#!/bin/bash

if [ ! "$(which sassc 2> /dev/null)" ]; then
  echo sassc needs to be installed to generate the css.
  exit 1
fi

SASSC_OPT="-M -t expanded"

for color in '' '-Light' '-Dark'; do
  for solid in '' '-Solid'; do
    sassc $SASSC_OPT src/gtk/3.0/gtk${color}${solid}.{scss,css}
    echo ">> generating 3.0 gtk${color}${solid}.css."
    sassc $SASSC_OPT src/gtk/4.0/gtk${color}${solid}.{scss,css}
    echo ">> generating 4.0 gtk${color}${solid}.css."
  done
done

for color in '' '-Dark'; do
  for shell in '3-36' '40-0' '42-0' '44-0'; do
    echo ">> generating ${shell} gnome-shell${color}.css."
    sassc $SASSC_OPT src/gnome-shell/shell-${shell}/gnome-shell${color}.{scss,css}
  done
done
