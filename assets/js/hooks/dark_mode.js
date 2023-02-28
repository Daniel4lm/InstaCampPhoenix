let ThemeHooks = {}

ThemeHooks.DarkModeToggle = {
    mounted() {

        this.el.addEventListener('click', () => {

            fromLocalStorage = localStorage.getItem('color-theme')

            if (fromLocalStorage) {
                if (fromLocalStorage == 'light') {
                    document.documentElement.classList.add('dark')
                    localStorage.setItem('color-theme', 'dark')

                } else {
                    document.documentElement.classList.remove('dark')
                    localStorage.setItem('color-theme', 'light')
                }

            } else {
                if (document.documentElement.classList.contains('dark')) {
                    document.documentElement.classList.remove('dark')
                    localStorage.setItem('color-theme', 'light');

                } else {
                    document.documentElement.classList.add('dark')
                    localStorage.setItem('color-theme', 'dark');
                }
            }
        })
    }
}

export default ThemeHooks;