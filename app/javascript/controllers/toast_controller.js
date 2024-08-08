import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['toast']

  connect() {
    setTimeout(() => {
      this.hide()
    }, 3000)
  }

  hide() {
    this.toastTarget.classList.add('opacity-0')
    this.toastTarget.classList.add('translate-y-4')
  }
}
