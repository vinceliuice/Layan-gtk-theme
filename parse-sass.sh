#!/bin/bash
set -ueo pipefail

if [ ! "$(which sassc 2> /dev/null)" ]; then
  echo sassc needs to be installed to generate the css.
  exit 1
fi

_COLOR_VARIANTS=('-dark' '-light')
if [ ! -z "${COLOR_VARIANTS:-}" ]; then
  IFS=', ' read -r -a _COLOR_VARIANTS <<< "${COLOR_VARIANTS:-}"
fi

SASSC_OPT="-M -t expanded"

for color in "${_COLOR_VARIANTS[@]}"; do
    sassc $SASSC_OPT src/gtk/gtk${color}.{scss,css}
    echo ">> generating gtk${color}.css."
    sassc $SASSC_OPT src/gnome-shell/gnome-shell${color}.{scss,css}
    echo ">> generating gnome-shell${color}.css."
done

