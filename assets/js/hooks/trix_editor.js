let TrixEditorHooks = {}

TrixEditorHooks.PostFormBodyHook = {
    mounted() {
        const trixEditor = document.querySelector("trix-editor")

        if (null != trixEditor) {
            trixEditor.editor.loadHTML(this.el.value)
        }
    }
}

TrixEditorHooks.CommentBodyHook = {
    updated() {
        const trixEditor = document.querySelector("trix-editor")
        trixEditor.editor.loadHTML(this.el.value)
    }
}

TrixEditorHooks.PostContentFormat = {
    getContentItems(source) {
        const sideNavLinks = []

        const contentElements = Array.from(source.children).map((element) => {
            if (element.nodeName.startsWith('H')) {
                const newSectionElement = document.createElement("a");
                const slugName = element.textContent.trim().toLowerCase().split(/[,\s'\/]/).join('-')
                newSectionElement.setAttribute('href', '#' + slugName)
                newSectionElement.setAttribute('id', slugName)
                newSectionElement.innerHTML = element.textContent.trim()
                newSectionElement.classList.add('text-link', 'pt-8')
                sideNavLinks.push({
                    href: newSectionElement.getAttribute('href'),
                    title: newSectionElement.textContent.trim()
                })
                return newSectionElement
            } else {
                return element
            }
        })

        return [contentElements, sideNavLinks]
    },
    mounted() {
        const [contentElements, sideNavLinks] = this.getContentItems(this.el)
        this.el.replaceChildren(...contentElements)

        this.pushEventTo('#user-post', 'side_nav_items', { side_items: sideNavLinks })
    },

    updated() {
        const [contentElements,] = this.getContentItems(this.el)
        this.el.replaceChildren(...contentElements)

        const sideNavList = Array.from(document.querySelectorAll('a[id*="side-nav-link"]'))

        document.addEventListener("scroll", (event) => {
            const currentScroll = window.pageYOffset
            contentElements.map((contentItem, index) => {
                if (contentItem.nodeName == 'A' && index >= 0 && currentScroll >= contentItem.offsetTop) {
                    sideNavList.filter((item) => {
                        if (item.hash === contentItem.hash) {
                            item.setAttribute('aria-current', true)
                        } else {
                            item.removeAttribute('aria-current')
                        }
                    })
                } else if (index == 0) {
                    Array.from(sideNavList).map((item) => item.removeAttribute('aria-current'))
                }
            })
        })
    }
}

export default TrixEditorHooks
