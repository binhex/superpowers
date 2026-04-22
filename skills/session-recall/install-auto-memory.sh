#!/usr/bin/env bash
# Installs auto-memory (session-recall CLI) from PyPI using the best available
# package manager: uv > pipx > pip. Handles PATH fixup for ~/.local/bin.
set -euo pipefail

readonly PACKAGE="auto-memory"
readonly BIN_NAME="session-recall"
readonly LOCAL_BIN="${HOME}/.local/bin"

# Adds ~/.local/bin to PATH for this script's lifetime and prints a reminder
# if it was not already present.
ensure_local_bin_on_path() {
  case ":${PATH}:" in
    *":${LOCAL_BIN}:"*) ;;
    *)
      export PATH="${LOCAL_BIN}:${PATH}"
      echo "NOTE: Add the following to your shell profile (~/.bashrc or ~/.zshrc):"
      echo "  export PATH=\"\${HOME}/.local/bin:\${PATH}\""
      ;;
  esac
}

install_with_uv() {
  echo "Installing ${PACKAGE} with uv..."
  uv tool install "${PACKAGE}"
}

install_with_pipx() {
  echo "Installing ${PACKAGE} with pipx..."
  pipx install "${PACKAGE}"
}

install_with_pip() {
  echo "Installing ${PACKAGE} with pip..."
  python3 -m pip install --user "${PACKAGE}"
}

main() {
  if command -v "${BIN_NAME}" &>/dev/null; then
    echo "${BIN_NAME} is already installed at: $(command -v "${BIN_NAME}")"
    "${BIN_NAME}" schema-check
    exit 0
  fi

  if command -v uv &>/dev/null; then
    install_with_uv
  elif command -v pipx &>/dev/null; then
    install_with_pipx
  elif command -v pip3 &>/dev/null || command -v pip &>/dev/null; then
    install_with_pip
  else
    echo "ERROR: No supported package manager found (uv, pipx, or pip)." >&2
    echo "Install one of them and re-run this script." >&2
    exit 1
  fi

  ensure_local_bin_on_path

  if ! command -v "${BIN_NAME}" &>/dev/null; then
    echo "ERROR: Installation succeeded but '${BIN_NAME}' is still not on PATH." >&2
    echo "Ensure '${LOCAL_BIN}' is in your PATH and restart your shell." >&2
    exit 1
  fi

  echo "Verifying install..."
  "${BIN_NAME}" schema-check
  echo "auto-memory installed and schema check passed."
}

main "$@"
