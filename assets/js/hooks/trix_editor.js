let TrixEditorHooks = {}

TrixEditorHooks.PostBodyHook = {
    mounted() {
        let trixEditor = document.querySelector("trix-editor")

        if (null != trixEditor) {
            trixEditor.editor.loadHTML(this.el.value);
        }
    }
}

TrixEditorHooks.CommentBodyHook = {
    updated() {
        let trixEditor = document.querySelector("trix-editor")
        trixEditor.editor.loadHTML(this.el.value)
    }
}

export default TrixEditorHooks
