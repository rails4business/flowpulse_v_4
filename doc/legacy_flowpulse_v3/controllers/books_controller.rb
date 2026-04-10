class BooksController < ApplicationController
  layout false

  allow_unauthenticated_access only: %i[library index show presale legacy_show legacy_presale]
  before_action :require_superadmin_for_book_management!, if: :book_management_action?
  before_action :set_book, only: %i[index show presale]
  before_action :set_book_paths, only: %i[index show presale]

  BOOK_ONLINE_SERVICE_SLUG = "libro-online-il-corpo-un-mondo-da-scoprire"
  DEFAULT_BOOK_FOLDER = "posturacorretta_il_corpo_un_mondo_da_scoprire"
  DEFAULT_BOOK_INDEX_FILE = "posturacorretta_il_corpo_un_mondo_da_scoprire.yml"

  # Access options:
  # - hidden: sempre nascosto e bloccato
  # - draft: non pubblicato (bloccato)
  # - free: pubblico
  # - registered: visibile/leggibile solo con login
  # - reg_hide: come registered, ma nascosto dall'indice se non loggato
  # - payment: visibile/leggibile solo se pagato
  # - pay_hide: come payment, ma nascosto dall'indice se non pagato

  def library
    @superadmin_library = Current.user&.superadmin? && Current.user&.superadmin_mode_active?
    @library_view = normalize_library_view(params[:view], @superadmin_library)
    @library_tab = normalize_library_tab(params[:tab])

    if @superadmin_library && @library_view == "admin"
      scope = Book.order(:title, :id)
      @active_books = scope.where(active: true)
      @inactive_books = scope.where.not(active: true)
      @books_to_create = discover_books_to_create
      @books = books_for_tab
    else
      @books = public_books_for_library
      @books = Book.active.order(:title, :id) if @books.empty?
      @library_tab = "active"
    end
  end

  def index
    return redirect_to(books_path, alert: "Libro non trovato.") unless @book

    @toc = Books::TocService.new(yaml_path: @book_yaml_path, md_dir: @book_md_dir).call
                            .select { |item| access_visible_in_index?(item[:access]) }
  end

  def presale
    # Renders app/views/books/presale.html.erb
  end

  def show
    return redirect_to(books_path, alert: "Libro non trovato.") unless @book

    slug = params[:id].to_s
    safe_slug = slug.gsub(/[^a-zA-Z0-9\-_\.]/, "")
    safe_slug_base = safe_slug.sub(/\.md\z/, "")

    file_path = find_book_file(@book_md_dir, safe_slug_base)

    if file_path && File.exist?(file_path)
      raw = File.read(file_path)
      frontmatter, body = extract_frontmatter(raw)
      access = normalize_access(frontmatter["access"])

      if access_blocked?(access)
        return redirect_to(book_presale_path(book_slug: @book.slug),
                           alert: "Il libro è in prevendita: puoi acquistarlo per sostenere il progetto o seguire l'avanzamento.")
      end

      toc = Books::TocService.new(yaml_path: @book_yaml_path, md_dir: @book_md_dir).call
      chapters = toc.reject { |item| item[:header] }

      normalize = ->(s) { s.to_s.sub(/\.md\z/, "") }
      current_index = chapters.index { |c| normalize.call(c[:slug]) == normalize.call(slug) }

      @chapter_markdown = body
      @chapter_meta = frontmatter
      @chapter_title = frontmatter["title"] || chapters[current_index]&.dig(:title) || slug
      @chapter_description = frontmatter["description"] || chapters[current_index]&.dig(:description)
      @chapter_slug = safe_slug_base
      @prev_chapter = current_index && current_index > 0 ? chapters[current_index - 1] : nil
      @next_chapter = current_index && current_index < chapters.length - 1 ? chapters[current_index + 1] : nil
    else
      render plain: "Contenuto non trovato per #{slug}", status: :not_found
    end
  end

  def legacy_show
    book = default_book_for_legacy
    return redirect_to(books_path, alert: "Nessun libro disponibile.") unless book

    redirect_to book_chapter_path(book_slug: book.slug, id: params[:id]), status: :moved_permanently
  end

  def legacy_presale
    book = default_book_for_legacy
    return redirect_to(books_presale_path) unless book

    redirect_to book_presale_path(book_slug: book.slug), status: :moved_permanently
  end

  private

  def set_book
    @book = if params[:book_slug].present?
              books_for_current_domain.find_by(slug: params[:book_slug]) || Book.active.find_by(slug: params[:book_slug])
            else
              default_book_for_legacy
            end
  end

  def default_book_for_legacy
    books_for_current_domain.first || Book.active.order(:title, :id).first
  end

  def books_for_current_domain
    scope = Book.active
    domain = Current.domain
    return scope.order(:title, :id) unless domain

    scoped = scope.joins(:book_domains).where(book_domains: { domain_id: domain.id }).distinct.order(:title, :id)
    return scoped if scoped.exists?

    scope.order(:title, :id)
  end

  def set_book_paths
    @book_md_dir = resolve_book_md_dir(@book)
    @book_yaml_path = resolve_book_yaml_path(@book, @book_md_dir)
  end

  def resolve_book_md_dir(book)
    candidate = resolve_data_folder_candidate(book&.folder_md)
    return candidate if candidate && Dir.exist?(candidate)

    Rails.root.join("config", "data", "books", DEFAULT_BOOK_FOLDER)
  end

  def resolve_book_yaml_path(book, md_dir)
    configured = resolve_data_file_candidate(book&.index_file, md_dir)
    return configured if configured && File.exist?(configured)

    fallback_in_dir = md_dir.join(DEFAULT_BOOK_INDEX_FILE)
    return fallback_in_dir if File.exist?(fallback_in_dir)

    Rails.root.join("config", "data", "books", DEFAULT_BOOK_FOLDER, DEFAULT_BOOK_INDEX_FILE)
  end

  def resolve_data_folder_candidate(value)
    return nil if value.blank?

    raw = value.to_s.strip
    absolute = Pathname.new(raw)
    return absolute if absolute.absolute?

    direct = Rails.root.join("config", "data", raw)
    return direct if Dir.exist?(direct)

    Rails.root.join("config", "data", "books", raw)
  end

  def resolve_data_file_candidate(value, md_dir)
    return nil if value.blank?

    raw = value.to_s.strip
    absolute = Pathname.new(raw)
    return absolute if absolute.absolute?

    in_data = Rails.root.join("config", "data", raw)
    return in_data if File.exist?(in_data)

    in_md_dir = md_dir.join(raw)
    return in_md_dir if File.exist?(in_md_dir)

    Rails.root.join("config", "data", "books", raw)
  end

  def extract_frontmatter(text)
    match = text.match(/\A---\n(.*?)\n---\n/m)
    return [{}, text] unless match

    frontmatter = YAML.safe_load(match[1], permitted_classes: [], aliases: false) || {}
    body = text.sub(/\A---\n(.*?)\n---\n/m, "")
    [frontmatter, body]
  rescue StandardError
    [{}, text]
  end

  def find_book_file(dir, safe_slug_base)
    file_path = dir.join("#{safe_slug_base}.md")
    return file_path if File.exist?(file_path)

    match = Dir.glob(dir.join("*#{safe_slug_base}.md")).first
    return match if match

    Dir.glob(dir.join("*.md")).each do |path|
      text = File.read(path)
      fm = text.match(/\A---\n(.*?)\n---\n/m)
      next unless fm
      front = YAML.safe_load(fm[1], permitted_classes: [], aliases: false) || {}
      file_slug = front["slug"].to_s.sub(/\.md\z/, "")
      return path if file_slug == safe_slug_base
    rescue StandardError
      next
    end

    nil
  end

  def normalize_access(value)
    value.to_s.strip.downcase.presence || "draft"
  end

  def access_blocked?(access)
    return false if Current.user&.superadmin? && Current.user.superadmin_mode_active?
    return true if access == "hidden"

    case access
    when "draft"
      true
    when "free"
      false
    when "registered", "reg_hide"
      !authenticated?
    when "payment", "pay_hide"
      !paid_access?
    else
      true
    end
  end

  def access_visible_in_index?(access)
    return true if Current.user&.superadmin? && Current.user.superadmin_mode_active?
    return false if access == "hidden"

    case access
    when "free"
      true
    when "draft"
      true
    when "registered"
      true
    when "reg_hide"
      authenticated?
    when "payment"
      true
    when "pay_hide"
      paid_access?
    else
      false
    end
  end

  def paid_access?
    service = Service.find_by(slug: BOOK_ONLINE_SERVICE_SLUG)
    return false unless service

    lead = Current.user&.lead
    return false unless lead

    lead.enrollments.where(service_id: service.id, status: %i[confirmed completed]).exists?
  end

  def require_superadmin_for_book_management!
    return if Current.user&.superadmin?

    redirect_to root_path, alert: "Non autorizzato."
  end

  def book_management_action?
    action_name.in?(%w[new create edit update destroy])
  end

  def normalize_library_tab(value)
    tab = value.to_s
    return tab if %w[active inactive to_create].include?(tab)

    "active"
  end

  def normalize_library_view(value, superadmin_library)
    return "public" unless superadmin_library

    view = value.to_s
    return view if %w[public admin].include?(view)

    "public"
  end

  def books_for_tab
    case @library_tab
    when "inactive"
      @inactive_books
    when "to_create"
      @books_to_create
    else
      @active_books
    end
  end

  def public_books_for_library
    books_for_current_domain
  end

  def discover_books_to_create
    books_root = Rails.root.join("config", "data", "books")
    return [] unless Dir.exist?(books_root)

    known = Book.pluck(:folder_md).compact.map { |value| normalize_folder_key(value) }

    Dir.children(books_root).sort.filter_map do |entry|
      next if entry.start_with?(".")

      dir_path = books_root.join(entry)
      next unless Dir.exist?(dir_path)
      next if known.include?(entry)

      index_candidate = find_index_candidate(dir_path, entry)
      {
        folder_name: entry,
        folder_md: "books/#{entry}",
        index_file: index_candidate,
        slug: entry.parameterize(separator: "_"),
        title: entry.tr("_", " ").split.map(&:capitalize).join(" ")
      }
    end
  end

  def normalize_folder_key(value)
    raw = value.to_s.strip.sub(%r{/\z}, "")
    return "" if raw.blank?
    return File.basename(raw) if raw.start_with?("/")

    normalized = raw.sub(%r{\Aconfig/data/books/}, "")
    normalized = normalized.sub(%r{\Abooks/}, "")
    normalized.split("/").reject(&:blank?).last.to_s
  end

  def find_index_candidate(dir_path, folder_name)
    expected = "#{folder_name}.yml"
    return expected if File.exist?(dir_path.join(expected))

    first_yml = Dir.children(dir_path).find { |name| name.end_with?(".yml") }
    first_yml || expected
  end
end
