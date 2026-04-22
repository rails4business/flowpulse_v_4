import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.initializeEditor()
  }

  disconnect() {
    if (this.editor) {
      this.editor.toTextArea()
      this.editor = null
    }
  }

  initializeEditor() {
    if (this.editor || !this.hasInputTarget || typeof window.EasyMDE === "undefined") {
      return
    }

    this.editor = new window.EasyMDE({
      element: this.inputTarget,
      autoDownloadFontAwesome: false,
      spellChecker: false,
      status: ["lines", "words"],
      minHeight: "360px",
      placeholder: this.inputTarget.placeholder || "Scrivi il contenuto...",
      previewRender: (plainText) => this.renderMarkdown(plainText),
      renderingConfig: {
        singleLineBreaks: false,
        codeSyntaxHighlighting: false
      },
      toolbar: [
        "bold",
        "italic",
        "heading",
        "|",
        "quote",
        "unordered-list",
        "ordered-list",
        "|",
        "link",
        "image",
        "table",
        "code",
        "|",
        "preview",
        "side-by-side",
        "fullscreen",
        "|",
        "guide"
      ]
    })

    this.editor.codemirror.on("change", () => {
      this.inputTarget.value = this.editor.value()
    })
  }

  renderMarkdown(markdown) {
    const lines = (markdown || "").split("\n")
    const html = []
    let paragraph = []
    let listItems = []
    let listType = null
    let quoteLines = []

    const flushParagraph = () => {
      if (paragraph.length === 0) return
      html.push(`<p>${this.renderInlineMarkdown(paragraph.join("\n"), true)}</p>`)
      paragraph = []
    }

    const flushList = () => {
      if (listItems.length === 0 || !listType) return
      html.push(`<${listType}>${listItems.map((item) => `<li>${this.renderInlineMarkdown(item)}</li>`).join("")}</${listType}>`)
      listItems = []
      listType = null
    }

    const flushQuote = () => {
      if (quoteLines.length === 0) return
      html.push(`<blockquote>${this.renderInlineMarkdown(quoteLines.join("\n"), true)}</blockquote>`)
      quoteLines = []
    }

    for (const rawLine of lines) {
      const line = rawLine.trim()

      if (line === "") {
        flushParagraph()
        flushList()
        flushQuote()
        continue
      }

      let match

      if ((match = line.match(/^######\s+(.+)$/))) {
        flushParagraph()
        flushList()
        flushQuote()
        html.push(`<h6>${this.renderInlineMarkdown(match[1])}</h6>`)
        continue
      }

      if ((match = line.match(/^#####\s+(.+)$/))) {
        flushParagraph()
        flushList()
        flushQuote()
        html.push(`<h5>${this.renderInlineMarkdown(match[1])}</h5>`)
        continue
      }

      if ((match = line.match(/^####\s+(.+)$/))) {
        flushParagraph()
        flushList()
        flushQuote()
        html.push(`<h4>${this.renderInlineMarkdown(match[1])}</h4>`)
        continue
      }

      if ((match = line.match(/^###\s+(.+)$/))) {
        flushParagraph()
        flushList()
        flushQuote()
        html.push(`<h3>${this.renderInlineMarkdown(match[1])}</h3>`)
        continue
      }

      if ((match = line.match(/^##\s+(.+)$/))) {
        flushParagraph()
        flushList()
        flushQuote()
        html.push(`<h2>${this.renderInlineMarkdown(match[1])}</h2>`)
        continue
      }

      if ((match = line.match(/^#\s+(.+)$/))) {
        flushParagraph()
        flushList()
        flushQuote()
        html.push(`<h1>${this.renderInlineMarkdown(match[1])}</h1>`)
        continue
      }

      if (/^(---+|\*\*\*+)$/.test(line)) {
        flushParagraph()
        flushList()
        flushQuote()
        html.push("<hr>")
        continue
      }

      if ((match = line.match(/^-\s+(.+)$/))) {
        flushParagraph()
        flushQuote()
        if (listType !== "ul") {
          flushList()
          listType = "ul"
        }
        listItems.push(match[1])
        continue
      }

      if ((match = line.match(/^\d+\.\s+(.+)$/))) {
        flushParagraph()
        flushQuote()
        if (listType !== "ol") {
          flushList()
          listType = "ol"
        }
        listItems.push(match[1])
        continue
      }

      if ((match = line.match(/^>\s?(.*)$/))) {
        flushParagraph()
        flushList()
        quoteLines.push(match[1])
        continue
      }

      flushList()
      flushQuote()
      paragraph.push(line)
    }

    flushParagraph()
    flushList()
    flushQuote()

    return html.join("")
  }

  renderInlineMarkdown(text, preserveBreaks = false) {
    let html = this.escapeHtml(text || "")

    html = html.replace(/`([^`]+)`/g, "<code>$1</code>")
    html = html.replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>")
    html = html.replace(/\*([^*]+)\*/g, "<em>$1</em>")
    html = html.replace(/\[([^\]]+)\]\((https?:\/\/[^)\s]+)\)/g, '<a href="$2" target="_blank" rel="noopener noreferrer">$1</a>')

    if (preserveBreaks) {
      html = html.replace(/\n/g, "<br>")
    }

    return html
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
