export default {
    mounted() {
        this.el.addEventListener("keydown", (e) => {

            const keyActions = ['Comma', 'Enter', 'Tab']

            if (keyActions.includes(e.code) || keyActions.includes(e.key)) {
                e.preventDefault()
                let tags = e.target.value.replace(/[\s#\/+-]+/g, "")

                tags.split(',').forEach((tag) => {
                    if (tag.length > 0) {
                        this.pushEvent('add-item', tag)
                    }
                });
                e.target.value = ''
            }
        });
    },
};