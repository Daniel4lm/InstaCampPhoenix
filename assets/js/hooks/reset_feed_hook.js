export default {
    mounted() {
        // let postFeedList = document.getElementById("posts-feed")
        let postFeedList = this.el
        let children = postFeedList.children;
        let submitButton = document.getElementById("submit-button")
        let resetFormButton = document.getElementById("reset_button")

        submitButton.addEventListener('click', (e) => { this.assignStreamIds(children) })
        resetFormButton.addEventListener('click', (e) => { this.clearPostList(children) })
    },
    assignStreamIds(children) {
        this.pushEvent("assign_stream_ids", { ids_list: this.getChildrenIdList(children) })
    },
    clearPostList(children) {
        this.pushEvent("clear_post_list", { ids_list: this.getChildrenIdList(children) })
    },
    getChildrenIdList(children) {
        return Array.from(children).map((child) => child.id)
    }
}