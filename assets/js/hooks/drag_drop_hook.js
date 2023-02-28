export default {
  mounted() {
    this.el.addEventListener('drop', dropped)
    this.el.addEventListener('dragover', dragOver)
    this.el.addEventListener('dragleave', dragLeave)

    const sub_elements = this.el.querySelectorAll("[class~='drag-sub-el']")

    function dropped(e) {
      this.classList.remove('text-indigo-400', 'border-indigo-400', 'dark:border-blue-400')
      removeStyle('text-indigo-400')
    }

    function dragOver(e) {
      cancelDefault(e)
      this.classList.add('text-indigo-400', 'border-indigo-400', 'dark:border-blue-400')
      addStyle('text-indigo-400')
    }

    function dragLeave(e) {
      this.classList.remove('text-indigo-400', 'border-indigo-400', 'dark:border-blue-400')
      removeStyle('text-indigo-400')
    }

    function addStyle(style) {
      sub_elements.forEach((target) => {
        target.classList.add(style)
      })
    }

    function removeStyle(style) {
      sub_elements.forEach((target) => {
        target.classList.remove(style)
      })
    }

    function cancelDefault(e) {
      e.preventDefault()
      e.stopPropagation()
      return false
    }
  },
}
