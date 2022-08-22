# ghback

Backup GitHub repositories locally.

## Running

1. Create a [new personal access token](https://github.com/settings/tokens/new) with `repo` scope;
2. Create `gh.secret` and put your token inside;
3. Set `GHBACKUP_PATH` env variable to set the backup path;
4. `mix run`
