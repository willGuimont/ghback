defmodule Ghback do
  @moduledoc """
  ghback, the CLI tool to backup GitHub repositories locally.
  """

  @doc """
  ghback entrypoint
  """
  def start(_type, _args) do
    backup_path_env = "GHBACKUP_PATH"
    backup_path = System.get_env(backup_path_env)

    if backup_path == nil do
      IO.puts("Environment variable #{backup_path_env}} was not set")
      IO.puts("Exiting")
      System.halt()
    end

    # TODO handle failure
    {:ok, file_content} = File.read("gh.secret")
    token = String.trim(file_content)
    api = Github.new(token)

    {:ok, username} = Github.get_username(api)
    IO.puts("Will backup repositories into #{backup_path} for user #{username}}")

    list_all_repos(api)
    |> Stream.map(fn r -> Task.async(fn -> clone_repo(r) end) end)
    |> Stream.map(&Task.await/1)

    Supervisor.start_link([], strategy: :one_for_one)
  end

  defp list_all_repos(api) do
    #    list_all_repo_go(api, 1, [], [])
    Stream.transform(
      Stream.iterate(1, &(&1 + 1)),
      1,
      fn page, acc ->
        nil
      end
    )
  end

  defp list_all_repo_go(_api, page, [], urls) when page != 1 do
    urls
  end

  defp list_all_repo_go(api, page, new_urls, urls) do
    {:ok, new} = Github.list_repositories(api, page)
    IO.inspect(length(new))
    IO.inspect(List.last(new)["name"])
    list_all_repo_go(api, page + 1, new, new_urls ++ urls)
  end

  defp clone_repo(repo) do
    # TODO handle failure
    {:ok, ssh_url} = Map.fetch(repo, "ssh_url")

    if repo["owner"]["login"] == "willGuimont" do
      IO.puts(ssh_url)
    end
  end
end
