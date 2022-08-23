# ghback

Backup GitHub repositories locally.

## Running

1. Create a [new personal access token](https://github.com/settings/tokens/new) with `repo` scope;
2. Create `gh.secret` and put your token inside;
3. Set `GHBACKUP_PATH` env variable to set the backup path;
4. `mix run`

## Docker

Make a ssh key to clone the repositories in the `ssh_keys` folder.

```shell
ssh-keygen -t ed25519 -C "your_email@example.com" -f ./ssh_keys/id_ed25519 -q -N ""
```

Add the key to your GitHub account.

Build and run the docker with:

```shell
docker build -t ghback .
docker run -d --rm -v <path/to/backup>:/usr/app/backup ghback
```
