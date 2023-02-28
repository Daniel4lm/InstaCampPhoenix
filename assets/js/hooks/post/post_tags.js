export default {
    mounted() {
        this.el.addEventListener("keydown", (e) => {

            if (e.code == 'Comma' || e.key == 'Enter') {
                e.preventDefault()

                // let tags = e.target.value.replace(/\s+/g, "");
                let tags = e.target.value.trim();

                tags.split(',').forEach((tag) => {
                    if (tag.length > 0) {
                        this.pushEvent('add-item', tag);
                    }
                });
                e.target.value = '';
            }
        });
    },
};