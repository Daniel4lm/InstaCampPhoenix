export default {
    mounted() {

        const postBody = this.el
        const readingTimeSummary = document.querySelector(".reading-time span");
        const avgWordsPerMin = 225;

        let count = getWordCount(postBody);
        let time = Math.ceil(count / avgWordsPerMin);

        readingTimeSummary.innerText = time + " min read";

        function getWordCount(content) {
            // return post.innerText.match(/\w+/g).length;
            return content.innerText.trim().split(/\s+/).length;
        }
    }
}