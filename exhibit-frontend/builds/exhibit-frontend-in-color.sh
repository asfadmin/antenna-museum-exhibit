#!/bin/sh
echo -ne '\033c\033]0;exhibit-frontend\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/exhibit-frontend-in-color.arm64" "$@"
