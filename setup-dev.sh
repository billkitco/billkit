#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${1:-$(pwd)}"

FRONTEND_REPO="git@billkitco:billkitco/billkit-frontend.git"
BACKEND_REPO="git@billkitco:billkitco/billkit-backend.git"
BACKEND_ENV_REPO="git@billkitco:billkitco/billkit-backend-env.git"
FRONTEND_ENV_REPO="git@billkitco:billkitco/billkit-frontend-env.git"

clone_or_update() {
  local repo_url="$1"
  local target_dir="$2"

  if [[ -d "$target_dir/.git" ]]; then
    echo "Updating $target_dir"
    git -C "$target_dir" pull --ff-only
    return
  fi

  if [[ -e "$target_dir" ]]; then
    echo "Path exists but is not a git repo: $target_dir"
    return 1
  fi

  echo "Cloning $repo_url -> $target_dir"
  git clone "$repo_url" "$target_dir"
}

clone_env_repo() {
  local repo_url="$1"
  local target_dir="$2"

  echo "Cloning $repo_url -> $target_dir"
  git clone "$repo_url" "$target_dir"
}

copy_env_files() {
  local env_repo_dir="$1"
  local target_dir="$2"

  if [[ ! -d "$env_repo_dir" ]]; then
    return
  fi

  for env_file in .env .env.local .env.development .env.production; do
    if [[ -f "$env_repo_dir/$env_file" && ! -f "$target_dir/$env_file" ]]; then
      echo "Copying $env_file -> $target_dir"
      cp "$env_repo_dir/$env_file" "$target_dir/$env_file"
    fi
  done
}

echo "Using root: $ROOT_DIR"
mkdir -p "$ROOT_DIR"

clone_or_update "$FRONTEND_REPO" "$ROOT_DIR/frontend"
clone_or_update "$BACKEND_REPO" "$ROOT_DIR/backend"

ENV_WORKDIR="$(mktemp -d "${ROOT_DIR}/.env-repos.XXXXXX")"
cleanup_env_workdir() {
  rm -rf "$ENV_WORKDIR"
}
trap cleanup_env_workdir EXIT

clone_env_repo "$BACKEND_ENV_REPO" "$ENV_WORKDIR/backend-env"
clone_env_repo "$FRONTEND_ENV_REPO" "$ENV_WORKDIR/frontend-env"

copy_env_files "$ENV_WORKDIR/backend-env" "$ROOT_DIR/backend"
copy_env_files "$ENV_WORKDIR/frontend-env" "$ROOT_DIR/frontend"

if [[ -f "$ROOT_DIR/backend/requirements.txt" ]]; then
  if [[ ! -d "$ROOT_DIR/backend/env" ]]; then
    echo "Creating backend virtualenv"
    python3 -m venv "$ROOT_DIR/backend/env"
  fi
  echo "Installing backend dependencies"
  "$ROOT_DIR/backend/env/bin/pip" install -r "$ROOT_DIR/backend/requirements.txt"
fi

if [[ -f "$ROOT_DIR/frontend/package.json" ]]; then
  echo "Installing frontend dependencies"
  (cd "$ROOT_DIR/frontend" && npm install)
fi

echo "Done."
