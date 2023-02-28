defmodule Instacamp.MixProject do
  use Mix.Project

  def project do
    [
      app: :instacamp,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs",
        plt_add_apps: [:ex_unit, :mix, :wallaby],
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],
      preferred_cli_env: [
        ci: :test,
        "ci.code_quality": :test,
        "ci.deps": :test,
        "ci.formatting": :test,
        "ci.migrations": :test,
        "ci.security": :test,
        "ci.test": :test,
        "cover.full": :test,
        "cover.full_html": :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        credo: :test,
        dialyzer: :test,
        sobelow: :test,
        "test.full": :test,
        "test.prepare": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Instacamp.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:phoenix, "~> 1.6.15"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.17.5"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:excoveralls, "~> 0.14", only: [:dev, :test]},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.8", only: [:dev, :test], runtime: false},
      {:tailwind, "~> 0.1.8", runtime: Mix.env() == :dev},
      {:timex, "~> 3.7"},
      {:wallaby, "~> 0.30", runtime: false, only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": [
        "ecto.create",
        "ecto.migrate",
        "run priv/repo/seeds.exs",
        "run priv/repo/seeds.dev.exs"
      ],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
      ci: [
        "ci.deps_and_security",
        "ci.formatting",
        "ci.code_quality",
        "ci.test"
        # "ci.migrations"
      ],
      "ci.code_quality": [
        "compile --force --warnings-as-errors",
        "credo --strict",
        "dialyzer"
      ],
      "ci.deps_and_security": [
        "deps.unlock --check-unused",
        "hex.audit"
        # "sobelow --config .sobelow-conf"
      ],
      "ci.formatting": ["format --check-formatted"],
      "ci.test": ["cover.full"],
      "cover.full": [
        "test.prepare",
        "coveralls"
      ],
      "cover.full_html": [
        "test.prepare",
        "coveralls.html"
      ],
      "test.prepare": [
        "ecto.create --quiet",
        "ecto.migrate --quiet"
      ]
    ]
  end
end
