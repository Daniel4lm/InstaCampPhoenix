defmodule InstacampWeb.Components.CommingSoon do
  @moduledoc """
  Icons module render various icon components
  """
  use InstacampWeb, :component

  @type assigns :: map()
  @type render :: Phoenix.LiveView.Rendered.t()

  @spec message(assigns()) :: render()
  def message(assigns) do
    ~H"""
    <svg
      id="comming-soon-animation"
      xmlns="http://www.w3.org/2000/svg"
      height="300"
      viewBox="0 0 500 300"
      fill="none"
      id="general"
      style="opacity: 1;"
      class="dark:fill-slate-700 w-[300px] md:w-[500px]"
    >
      <g id="Frame 3">
        <g id="Group">
          <g id="working">
            <g id="lines_bg">
              <path
                id="line01"
                d="M457.63 201.279H47.6359"
                stroke="#ECECEC"
                stroke-width="34.3083"
                stroke-linecap="round"
              >
              </path>
              <path
                id="line02"
                d="M398.984 169.141H103.968"
                stroke="#ECECEC"
                stroke-width="34.3083"
                stroke-linecap="round"
              >
              </path>
              <path
                id="line03"
                d="M387.467 233.88H145.072"
                stroke="#ECECEC"
                stroke-width="34.3083"
                stroke-linecap="round"
              >
              </path>
              <path
                id="line04"
                d="M338.286 107.709H291.663"
                stroke="#ECECEC"
                stroke-width="34.3083"
                stroke-linecap="round"
              >
              </path>
              <path
                id="line05"
                d="M87.2574 244.963H55.9893"
                stroke="#ECECEC"
                stroke-width="34.3083"
                stroke-linecap="round"
              >
              </path>
            </g>
            <g id="Group 5.3">
              <path
                id="Stroke 2130"
                fill-rule="evenodd"
                clip-rule="evenodd"
                d="M110.316 201.431C110.316 205.577 113.468 208.942 117.361 208.942H149.065C152.957 208.942 156.11 205.577 156.11 201.431V160.118H110.316V201.431Z"
                fill="white"
                class="dark:fill-slate-700"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 2130.1"
                fill-rule="evenodd"
                clip-rule="evenodd"
                d="M110.316 204.63C110.316 207.01 113.468 208.943 117.361 208.943H149.065C152.957 208.943 156.11 207.01 156.11 204.63V180.909H110.316V204.63Z"
                fill="white"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
                class="dark:fill-slate-700"
              >
              </path>
              <path
                id="Stroke 2132"
                d="M121.583 160.118L111.784 142.516"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 2133"
                d="M107.909 143.806L114.072 160.121"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 2131"
                fill-rule="evenodd"
                clip-rule="evenodd"
                d="M110.765 122.803C106.889 128.715 112.631 131.956 113.968 135.129C115.384 138.487 114.006 141.709 110.645 143.125C99.753 147.715 96.5119 126.251 110.765 122.803Z"
                stroke="#8223D2"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 2134"
                fill-rule="evenodd"
                clip-rule="evenodd"
                d="M144.118 160.119H155.385L161.018 148.851L162.896 137.584L153.507 143.218L144.118 160.119V160.119Z"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 2135"
                d="M161.019 148.852L153.507 143.219"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 2136"
                fill-rule="evenodd"
                clip-rule="evenodd"
                d="M140.363 160.119H125.34V122.562H140.363V160.119Z"
                fill="white"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
                class="dark:fill-slate-700"
              >
              </path>
              <path
                id="Stroke 2137"
                d="M125.341 130.074H132.852"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 2138"
                d="M125.339 137.584H129.095"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 2139"
                d="M125.341 145.096H132.852"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 2140"
                d="M125.339 152.607H129.095"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
            </g>
            <g id="Group 5.4">
              <path
                id="Stroke 2129"
                d="M406.214 147.519H409.969C416.193 147.519 421.236 152.563 421.236 158.786C421.236 165.009 416.193 170.053 409.969 170.053H406.214"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 2130_2"
                fill-rule="evenodd"
                clip-rule="evenodd"
                d="M406.213 181.32C406.213 185.466 402.852 188.831 398.702 188.831H364.9C360.75 188.831 357.389 185.466 357.389 181.32V140.007H406.213V181.32Z"
                fill="white"
                class="dark:fill-slate-700"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
            </g>
            <g id="Group 31.2">
              <g id="Exclude">
                <path
                  fill-rule="evenodd"
                  clip-rule="evenodd"
                  d="M139.312 233.915L127.333 206.963L94.9356 221.363L139.312 233.915ZM62.2037 226.692L133.169 195.15L159.409 254.186L62.2037 226.692Z"
                  fill="white"
                  class="dark:fill-slate-700"
                  class="dark:fill-slate-700"
                >
                </path>
                <path
                  d="M139.312 233.915L138.728 235.978C139.528 236.204 140.387 235.947 140.932 235.319C141.477 234.69 141.609 233.804 141.271 233.044L139.312 233.915ZM127.333 206.963L129.292 206.092C128.811 205.01 127.544 204.523 126.462 205.004L127.333 206.963ZM94.9356 221.363L94.0647 219.403C93.2394 219.77 92.7324 220.615 92.7968 221.516C92.8611 222.416 93.483 223.18 94.352 223.426L94.9356 221.363ZM62.2037 226.692L61.3328 224.732C60.5076 225.099 60.0006 225.944 60.0649 226.844C60.1293 227.745 60.7511 228.509 61.6201 228.755L62.2037 226.692ZM133.169 195.15L135.128 194.279C134.647 193.197 133.38 192.709 132.298 193.19L133.169 195.15ZM159.409 254.186L158.825 256.249C159.625 256.475 160.484 256.219 161.029 255.59C161.574 254.962 161.706 254.075 161.368 253.315L159.409 254.186ZM141.271 233.044L129.292 206.092L125.373 207.834L137.352 234.785L141.271 233.044ZM126.462 205.004L94.0647 219.403L95.8065 223.322L128.204 208.923L126.462 205.004ZM94.352 223.426L138.728 235.978L139.895 231.851L95.5192 219.3L94.352 223.426ZM63.0747 228.651L134.04 197.109L132.298 193.19L61.3328 224.732L63.0747 228.651ZM131.209 196.021L157.449 255.057L161.368 253.315L135.128 194.279L131.209 196.021ZM159.992 252.122L62.7873 224.628L61.6201 228.755L158.825 256.249L159.992 252.122Z"
                  fill="currentColor"
                >
                </path>
              </g>
              <path
                id="Stroke 2116"
                d="M142.501 249.405L144.446 245.467"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 2117"
                d="M131.936 246.414L133.881 242.476"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 2118"
                d="M121.369 243.427L123.314 239.489"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 2119"
                d="M110.835 240.377L112.749 236.502"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 2120"
                d="M100.242 237.45L102.186 233.512"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 2121"
                d="M89.6728 234.462L91.6173 230.523"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 2122"
                d="M79.1085 231.474L81.0531 227.536"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
            </g>
            <g id="Group 908.3">
              <g id="Stroke 8340">
                <path
                  fill-rule="evenodd"
                  clip-rule="evenodd"
                  d="M190.51 243.834H171.76L186.76 183.834H329.26L344.26 243.834H325.51"
                  fill="white"
                  class="dark:fill-slate-700"
                >
                </path>
                <path
                  d="M190.51 243.834H171.76L186.76 183.834H329.26L344.26 243.834H325.51"
                  stroke="currentColor"
                  stroke-width="4.28854"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                >
                </path>
              </g>
              <path
                id="Stroke 8341"
                d="M246.757 243.837H269.257"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 8342"
                d="M198.008 198.835H205.508"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 8343"
                d="M209.258 213.835H216.758"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 8345"
                d="M254.256 213.835H261.756"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 8347"
                d="M299.262 213.835H306.762"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="btn"
                d="M220.51 198.835H228.01"
                stroke="rgba(205,25,25,1)"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 8349"
                d="M243.01 198.835H250.51"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 8350"
                d="M265.508 198.835H273.008"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 8351"
                d="M288.008 198.835H295.508"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 8352"
                d="M310.511 198.835H318.011"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 8353"
                d="M198.008 228.835H205.508"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 8354"
                d="M220.51 228.835H228.01"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 8355"
                d="M243.01 228.835H250.51"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 8356"
                d="M265.508 228.835H273.008"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 8357"
                d="M288.008 228.835H295.508"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <path
                id="Stroke 8358"
                d="M310.511 228.835H318.011"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </path>
              <g id="hands_group">
                <g id="hand1" style="transform: translateY(1px);">
                  <g id="hand1_w_line">
                    <g id="Stroke 8364">
                      <path
                        fill-rule="evenodd"
                        clip-rule="evenodd"
                        d="M199.177 235.205L201.582 226.091C202.445 223.046 200.69 219.858 197.63 218.988C194.577 218.118 191.397 219.881 190.52 222.941L180.005 259.796C177.087 269.981 182.99 280.586 193.167 283.481L205.46 286.998C211.76 288.798 218.555 287.246 223.467 282.881C232.662 274.713 245.247 260.486 245.247 260.486C246.987 259.083 247.475 256.631 246.387 254.673C245.217 252.573 242.63 251.733 240.44 252.723L227.382 261.363L237.912 224.508C238.782 221.463 237.012 218.268 233.96 217.398C230.9 216.528 227.727 218.298 226.85 221.343L222.579 235.886"
                        fill="white"
                        class="dark:fill-slate-700"
                      >
                      </path>
                      <path
                        d="M199.177 235.205L201.582 226.091C202.445 223.046 200.69 219.858 197.63 218.988C194.577 218.118 191.397 219.881 190.52 222.941L180.005 259.796C177.087 269.981 182.99 280.586 193.167 283.481L205.46 286.998C211.76 288.798 218.555 287.246 223.467 282.881C232.662 274.713 245.247 260.486 245.247 260.486C246.987 259.083 247.475 256.631 246.387 254.673C245.217 252.573 242.63 251.733 240.44 252.723L227.382 261.363L237.912 224.508C238.782 221.463 237.012 218.268 233.96 217.398C230.9 216.528 227.727 218.298 226.85 221.343L222.579 235.886"
                        stroke="white"
                        class="dark:fill-slate-700"
                        stroke-width="12.8656"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      >
                      </path>
                    </g>
                    <g id="Stroke 8362">
                      <path
                        fill-rule="evenodd"
                        clip-rule="evenodd"
                        d="M219.965 245.088L228.958 213.98C229.82 210.927 228.058 207.74 225.02 206.87C221.953 206 218.78 207.762 217.903 210.815L209.512 240.43"
                        fill="white"
                        class="dark:fill-slate-700"
                      >
                      </path>
                      <path
                        d="M219.965 245.088L228.958 213.98C229.82 210.927 228.058 207.74 225.02 206.87C221.953 206 218.78 207.762 217.903 210.815L209.512 240.43"
                        stroke="white"
                        class="dark:fill-slate-700"
                        stroke-width="12.8656"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      >
                      </path>
                    </g>
                    <g id="Stroke 8363">
                      <path
                        fill-rule="evenodd"
                        clip-rule="evenodd"
                        d="M209.4 240.771L215.797 218.2C216.667 215.147 214.897 211.96 211.845 211.09C208.785 210.212 205.605 211.99 204.727 215.035L196.676 243.044"
                        fill="white"
                        class="dark:fill-slate-700"
                      >
                      </path>
                      <path
                        d="M209.4 240.771L215.797 218.2C216.667 215.147 214.897 211.96 211.845 211.09C208.785 210.212 205.605 211.99 204.727 215.035L196.676 243.044"
                        stroke="white"
                        class="dark:fill-slate-700"
                        stroke-width="12.8656"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      >
                      </path>
                    </g>
                  </g>
                  <g id="hand1_line">
                    <g id="Stroke 8364_2">
                      <path
                        fill-rule="evenodd"
                        clip-rule="evenodd"
                        d="M199.177 235.205L201.582 226.091C202.445 223.046 200.69 219.858 197.63 218.988C194.577 218.118 191.397 219.881 190.52 222.941L180.005 259.796C177.087 269.981 182.99 280.586 193.167 283.481L205.46 286.998C211.76 288.798 218.555 287.246 223.467 282.881C232.662 274.713 245.247 260.486 245.247 260.486C246.987 259.083 247.475 256.631 246.387 254.673C245.217 252.573 242.63 251.733 240.44 252.723L227.382 261.363L237.912 224.508C238.782 221.463 237.012 218.268 233.96 217.398C230.9 216.528 227.727 218.298 226.85 221.343L222.579 235.886"
                        fill="white"
                        class="dark:fill-slate-700"
                      >
                      </path>
                      <path
                        d="M199.177 235.205L201.582 226.091C202.445 223.046 200.69 219.858 197.63 218.988C194.577 218.118 191.397 219.881 190.52 222.941L180.005 259.796C177.087 269.981 182.99 280.586 193.167 283.481L205.46 286.998C211.76 288.798 218.555 287.246 223.467 282.881C232.662 274.713 245.247 260.486 245.247 260.486C246.987 259.083 247.475 256.631 246.387 254.673C245.217 252.573 242.63 251.733 240.44 252.723L227.382 261.363L237.912 224.508C238.782 221.463 237.012 218.268 233.96 217.398C230.9 216.528 227.727 218.298 226.85 221.343L222.579 235.886"
                        stroke="currentColor"
                        stroke-width="4.28854"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      >
                      </path>
                    </g>
                    <g id="Stroke 8362_2">
                      <path
                        fill-rule="evenodd"
                        clip-rule="evenodd"
                        d="M219.965 245.088L228.958 213.98C229.82 210.927 228.058 207.74 225.02 206.87C221.953 206 218.78 207.762 217.903 210.815L209.512 240.43"
                        fill="white"
                        class="dark:fill-slate-700"
                      >
                      </path>
                      <path
                        d="M219.965 245.088L228.958 213.98C229.82 210.927 228.058 207.74 225.02 206.87C221.953 206 218.78 207.762 217.903 210.815L209.512 240.43"
                        stroke="currentColor"
                        stroke-width="4.28854"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      >
                      </path>
                    </g>
                    <g id="Stroke 8363_2">
                      <path
                        fill-rule="evenodd"
                        clip-rule="evenodd"
                        d="M209.4 240.771L215.797 218.2C216.667 215.147 214.897 211.96 211.845 211.09C208.785 210.212 205.605 211.99 204.727 215.035L196.676 243.044"
                        fill="white"
                        class="dark:fill-slate-700"
                      >
                      </path>
                      <path
                        d="M209.4 240.771L215.797 218.2C216.667 215.147 214.897 211.96 211.845 211.09C208.785 210.212 205.605 211.99 204.727 215.035L196.676 243.044"
                        stroke="currentColor"
                        stroke-width="4.28854"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      >
                      </path>
                    </g>
                  </g>
                </g>
                <g id="hand2">
                  <g id="hand2_w_line">
                    <g id="Stroke 8364_3">
                      <path
                        fill-rule="evenodd"
                        clip-rule="evenodd"
                        d="M317.107 235.205L314.701 226.091C313.839 223.046 315.594 219.858 318.654 218.988C321.706 218.118 324.886 219.881 325.764 222.941L336.279 259.796C339.196 269.981 333.294 280.586 323.116 283.481L310.824 286.999C304.524 288.799 297.729 287.246 292.816 282.881C283.621 274.714 271.036 260.486 271.036 260.486C269.296 259.084 268.809 256.631 269.896 254.674C271.066 252.574 273.654 251.734 275.844 252.724L288.901 261.364L278.371 224.508C277.501 221.463 279.271 218.268 282.324 217.398C285.384 216.528 288.556 218.298 289.434 221.343L293.704 235.886"
                        fill="white"
                        class="dark:fill-slate-700"
                      >
                      </path>
                      <path
                        d="M317.107 235.205L314.701 226.091C313.839 223.046 315.594 219.858 318.654 218.988C321.706 218.118 324.886 219.881 325.764 222.941L336.279 259.796C339.196 269.981 333.294 280.586 323.116 283.481L310.824 286.999C304.524 288.799 297.729 287.246 292.816 282.881C283.621 274.714 271.036 260.486 271.036 260.486C269.296 259.084 268.809 256.631 269.896 254.674C271.066 252.574 273.654 251.734 275.844 252.724L288.901 261.364L278.371 224.508C277.501 221.463 279.271 218.268 282.324 217.398C285.384 216.528 288.556 218.298 289.434 221.343L293.704 235.886"
                        stroke="white"
                        class="dark:fill-slate-700"
                        stroke-width="12.8656"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      >
                      </path>
                    </g>
                    <g id="Stroke 8362_3">
                      <path
                        fill-rule="evenodd"
                        clip-rule="evenodd"
                        d="M296.319 245.088L287.326 213.98C286.463 210.928 288.226 207.74 291.263 206.87C294.331 206 297.503 207.763 298.381 210.815L306.771 240.43"
                        fill="white"
                        class="dark:fill-slate-700"
                      >
                      </path>
                      <path
                        d="M296.319 245.088L287.326 213.98C286.463 210.928 288.226 207.74 291.263 206.87C294.331 206 297.503 207.763 298.381 210.815L306.771 240.43"
                        stroke="white"
                        class="dark:fill-slate-700"
                        stroke-width="12.8656"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      >
                      </path>
                    </g>
                    <g id="Stroke 8363_3">
                      <path
                        fill-rule="evenodd"
                        clip-rule="evenodd"
                        d="M306.883 240.772L300.486 218.2C299.616 215.148 301.386 211.96 304.439 211.09C307.499 210.213 310.679 211.99 311.556 215.035L319.607 243.044"
                        fill="white"
                        class="dark:fill-slate-700"
                      >
                      </path>
                      <path
                        d="M306.883 240.772L300.486 218.2C299.616 215.148 301.386 211.96 304.439 211.09C307.499 210.213 310.679 211.99 311.556 215.035L319.607 243.044"
                        stroke="white"
                        class="dark:fill-slate-700"
                        stroke-width="12.8656"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      >
                      </path>
                    </g>
                  </g>
                  <g id="hand2_line">
                    <g id="Stroke 8364_4">
                      <path
                        fill-rule="evenodd"
                        clip-rule="evenodd"
                        d="M317.107 235.205L314.701 226.091C313.839 223.046 315.594 219.858 318.654 218.988C321.706 218.118 324.886 219.881 325.764 222.941L336.279 259.796C339.196 269.981 333.294 280.586 323.116 283.481L310.824 286.999C304.524 288.799 297.729 287.246 292.816 282.881C283.621 274.714 271.036 260.486 271.036 260.486C269.296 259.084 268.809 256.631 269.896 254.674C271.066 252.574 273.654 251.734 275.844 252.724L288.901 261.364L278.371 224.508C277.501 221.463 279.271 218.268 282.324 217.398C285.384 216.528 288.556 218.298 289.434 221.343L293.704 235.886"
                        fill="white"
                        class="dark:fill-slate-700"
                      >
                      </path>
                      <path
                        d="M317.107 235.205L314.701 226.091C313.839 223.046 315.594 219.858 318.654 218.988C321.706 218.118 324.886 219.881 325.764 222.941L336.279 259.796C339.196 269.981 333.294 280.586 323.116 283.481L310.824 286.999C304.524 288.799 297.729 287.246 292.816 282.881C283.621 274.714 271.036 260.486 271.036 260.486C269.296 259.084 268.809 256.631 269.896 254.674C271.066 252.574 273.654 251.734 275.844 252.724L288.901 261.364L278.371 224.508C277.501 221.463 279.271 218.268 282.324 217.398C285.384 216.528 288.556 218.298 289.434 221.343L293.704 235.886"
                        stroke="currentColor"
                        stroke-width="4.28854"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      >
                      </path>
                    </g>
                    <g id="Stroke 8362_4">
                      <path
                        fill-rule="evenodd"
                        clip-rule="evenodd"
                        d="M296.319 245.088L287.326 213.98C286.463 210.928 288.226 207.74 291.263 206.87C294.331 206 297.503 207.763 298.381 210.815L306.771 240.43"
                        fill="white"
                        class="dark:fill-slate-700"
                      >
                      </path>
                      <path
                        d="M296.319 245.088L287.326 213.98C286.463 210.928 288.226 207.74 291.263 206.87C294.331 206 297.503 207.763 298.381 210.815L306.771 240.43"
                        stroke="currentColor"
                        stroke-width="4.28854"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      >
                      </path>
                    </g>
                    <g id="Stroke 8363_4">
                      <path
                        fill-rule="evenodd"
                        clip-rule="evenodd"
                        d="M306.883 240.772L300.486 218.2C299.616 215.148 301.386 211.96 304.439 211.09C307.499 210.213 310.679 211.99 311.556 215.035L319.607 243.044"
                        fill="white"
                        class="dark:fill-slate-700"
                      >
                      </path>
                      <path
                        d="M306.883 240.772L300.486 218.2C299.616 215.148 301.386 211.96 304.439 211.09C307.499 210.213 310.679 211.99 311.556 215.035L319.607 243.044"
                        stroke="currentColor"
                        stroke-width="4.28854"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      >
                      </path>
                    </g>
                  </g>
                </g>
              </g>
            </g>
            <g id="Rectangle 3.1">
              <mask id="path-71-inside-1" fill="white">
                <rect x="184.702" y="101" width="146.078" height="85.1007" rx="2.14427"></rect>
              </mask>
              <rect
                x="184.702"
                y="101"
                width="146.078"
                height="85.1007"
                rx="2.14427"
                fill="white"
                class="dark:fill-slate-700"
                stroke="currentColor"
                stroke-width="8.57707"
                stroke-linecap="round"
                mask="url(#path-71-inside-1)"
              >
              </rect>
            </g>
            <g id="smoke_group">
              <path
                id="smoke_b"
                d="M369.541 126.981C349.59 107.03 389.354 100.24 369.817 80.7027"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
                style="opacity: 1;"
              >
              </path>
            </g>
            <g id="smoke_group2">
              <path
                id="smoke_b2"
                d="M386.766 111.972C406.717 92.0212 366.953 85.2306 386.49 65.6936"
                stroke="currentColor"
                stroke-width="4.28854"
                stroke-linecap="round"
                stroke-linejoin="round"
                style="opacity: 1; "
              >
              </path>
            </g>
          </g>
        </g>
      </g>
    </svg>
    """
  end
end
