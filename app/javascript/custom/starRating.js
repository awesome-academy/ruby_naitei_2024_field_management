document.addEventListener('turbo:load', function () {
  const stars = document.querySelectorAll('#star-rating .fa-star')
  const ratingInput = document.getElementById('rating-input')

  if (ratingInput) {
    const setRating = (value) => {
      ratingInput.value = value
      stars.forEach((star) => {
        if (star.getAttribute('data-value') <= value) {
          star.classList.add('text-primary')
          star.classList.remove('text-gray-300')
        } else {
          star.classList.add('text-gray-300')
          star.classList.remove('text-primary')
        }
      })
    }

    setRating(ratingInput.value)

    stars.forEach((star) => {
      star.addEventListener('click', function () {
        const value = this.getAttribute('data-value')
        setRating(value)
      })
    })
  }
})
