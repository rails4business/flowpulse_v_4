class BookIndexController < ApplicationController
  allow_unauthenticated_access only: :show

  def show
    md_dir, yaml_path = resolve_book_paths
    data = if File.exist?(yaml_path)
             YAML.load_file(yaml_path)
           else
             Books::TocService.new(md_dir: md_dir, yaml_path: yaml_path).call
           end
    render json: data
  end

  private

  def resolve_book_paths
    default_folder = "posturacorretta_il_corpo_un_mondo_da_scoprire"
    default_index_file = "posturacorretta_il_corpo_un_mondo_da_scoprire.yml"
    default_md_dir = Rails.root.join("config", "data", "books", default_folder)
    default_yaml_path = default_md_dir.join(default_index_file)

    book = if Current.domain
             Book.active.joins(:book_domains).where(book_domains: { domain_id: Current.domain.id }).order(:id).first
           else
             Book.active.order(:id).first
           end
    return [default_md_dir, default_yaml_path] unless book

    md_dir = if book.folder_md.present?
               configured = Pathname.new(book.folder_md)
               if configured.absolute?
                 configured
               else
                 Rails.root.join("config", "data", book.folder_md)
               end
             else
               default_md_dir
             end

    md_dir = default_md_dir unless Dir.exist?(md_dir)

    yaml_path = if book.index_file.present?
                  configured = Pathname.new(book.index_file)
                  if configured.absolute?
                    configured
                  else
                    in_data = Rails.root.join("config", "data", book.index_file)
                    File.exist?(in_data) ? in_data : md_dir.join(book.index_file)
                  end
                else
                  default_yaml_path
                end

    [md_dir, yaml_path]
  end
end
