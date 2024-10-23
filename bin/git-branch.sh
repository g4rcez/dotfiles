#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo $(git -C "$1" rev-parse --abbrev-ref HEAD)
