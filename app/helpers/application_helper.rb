module ApplicationHelper
  def render_markdown(markdown)
    safe_join(markdown.to_s.split(/\n{2,}/).map { |block| render_markdown_block(block) })
  end

  private
    def render_markdown_block(block)
      stripped = block.strip
      return "".html_safe if stripped.blank?

      case stripped
      when /\A(?:-\s.+\n?)+\z/
        content_tag(:ul, class: "blog-content-list") do
          safe_join(stripped.lines.map { |line| content_tag(:li, line.sub(/\A-\s*/, "").strip) })
        end
      when /\A###\s+(.+)/
        content_tag(:h3, Regexp.last_match(1), class: "blog-content-heading blog-content-heading-small")
      when /\A##\s+(.+)/
        content_tag(:h2, Regexp.last_match(1), class: "blog-content-heading")
      when /\A#\s+(.+)/
        content_tag(:h1, Regexp.last_match(1), class: "blog-content-title")
      else
        content_tag(:p, markdown_lines(stripped), class: "blog-content-paragraph")
      end
    end

    def markdown_lines(text)
      safe_join(text.split("\n").map { |line| ERB::Util.html_escape(line.strip) }, tag.br)
    end
end
