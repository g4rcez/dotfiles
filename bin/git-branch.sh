#!/usr/bin/env bash

echo -n "$(git -C "$1" rev-parse --abbrev-ref HEAD)"
