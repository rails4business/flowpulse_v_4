module Superadmin
  class BackupsController < ApplicationController
    include RequireSuperadmin

    STRATEGIES = [
      [ "Solo analisi (consigliato)", "analyze_only" ],
      [ "Clona tutto in locale (sovrascrive DB locale)", "replace_local" ],
      [ "Merge guidato (manuale)", "guided_merge" ]
    ].freeze

    def index
      initialize_page_state
    end

    def analyze
      initialize_page_state
      @selected_strategy = strategy_param
      uploaded = uploaded_dump_param

      if uploaded.blank?
        flash.now[:alert] = "Seleziona un file dump `.sql` o `.sql.gz`."
        render :index, status: :unprocessable_entity
        return
      end

      @analysis = analyze_dump(uploaded)
      @commands = build_command_plan(@selected_strategy, @analysis)
      flash.now[:notice] = analysis_notice(@analysis)
      render :index
    rescue StandardError => e
      Rails.logger.error("[Backups#analyze] #{e.class}: #{e.message}")
      flash.now[:alert] = "Analisi dump non riuscita: #{e.message}"
      render :index, status: :unprocessable_entity
    end

    private

    def initialize_page_state
      @strategies = STRATEGIES
      @selected_strategy = "analyze_only"
      @analysis = nil
      @commands = []
      @development_env = Rails.env.development?
    end

    def strategy_param
      allowed = STRATEGIES.map(&:last)
      selected = params[:strategy] || params.dig(:backup, :strategy) || params.dig(:backups, :strategy)
      allowed.include?(selected) ? selected : "analyze_only"
    end

    def uploaded_dump_param
      params[:dump_file] || params.dig(:backup, :dump_file) || params.dig(:backups, :dump_file)
    end

    def analyze_dump(uploaded)
      filename = uploaded.original_filename.to_s
      file_format = detect_dump_format(uploaded.tempfile.path, filename)
      gzipped = file_format == :gzip
      tables = []
      has_pg_dump_signature = false
      custom_dump_format = file_format == :pg_custom
      copy_statements = 0
      insert_statements = 0
      create_table_statements = 0
      sampled_lines = 0

      if [ :plain, :gzip ].include?(file_format)
        with_dump_reader(uploaded.tempfile.path, file_format) do |reader|
          reader.each_line do |line|
            line = normalize_dump_line(line)
            normalized = line.lstrip
            sampled_lines += 1
            has_pg_dump_signature ||= normalized.include?("PostgreSQL database dump")

            if (table_name = extract_table_name_from_copy(normalized))
              tables << table_name unless tables.include?(table_name)
              copy_statements += 1
              next
            end

            if (table_name = extract_table_name_from_insert(normalized))
              tables << table_name unless tables.include?(table_name)
              insert_statements += 1
              next
            end

            if (table_name = extract_table_name_from_create(normalized))
              tables << table_name unless tables.include?(table_name)
              create_table_statements += 1
            end
          end
        end
      else
        tables = extract_tables_with_pg_restore(uploaded.tempfile.path, file_format)
      end

      {
        filename: filename,
        size_human: ActiveSupport::NumberHelper.number_to_human_size(uploaded.size),
        gzipped: gzipped,
        detected_format: file_format.to_s,
        has_pg_dump_signature: has_pg_dump_signature,
        custom_dump_format: custom_dump_format,
        tables: tables.sort,
        tables_count: tables.size,
        copy_statements: copy_statements,
        insert_statements: insert_statements,
        create_table_statements: create_table_statements,
        sampled_lines: sampled_lines
      }
    end

    def analysis_notice(analysis)
      if [ "pg_custom", "tar" ].include?(analysis[:detected_format]) && analysis[:tables_count].zero?
        "Analisi completata: dump binario rilevato, anteprima tabelle non disponibile ma piano comandi pronto."
      else
        "Analisi completata: #{analysis[:tables_count]} tabelle rilevate."
      end
    end

    def detect_dump_format(path, filename)
      header = File.binread(path, 10) || ""
      return :gzip if header.bytes[0, 2] == [0x1F, 0x8B]
      return :pg_custom if header.start_with?("PGDMP")
      return :tar if tar_archive?(path)
      return :gzip if filename.to_s.downcase.end_with?(".gz")
      return :tar if filename.to_s.downcase.end_with?(".tar")
      return :pg_custom if filename.to_s.downcase.end_with?(".dump")

      :plain
    rescue StandardError
      filename.to_s.downcase.end_with?(".gz") ? :gzip : :plain
    end

    def tar_archive?(path)
      File.open(path, "rb") do |f|
        f.seek(257)
        signature = f.read(5)
        signature == "ustar"
      end
    rescue StandardError
      false
    end

    def extract_tables_with_pg_restore(path, format)
      require "open3"

      command = [ "pg_restore", "-l" ]
      command += [ "-F", "t" ] if format == :tar
      command << path
      output, status = Open3.capture2e(*command)
      return [] unless status.success?

      tables = []
      output.each_line do |line|
        normalized = normalize_dump_line(line).strip
        next if normalized.empty?
        next unless normalized.include?("TABLE")

        # Typical lines:
        # ; ... TABLE public users postgres
        # ; ... TABLE DATA public users postgres
        if (match = normalized.match(/\bTABLE(?: DATA)?\s+(\S+)\s+(\S+)/))
          schema = match[1]
          table = match[2]
          table_name = clean_table_name("#{schema}.#{table}")
          tables << table_name unless tables.include?(table_name)
        end
      end

      tables.sort
    rescue StandardError
      []
    end

    def with_dump_reader(path, format)
      require "zlib"

      if format == :gzip
        Zlib::GzipReader.open(path) { |reader| yield(reader) }
      else
        File.open(path, "rb") { |reader| yield(reader) }
      end
    end

    def normalize_dump_line(line)
      return "" if line.nil?

      line.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
    rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
      line.to_s.force_encoding("BINARY").encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
    end

    def clean_table_name(value)
      raw = value.to_s.strip
      raw = raw.sub(/\AONLY\s+/i, "")
      raw = raw.delete('"')
      raw = raw.gsub(/\[[^\]]+\]/, "")
      raw.split(".").last
    end

    def extract_table_name_from_copy(line)
      # Supports forms like:
      # COPY public.users (
      # COPY "public"."users" (
      # COPY ONLY public.users (
      match = line.match(/\ACOPY\s+(.+?)\s+\(/i)
      return nil unless match

      clean_table_name(match[1])
    end

    def extract_table_name_from_insert(line)
      # Supports forms like:
      # INSERT INTO public.users ...
      # INSERT INTO "public"."users" ...
      match = line.match(/\AINSERT INTO\s+(.+?)(?:\s|\()/i)
      return nil unless match

      clean_table_name(match[1])
    end

    def extract_table_name_from_create(line)
      # Supports forms like:
      # CREATE TABLE public.users (
      # CREATE TABLE IF NOT EXISTS "public"."users" (
      match = line.match(/\ACREATE TABLE(?: IF NOT EXISTS)?\s+(.+?)\s*\(/i)
      return nil unless match

      clean_table_name(match[1])
    end

    def build_command_plan(strategy, analysis)
      if !Rails.env.development? && strategy != "analyze_only"
        return [
          "# Bloccato: operazione guidata disponibile solo in development.",
          "# In produzione/staging usa restore ufficiale da Hatchbox."
        ]
      end

      db_cfg = ActiveRecord::Base.connection_db_config.configuration_hash
      db_name = db_cfg[:database]
      db_host = db_cfg[:host].presence || "localhost"
      db_port = db_cfg[:port].presence || 5432
      db_user = db_cfg[:username].presence || ENV["USER"]
      placeholder = "/path/to/#{analysis[:filename]}"
      psql_base = "psql -h #{db_host} -p #{db_port} -U #{db_user} -d #{db_name}"
      pg_restore_base = "pg_restore --no-owner --no-privileges -h #{db_host} -p #{db_port} -U #{db_user} -d #{db_name}"
      restore_cmd = restore_command_for_format(analysis[:detected_format], placeholder, psql_base, pg_restore_base)

      case strategy
      when "replace_local"
        [
          "bin/rails db:drop db:create",
          restore_cmd,
          "bin/rails db:migrate"
        ]
      when "guided_merge"
        [
          "# 1) Crea un DB temporaneo locale",
          "createdb #{db_name}_import_tmp",
          guided_import_cmd(analysis[:detected_format], placeholder, db_name),
          "# 2) Confronta dati da mantenere (users/leads) e prepara SQL di merge manuale",
          "psql -d #{db_name}_import_tmp -c \"SELECT COUNT(*) FROM users;\"",
          "psql -d #{db_name} -c \"SELECT COUNT(*) FROM users;\"",
          "# 3) Esegui merge SOLO dopo query di confronto e backup locale",
          "dropdb #{db_name}_import_tmp"
        ]
      else
        [
          "# Analisi completata: nessuna modifica al database.",
          "# Se vuoi procedere, scegli una strategia e rilancia."
        ]
      end
    end

    def restore_command_for_format(format, placeholder, psql_base, pg_restore_base)
      case format
      when "pg_custom"
        "#{pg_restore_base} #{placeholder}"
      when "tar"
        "#{pg_restore_base} -F t #{placeholder}"
      when "gzip"
        "gunzip -c #{placeholder} | #{psql_base}"
      else
        "#{psql_base} -f #{placeholder}"
      end
    end

    def guided_import_cmd(format, placeholder, db_name)
      case format
      when "pg_custom"
        "pg_restore --no-owner --no-privileges -d #{db_name}_import_tmp #{placeholder}"
      when "tar"
        "pg_restore --no-owner --no-privileges -F t -d #{db_name}_import_tmp #{placeholder}"
      when "gzip"
        "gunzip -c #{placeholder} | psql -d #{db_name}_import_tmp"
      else
        "psql -d #{db_name}_import_tmp -f #{placeholder}"
      end
    end
  end
end
