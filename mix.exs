defmodule CryptopiaApi.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cryptopia_api,
      version: "0.2.5",
      elixir: "~> 1.3",
      description: "Elixir wrapped cryptopia API",
      docs: [extras: ["README.md"]],
      deps: deps(),
      package: package(),
      source_url: "https://github.com/konstantinzolotarev/cryptopia_api"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:httpoison]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.1"},
      {:ex_doc, "~> 0.14", only: :dev}
    ]
  end

  defp package do
    [ maintainers: ["Konstantin Zolotarev"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/konstantinzolotarev/cryptopia_api"} ]
  end
end
