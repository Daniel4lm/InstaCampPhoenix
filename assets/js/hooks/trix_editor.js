export default {
    mounted() {

        let trixEditor = document.querySelector("trix-editor")

        if (null != trixEditor) {
            trixEditor.editor.loadHTML(this.el.value);
        }

    }
}