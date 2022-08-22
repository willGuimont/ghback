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
      IO.puts("Environment variable #{backup_path_env} was not set")
      IO.puts("Exiting")
      System.halt()
    end

    # TODO handle failure
    {err, file_content} = File.read("gh.secret")

    if err == :error do
      IO.puts("Could not find gh.secret")
      IO.puts("Exiting")
      System.halt()
    end

    token = String.trim(file_content)
    api = Github.new(token)

    {:ok, username} = Github.get_username(api)
    IO.puts("Will backup repositories from user #{username} into #{backup_path}")

    list_all_repos(api)
    |> Stream.map(&Task.async(fn -> clone_repo(&1, username, backup_path) end))
    |> Enum.to_list()
    |> Enum.map(&Task.await(&1, :infinity))

    Supervisor.start_link([], strategy: :one_for_one)
  end

  defp list_all_repos(api) do
    Stream.transform(
      Stream.iterate(1, &(&1 + 1)),
      1,
      fn page, _ ->
        case Github.list_repositories(api, page) do
          {:ok, urls} when urls != [] -> {urls, page + 1}
          _ -> {:halt, page}
        end
      end
    )
  end

  defp clone_repo(repo, username, backup_path) do
    {:ok, ssh_url} = Map.fetch(repo, "ssh_url")
    {:ok, name} = Map.fetch(repo, "name")

    if repo["owner"]["login"] == username do
      "cd #{backup_path} && git clone #{ssh_url}" |> String.to_charlist() |> :os.cmd()
      "cd #{backup_path}/#{name} && git pull" |> String.to_charlist() |> :os.cmd()
    end
  end
end
