class BlogPost
  CONTENT_PATH = Rails.root.join("content/flowpulse_blog").freeze

  attr_reader :slug, :title, :published_on, :body, :excerpt, :source_path

  class << self
    def all
      Dir.glob(CONTENT_PATH.join("*.md")).sort.reverse.filter_map do |path|
        build_from_file(Pathname.new(path))
      end
    end

    def find_by_slug!(slug)
      all.find { |post| post.slug == slug } || raise(ActiveRecord::RecordNotFound)
    end

    private
      def build_from_file(path)
        raw = path.read
        metadata, body = split_frontmatter(raw)
        filename_slug = path.basename(".md").to_s.sub(/\A\d+[-_]/, "")

        title = metadata["title"].presence || filename_slug.tr("-", " ").split.map(&:capitalize).join(" ")
        slug = metadata["slug"].presence || filename_slug.parameterize
        published_on = parse_date(metadata["date"]) || parse_date_from_filename(path.basename(".md").to_s)

        new(
          slug: slug,
          title: title,
          published_on: published_on,
          body: body.strip,
          excerpt: metadata["excerpt"].presence || build_excerpt(body),
          source_path: path
        )
      rescue Psych::SyntaxError
        nil
      end

      def split_frontmatter(raw)
        return [{}, raw] unless raw.start_with?("---\n")

        parts = raw.split(/^---\s*$\n?/, 3)
        return [{}, raw] if parts.length < 3

        metadata = YAML.safe_load(parts[1], permitted_classes: [Date], aliases: false) || {}
        [metadata, parts[2]]
      end

      def parse_date(value)
        return value if value.is_a?(Date)
        return if value.blank?

        Date.parse(value.to_s)
      rescue Date::Error
        nil
      end

      def parse_date_from_filename(filename)
        match = filename.match(/(\d{4})-(\d{2})-(\d{2})/)
        return unless match

        Date.new(match[1].to_i, match[2].to_i, match[3].to_i)
      end

      def build_excerpt(body)
        body.lines.reject { |line| line.strip.start_with?("#") }.join(" ").squish.truncate(180)
      end
  end

  def initialize(slug:, title:, published_on:, body:, excerpt:, source_path:)
    @slug = slug
    @title = title
    @published_on = published_on
    @body = body
    @excerpt = excerpt
    @source_path = source_path
  end
end
