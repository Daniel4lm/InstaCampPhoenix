// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const colors = require('tailwindcss/colors')
const defaultTheme = require('tailwindcss/defaultTheme');
let plugin = require('tailwindcss/plugin')

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex'
  ],
  darkMode: 'class',
  theme: {
    extend: {
      animation: {
        'show-tab-line': 'show-tab-line 0.4s ease-in-out forwards',
      },
      backgroundImage: {
        'search-icon': "url('../images/search.svg')",
        'search-icon-dark': "url('../images/search-dark.svg')",
      },
      fontFamily: {
        ubuntu: ['Ubuntu', ...defaultTheme.fontFamily.sans],
        nunitoSans: ['Nunito Sans', ...defaultTheme.fontFamily.sans],
        ptSans: ['PT Sans', ...defaultTheme.fontFamily.sans],
        quickSand: ['Quicksand', ...defaultTheme.fontFamily.sans],
        roboto: ['Roboto', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        'light-blue': colors.sky,
        cyan: colors.cyan,
        'main-background': "#fafafa"
      },
    },
  },
  variants: {
    extend: {
      borderWidth: ['hover'],
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    plugin(({ addVariant }) => addVariant('phx-no-feedback', ['&.phx-no-feedback', '.phx-no-feedback &'])),
    plugin(({ addVariant }) => addVariant('phx-click-loading', ['&.phx-click-loading', '.phx-click-loading &'])),
    plugin(({ addVariant }) => addVariant('phx-submit-loading', ['&.phx-submit-loading', '.phx-submit-loading &'])),
    plugin(({ addVariant }) => addVariant('phx-change-loading', ['&.phx-change-loading', '.phx-change-loading &']))
  ]
}
