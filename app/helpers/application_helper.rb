module ApplicationHelper
  def render_markdown(markdown)
    lines = markdown.to_s.split("\n")
    rendered = []
    paragraph = []
    list_items = []
    list_type = nil
    quote_lines = []

    flush_paragraph = lambda do
      next if paragraph.empty?

      rendered << content_tag(:p, markdown_lines(paragraph.join("\n")), class: "blog-content-paragraph")
      paragraph = []
    end

    flush_list = lambda do
      next if list_items.empty? || list_type.blank?

      css_class = ["blog-content-list"]
      css_class << "blog-content-list-ordered" if list_type == :ol
      rendered << content_tag(list_type, class: css_class.join(" ")) do
        safe_join(list_items.map { |item| content_tag(:li, render_inline_markdown(item)) })
      end
      list_items = []
      list_type = nil
    end

    flush_quote = lambda do
      next if quote_lines.empty?

      rendered << content_tag(:blockquote, markdown_lines(quote_lines.join("\n")), class: "blog-content-quote")
      quote_lines = []
    end

    lines.each do |raw_line|
      line = raw_line.strip

      if line.blank?
        flush_paragraph.call
        flush_list.call
        flush_quote.call
        next
      end

      case line
      when /\A######\s+(.+)/
        flush_paragraph.call
        flush_list.call
        flush_quote.call
        rendered << content_tag(:h6, render_inline_markdown(Regexp.last_match(1)), class: "blog-content-heading blog-content-heading-tiny")
      when /\A#####\s+(.+)/
        flush_paragraph.call
        flush_list.call
        flush_quote.call
        rendered << content_tag(:h5, render_inline_markdown(Regexp.last_match(1)), class: "blog-content-heading blog-content-heading-mini")
      when /\A####\s+(.+)/
        flush_paragraph.call
        flush_list.call
        flush_quote.call
        rendered << content_tag(:h4, render_inline_markdown(Regexp.last_match(1)), class: "blog-content-heading blog-content-heading-smallest")
      when /\A###\s+(.+)/
        flush_paragraph.call
        flush_list.call
        flush_quote.call
        rendered << content_tag(:h3, render_inline_markdown(Regexp.last_match(1)), class: "blog-content-heading blog-content-heading-small")
      when /\A##\s+(.+)/
        flush_paragraph.call
        flush_list.call
        flush_quote.call
        rendered << content_tag(:h2, render_inline_markdown(Regexp.last_match(1)), class: "blog-content-heading")
      when /\A#\s+(.+)/
        flush_paragraph.call
        flush_list.call
        flush_quote.call
        rendered << content_tag(:h1, render_inline_markdown(Regexp.last_match(1)), class: "blog-content-title")
      when /\A(?:---+|\*\*\*+)\z/
        flush_paragraph.call
        flush_list.call
        flush_quote.call
        rendered << tag.hr(class: "blog-content-divider")
      when /\A-\s+(.+)/
        flush_paragraph.call
        flush_quote.call
        if list_type != :ul
          flush_list.call
          list_type = :ul
        end
        list_items << Regexp.last_match(1)
      when /\A\d+\.\s+(.+)/
        flush_paragraph.call
        flush_quote.call
        if list_type != :ol
          flush_list.call
          list_type = :ol
        end
        list_items << Regexp.last_match(1)
      when /\A>\s?(.*)/
        flush_paragraph.call
        flush_list.call
        quote_lines << Regexp.last_match(1)
      else
        flush_list.call
        flush_quote.call
        paragraph << line
      end
    end

    flush_paragraph.call
    flush_list.call
    flush_quote.call

    safe_join(rendered)
  end

  def brand_public_title(webapp_domain, brand_port)
    webapp_domain&.title.presence || brand_port&.name || "Flowpulse"
  end

  def brand_public_theme(webapp_domain)
    {
      header_bg: "#ffffff",
      header_text: "#0f172a",
      accent: webapp_domain&.accent_color.presence || "#0f766e",
      background: webapp_domain&.background_color.presence || "#f8fafc"
    }
  end

  def brand_public_nav_links(brand_nav_routes)
    [{ label: "Home", href: root_path }] +
      Array.wrap(brand_nav_routes).map do |route|
        { label: route.target_port.name, href: "#brand-port-#{route.target_port.id}" }
      end
  end

  def embeddable_media_url(url)
    value = url.to_s.strip
    return nil if value.blank?

    if value =~ %r{\Ahttps?://(?:www\.)?youtube\.com/watch\?v=([^&]+)}i
      "https://www.youtube.com/embed/#{$1}"
    elsif value =~ %r{\Ahttps?://youtu\.be/([^?&/]+)}i
      "https://www.youtube.com/embed/#{$1}"
    elsif value =~ %r{\Ahttps?://(?:www\.)?youtube\.com/embed/([^?&/]+)}i
      "https://www.youtube.com/embed/#{$1}"
    elsif value =~ %r{\Ahttps?://(?:www\.)?vimeo\.com/(\d+)}i
      "https://player.vimeo.com/video/#{$1}"
    elsif value =~ %r{\Ahttps?://player\.vimeo\.com/video/(\d+)}i
      "https://player.vimeo.com/video/#{$1}"
    end
  end

  private
    def markdown_lines(text)
      safe_join(text.split("\n").map { |line| render_inline_markdown(line.strip) }, tag.br)
    end

    def render_inline_markdown(text)
      html = ERB::Util.html_escape(text.to_s)
      html = html.gsub(/`([^`]+)`/, '<code>\1</code>')
      html = html.gsub(/\*\*([^*]+)\*\*/, '<strong>\1</strong>')
      html = html.gsub(/\*([^*]+)\*/, '<em>\1</em>')
      html = html.gsub(/\[([^\]]+)\]\((https?:\/\/[^)\s]+)\)/, '<a href="\2" target="_blank" rel="noopener noreferrer">\1</a>')
      html.html_safe
    end
end
