#!/usr/bin/env bash
# Instala el tema beamer PUCV en el TEXMFHOME del usuario.
set -euo pipefail

cd "$(dirname "$0")"
make install
