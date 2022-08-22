defmodule Github do
  defstruct [:token, base_url: "https://api.github.com"]

  def new(token) do
    %Github{token: token}
  end

  defp headers(api) do
    [
      {:Authorization, "token #{api.token}"},
      {:"Content-Type", "application/vnd.github+json"}
    ]
  end

  def get_username(api) do
    url = api.base_url <> "/user"

    with {:ok, response} <- HTTPoison.get(url, headers(api)),
         {:ok, decoded} <- Poison.decode(response.body) do
      {:ok, decoded["login"]}
    end
  end

  def list_repositories(api, page) do
    url = api.base_url <> "/user/repos?per_page=30&page=#{page}"

    with {:ok, response} <- HTTPoison.get(url, headers(api)),
         {:ok, decoded} <- Poison.decode(response.body) do
      {:ok, decoded}
    end
  end
end
