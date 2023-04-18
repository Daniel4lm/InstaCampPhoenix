let FormInputHooks = {}

FormInputHooks.InputShowPassword = {
    mounted() {
        let hook = this
        let button = hook.el
        let inputFieldID = this.el.dataset.inputId
        let inputField = document.getElementById(inputFieldID)

        let showPasswordIcon = document.getElementById('show-password-icon-' + inputFieldID)
        let hidePasswordIcon = document.getElementById('hide-password-icon-' + inputFieldID)

        let showIcon = () => {
            let type = inputField.getAttribute('type')

            if (type == 'password') {
                hidePasswordIcon.style.display = 'none'
                showPasswordIcon.style.display = 'block'
            } else {
                hidePasswordIcon.style.display = 'block'
                showPasswordIcon.style.display = 'none'
            }

            button.style.display = 'block'
        }

        let indigoIconColor = () => {
            showPasswordIcon.classList.add('text-indigo-400')
            hidePasswordIcon.classList.add('text-indigo-400')
        }

        let defaultIconColor = () => {
            showPasswordIcon.classList.remove('text-indigo-400')
            hidePasswordIcon.classList.remove('text-indigo-400')
        }

        inputField.addEventListener('focus', () => {
            if (inputField.value.length > 0) {
                indigoIconColor()
            }
        })

        inputField.addEventListener('blur', () => {
            defaultIconColor()
        })

        inputField.addEventListener('keyup', () => {
            if (inputField.value.length > 0) {
                indigoIconColor()
            } else {
                defaultIconColor()
            }
        })

        button.addEventListener('mousedown', (e) => {
            if (inputField.value.length > 0) {
                let type = inputField.getAttribute('type')
                inputField.setAttribute('type', type == 'password' ? 'text' : 'password')
                inputField.focus()
                indigoIconColor()
                showIcon()
            }

            e.preventDefault()
        })
    },
}

export default FormInputHooks
