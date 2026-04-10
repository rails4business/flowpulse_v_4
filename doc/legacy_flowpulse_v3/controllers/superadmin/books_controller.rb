module Superadmin
  class BooksController < ApplicationController
    include RequireSuperadmin

    before_action :require_superadmin_mode_active!
    before_action :set_book, only: %i[show edit update destroy]
    before_action :load_domains, only: %i[new edit create update]

    def index
      @books = Book.includes(:domains).order(Arel.sql("COALESCE(sort_position, 999999) ASC"), :title, :id)
    end

    def show
    end

    def new
      preset = params.fetch(:book, {}).permit(
        :slug, :title, :subtitle, :author, :description,
        :published_at, :isbn, :language, :pages_count, :sort_position,
        :url_cover_front, :url_cover_back,
        :folder_md, :index_file,
        :price_euro, :price_dash,
        :access_mode, :active
      )
      @book = Book.new({ active: true }.merge(preset.to_h))
    end

    def edit
    end

    def create
      @book = Book.new(book_params)
      assign_domains

      if @book.save
        redirect_to [:superadmin, @book], notice: "Libro creato.", status: :see_other
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @book.assign_attributes(book_params)
      assign_domains

      if @book.save
        redirect_to [:superadmin, @book], notice: "Libro aggiornato.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @book.destroy!
      redirect_to superadmin_books_path, notice: "Libro eliminato.", status: :see_other
    end

    private

    def set_book
      @book = Book.find(params.expect(:id))
    end

    def load_domains
      @domains = Domain.order(:host)
    end

    def book_params
      params.expect(book: [
        :slug, :title, :subtitle, :author, :description,
        :published_at, :isbn, :language, :pages_count, :sort_position,
        :url_cover_front, :url_cover_back,
        :folder_md, :index_file,
        :price_euro, :price_dash,
        :access_mode, :active,
        :cover_image
      ])
    end

    def assign_domains
      ids = Array(params.dig(:book, :domain_ids)).filter_map { |id| id.to_s.strip.presence&.to_i }.uniq
      @book.domain_ids = ids
    end

    def require_superadmin_mode_active!
      return if Current.user&.superadmin_mode_active?

      redirect_to dashboard_home_path, alert: "Attiva la modalita superadmin per gestire i libri."
    end
  end
end
