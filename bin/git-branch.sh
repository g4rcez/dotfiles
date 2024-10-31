#!/usr/bin/env bash

echo "$(git -C "$1" rev-parse --abbrev-ref HEAD)"
