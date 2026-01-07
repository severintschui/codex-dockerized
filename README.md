# Dockerized Codex CLI

The `codex-docker.sh` script starts an interactive Codex session with access only to the current folder, which is mounted as a volume upon starting the container.

## Arguments

- `-p`, `--project`
  
  Project folder to be mounted into the container. Defaults to current working directory.

- `-c`, `--config`
  
  Configuration folder mounted into the container. Defaults to `$HOME/.codex`.

- `-f`, `--force-build`
  
  Forces a rebuild of the Docker image. This can be used to update the installed Codex CLI package.

- `-h`, `--help`
  
  Prints a description and usage examples.

- `-v`, `--version`
  
  Prints the current version of the script.

- `--` + codex args
  
  Arguments after `--` are forwarded to the Codex CLI.
