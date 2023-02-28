export default {
    mounted() {
        let hoverItem = this.el
        let tooltip = hoverItem.querySelector("[class*='tooltip-text']")

        hoverItem.addEventListener('mouseover', (e) => {
            tooltip.classList.add('tooltip-text-hover')
        })

        hoverItem.addEventListener('click', (e) => {
            tooltip.classList.remove('tooltip-text-hover')
        })

        hoverItem.addEventListener('mouseleave', (e) => {
            tooltip.classList.remove('tooltip-text-hover')
        })
    }
}