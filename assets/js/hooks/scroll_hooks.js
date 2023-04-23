let ScrollHooks = {}

ScrollHooks.ScrollToComments = {
    mounted() {
        this.el.addEventListener('click', () => {
            const commentsSection = document.getElementById('post-comments-section')

            commentsSection.scrollIntoView({ behavior: 'smooth', block: "start" })
        })
    }
}

ScrollHooks.ScrollToTop = {
    mounted() {
        const scrollToTopButton = this.el
        const contentSection = document.getElementById('post-wrapper')

        window.addEventListener('scroll', () => {
            if (window.scrollY > 400) {
                scrollToTopButton.classList.replace('invisible', 'visible')
                scrollToTopButton.classList.replace('opacity-0', 'opacity-1')
                scrollToTopButton.classList.replace('sm:-bottom-10', 'sm:bottom-5')
            } else {
                scrollToTopButton.classList.replace('visible', 'invisible')
                scrollToTopButton.classList.replace('opacity-1', 'opacity-0')
                scrollToTopButton.classList.replace('sm:bottom-5', 'sm:-bottom-10')
            }
        })

        scrollToTopButton.addEventListener('click', () => {
            window.scroll({
                top: 0,
                left: 0,
                behavior: 'smooth'
            })
        })
    }
}

ScrollHooks.PostsPageInfiniteScroll = {
    mounted() {

        this.pageNumber = this.el.dataset.pageNumber
        this.observer = new IntersectionObserver((entries) => {
            const target = entries[0]
            if (target.isIntersecting) {
                setTimeout(() => {
                    this.pageNumber = parseInt(this.pageNumber) + 1
                    this.pushEvent("show_more_posts", { page: this.pageNumber })
                }, 1000)
            }
        },
            {
                root: null, // window by default
                rootMargin: "0px",
                threshold: 1.0,
            })
        this.observer.observe(this.el)
    },
    beforeDestroy() {
        this.observer.unobserve(this.el)
    },
    updated() {
        this.pageNumber = this.el.dataset.pageNumber
    },
}

ScrollHooks.TrixEditorScroll = {
    mounted() {
        const trixEditorContainer = this.el
        const trixToolbar = trixEditorContainer.querySelector('trix-toolbar')

        const trixEditorPos = trixEditorContainer.getBoundingClientRect()

        document.addEventListener("scroll", (event) => {
            const currentScroll = window.pageYOffset
            if (currentScroll >= trixEditorPos.top) {
                trixToolbar.classList.add('sticky', 'top-14', 'z-50', 'bg-white', 'border-b', 'border-gray-500', 'dark:bg-slate-500')
            } else {
                trixToolbar.classList.remove('sticky', 'top-14', 'z-50', 'bg-white', 'border-b', 'border-gray-500', 'dark:bg-slate-500')
            }
        })
    },
}

export default ScrollHooks