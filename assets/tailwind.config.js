// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const colors = require('tailwindcss/colors')
const defaultTheme = require('tailwindcss/defaultTheme');
const fs = require("fs")
const path = require("path")
const plugin = require('tailwindcss/plugin')

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
        'search-icon': "url('/images/search.svg')",
        'search-icon-dark': "url('/images/search-dark.svg')",
      },
      boxShadow: {
        'card-shadow': '0px 0px 4px 0px rgb(219, 223, 227)',
        'card-shadow-hover': '0px 0px 6px 2px rgb(210, 209, 209)',
      },
      fontFamily: {
        sans: ['Inter', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        'light-blue': colors.sky,
        cyan: colors.cyan,
        'main-background': "#fafafa",
        gray: {
          250: "#dbdfe3",
        },
      },
      screens: {
        xs: '450px'
      },
      zIndex: {
        '60': '100',
        '70': '100',
        '80': '100',
        '90': '100',
        '100': '100'
      }
    },
  },
  variants: {
    extend: {
      borderWidth: ['hover'],
    }
  },
  plugins: [
    require("@tailwindcss/forms"),
    require('@tailwindcss/line-clamp'),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({ addVariant }) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Hero Icons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function ({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "./vendor/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).map(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) }
        })
      })
      matchComponents({
        "hero": ({ name, fullPath }) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": theme("spacing.5"),
            "height": theme("spacing.5")
          }
        }
      }, { values })
    })
  ]
}
