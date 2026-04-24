import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "dot"]
  static values = {
    images: Array,
    index: { type: Number, default: 0 }
  }

  connect() {
    this.boundKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundKeydown)
    this.render()
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundKeydown)
  }

  previous() {
    this.indexValue = (this.indexValue - 1 + this.imagesValue.length) % this.imagesValue.length
    this.render()
  }

  next() {
    this.indexValue = (this.indexValue + 1) % this.imagesValue.length
    this.render()
  }

  goTo(event) {
    this.indexValue = Number(event.currentTarget.dataset.index)
    this.render()
  }

  render() {
    if (!this.hasImageTarget || this.imagesValue.length === 0) return

    this.imageTarget.src = this.imagesValue[this.indexValue]
    this.dotTargets.forEach((dot, index) => {
      dot.classList.toggle("is-active", index === this.indexValue)
    })
  }

  handleKeydown(event) {
    if (event.key === "ArrowLeft") this.previous()
    if (event.key === "ArrowRight") this.next()
  }
}
