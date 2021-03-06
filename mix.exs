defmodule OneSignal.Mixfile do
  use Mix.Project

  @description "Elixir wrapper of OneSignal"

  def project do
    [
      app: :one_signal,
      version: "0.0.9",
      elixir: "~> 1.2",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: @description,
      package: package(),
      xref: [exclude: Jason]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application() do
    [extra_applications: [:logger]]
  end

  defp package() do
    [
      maintainers: ["Takuma Yoshida"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/yoavlt/one_signal"}
    ]
  end

  defp deps() do
    [
      {:jason, "~> 1.1", optional: true},
      {:httpoison, "~> 1.8", optional: true},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:hammox, "~> 0.5", only: :test}
    ]
  end
end
