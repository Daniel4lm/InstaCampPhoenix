export default {
    mounted() {
        let commentInput = this.el
        let commentFormSubmit =
            document.querySelector('#comment-form-submit')

        commentInput.addEventListener('input', (e) => {
            e.target.style.height = 'auto'
            e.target.style.height = e.target.scrollHeight + 'px'
        })
    }
}