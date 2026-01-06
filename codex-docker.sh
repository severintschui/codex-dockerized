#!/bin/bash

IMAGE="codex-cli:local"
VERSION="0.0.1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PROJECT_DIR="${PWD}"
CODEX_CONFIG_DIR="${HOME}/.codex"
BUILD_IMAGE=0

usage() {
    cat <<"EOF"
Starts an interactive codex session with access only to the current folder (default) or a specified path. Configuration and authentication is shared with the local codex installation.

Usage:
    codex-docker.sh [-c/--config /path/to/.codex] [-p/--project /path/to/project] [-f/--force-build] [-v/--version] [-- codex args...]

Examples:
    ./codex-docker.sh
    ./codex-docker.sh --project ~/src/myrepo
    ./codex-docker.sh --config ~/.codex -- chat "Explain this repo"
    ./codex-docker.sh -- chat "Explain this repo"
EOF
}

choose_container_name() {
    local base="codex-cli"
    local i=1
    local name=

    while :; do
        name="${base}-${i}"
        if ! docker ps -a --format '{{.Names}}' | grep -Fxq "${name}"; then
            echo "${name}"
            return
        fi
        i=$((i + 1))
    done
}

# parse args
CODEx_ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--version)
            echo "${VERSION}"
            exit 0
            ;;
        -c|--config)
            [[ $# -ge 2 ]] || { echo "Error: -c/--config requires a path"; usage; exit 2; }
            CODEX_CONFIG_DIR="$2"
            shift 2
            ;;
        -p|--project)
            [[ $# -ge 2 ]] || { echo "Error: -p/--project requires a path"; usage; exit 2; }
            PROJECT_DIR="$2"
            shift 2
            ;;
        -f|--force-build)
            BUILD_IMAGE=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            CODEx_ARGS+=("$@")
            break
            ;;
        -*)
            echo "Error: unknown option: $1" >&2
            usage
            exit 2
            ;;
        *)
            echo "Error: unexpected argument: $1" >&2
            echo "Tip: pass codex arguments after -- (example: $0 -- chat \"... \")" >&2
            usage
            exit 2
            ;;
    esac
done

# Validate project dir
if [[ ! -d "${PROJECT_DIR}" ]]; then
    echo "Error: project directory does not exist: ${PROJECT_DIR}" >&2
    exit 2
fi

# Validate config dir
if [[ ! -d "${CODEX_CONFIG_DIR}" ]]; then
    echo "Config dir not found: ${CODEX_CONFIG_DIR}" >&2
    exit 1
fi

# Normalize paths
PROJECT_DIR="$(cd "${PROJECT_DIR}" && pwd)"
CODEX_CONFIG_DIR="$(cd "${CODEX_CONFIG_DIR}" && pwd)"


# Check whether image exists, build if not
if [[ "${BUILD_IMAGE}" -eq 1 ]] || ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
    echo "Docker image '${IMAGE}' not found. Building..."
    docker build -t "${IMAGE}" "${SCRIPT_DIR}"
fi


CONTAINER_NAME="$(choose_container_name)"

# Run container
# Assumes your Dockerfile creates user 'nonroot' with home /home/nonroot.
# If you change that in the Dockerfile, update the mount target below.
docker run --rm -it \
    --name ${CONTAINER_NAME} \
    -v "${PROJECT_DIR}:/workspace:rw" \
    -v "${CODEX_CONFIG_DIR}:/home/nonroot/.codex:rw" \
    -w /workspace \
    "${IMAGE}" "${CODEx_ARGS[@]}"
