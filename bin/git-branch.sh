#!/usr/bin/env bash

WITH_ICON=""

if [[ "${2}" == "icon" ]]; then
    WITH_ICON=" "
fi

echo -n "${WITH_ICON}$(git -C "$1" rev-parse --abbrev-ref HEAD)"
