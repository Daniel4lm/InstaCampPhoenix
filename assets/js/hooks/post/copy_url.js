export default {
    mounted() {
        this.el.addEventListener('click', () => {
            let copyText = this.el.dataset.copyUrl
            copyPostUrl(copyText)
        })

        async function copyPostUrl(url) {
            try {
                let copyAnnouncer = document.getElementById('article-copy-link-announcer')
                copyAnnouncer.classList.remove('hidden')
                await navigator.clipboard.writeText(url)

                setTimeout(() => {
                    copyAnnouncer.classList.add('hidden')
                }, 4000)
            } catch (err) {
                console.error('Failed to copy url: ', err)
            }
        }
    }
}