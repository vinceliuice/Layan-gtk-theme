#!/bin/bash
set -ueo pipefail

if [ ! "$(which sassc 2> /dev/null)" ]; then
  echo sassc needs to be installed to generate the css.
  exit 1
fi

_COLOR_VARIANTS=('' '-dark' '-light')
if [ ! -z "${COLOR_VARIANTS:-}" ]; then
  IFS=', ' read -r -a _COLOR_VARIANTS <<< "${COLOR_VARIANTS:-}"
fi

_SOLID_VARIANTS=('' '-solid')
if [ ! -z "${SOLID_VARIANTS:-}" ]; then
  IFS=', ' read -r -a _SOLID_VARIANTS <<< "${SOLID_VARIANTS:-}"
fi

SASSC_OPT="-M -t expanded"

for color in "${_COLOR_VARIANTS[@]}"; do
  for solid in "${_SOLID_VARIANTS[@]}"; do
    sassc $SASSC_OPT src/gtk/gtk${color}${solid}.{scss,css}
    echo ">> generating gtk${color}${solid}.css."
  done
done

sassc $SASSC_OPT src/gnome-shell/shell-3-36/gnome-shell.{scss,css}
echo ">> generating 3-36 gnome-shell.css."
sassc $SASSC_OPT src/gnome-shell/shell-3-36/gnome-shell-dark.{scss,css}
echo ">> generating 3-36 gnome-shell-dark.css."
sassc $SASSC_OPT src/gnome-shell/shell-40-0/gnome-shell.{scss,css}
echo ">> generating 40-0 gnome-shell.css."
sassc $SASSC_OPT src/gnome-shell/shell-40-0/gnome-shell-dark.{scss,css}
echo ">> generating 40-0 gnome-shell-dark.css."
