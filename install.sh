#! /usr/bin/env bash

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/themes"
else
  DEST_DIR="$HOME/.themes"
fi

SRC_DIR=$(cd $(dirname $0) && pwd)

THEME_NAME=Layan
COLOR_VARIANTS=('' '-light' '-dark')
SOLID_VARIANTS=('' '-solid')

if [[ "$(command -v gnome-shell)" ]]; then
  SHELL_VERSION="$(gnome-shell --version | cut -d ' ' -f 3 | cut -d . -f -1)"
  if [[ "${SHELL_VERSION:-}" -ge "40" ]]; then
    GS_VERSION="new"
  else
    GS_VERSION="old"
  fi
  else
    echo "'gnome-shell' not found, using styles for last gnome-shell version available."
    GS_VERSION="new"
fi

usage() {
  printf "%s\n" "Usage: $0 [OPTIONS...]"
  printf "\n%s\n" "OPTIONS:"
  printf "  %-25s%s\n" "-d, --dest DIR" "Specify theme destination directory (Default: ${DEST_DIR})"
  printf "  %-25s%s\n" "-n, --name NAME" "Specify theme name (Default: ${THEME_NAME})"
  printf "  %-25s%s\n" "-c, --color VARIANTS" "Specify theme color variant(s) [standard|light|dark] (Default: All variants)"
  printf "  %-25s%s\n" "-s, --solid VARIANTS" "Specify theme solid variant(s) [standard|solid] (Default: All variants)"
  printf "  %-25s%s\n" "-h, --help" "Show this help"
}

install() {
  local dest=${1}
  local name=${2}
  local color=${3}
  local solid=${4}

  [[ ${color} == '-dark' ]] && local ELSE_DARK=${color}
  [[ ${color} == '-light' ]] && local ELSE_LIGHT=${color}

  local THEME_DIR=${dest}/${name}${color}${solid}

  [[ -d ${THEME_DIR} ]] && rm -rf ${THEME_DIR}

  echo "Installing '${THEME_DIR}'..."

  mkdir -p                                                                           ${THEME_DIR}
  cp -ur ${SRC_DIR}/COPYING                                                          ${THEME_DIR}
  cp -ur ${SRC_DIR}/AUTHORS                                                          ${THEME_DIR}

  echo "[Desktop Entry]" >> ${THEME_DIR}/index.theme
  echo "Type=X-GNOME-Metatheme" >> ${THEME_DIR}/index.theme
  echo "Name=${name}${color}${solid}" >> ${THEME_DIR}/index.theme
  echo "Comment=An Flat Gtk+ theme based on Material Design" >> ${THEME_DIR}/index.theme
  echo "Encoding=UTF-8" >> ${THEME_DIR}/index.theme
  echo "" >> ${THEME_DIR}/index.theme
  echo "[X-GNOME-Metatheme]" >> ${THEME_DIR}/index.theme
  echo "GtkTheme=${name}${color}${solid}" >> ${THEME_DIR}/index.theme
  echo "MetacityTheme=${name}${color}${solid}" >> ${THEME_DIR}/index.theme
  echo "IconTheme=Tela${ELSE_DARK}" >> ${THEME_DIR}/index.theme
  echo "CursorTheme=Adwaita" >> ${THEME_DIR}/index.theme
  echo "ButtonLayout=menu:minimize,maximize,close" >> ${THEME_DIR}/index.theme

  mkdir -p                                                                           ${THEME_DIR}/gnome-shell
  cp -ur ${SRC_DIR}/src/gnome-shell/{*.svg,noise-texture.png,pad-osd.css}            ${THEME_DIR}/gnome-shell
  cp -ur ${SRC_DIR}/src/gnome-shell/gnome-shell-theme.gresource.xml                  ${THEME_DIR}/gnome-shell
  cp -ur ${SRC_DIR}/src/gnome-shell/assets${ELSE_DARK}                               ${THEME_DIR}/gnome-shell/assets
  cp -ur ${SRC_DIR}/src/gnome-shell/common-assets/*.svg                              ${THEME_DIR}/gnome-shell/assets

  if [[ "${GS_VERSION:-}" == 'new' ]]; then
    cp -ur ${SRC_DIR}/src/gnome-shell/shell-40-0/gnome-shell${ELSE_DARK}.css         ${THEME_DIR}/gnome-shell/gnome-shell.css
  else
    cp -ur ${SRC_DIR}/src/gnome-shell/shell-3-36/gnome-shell${ELSE_DARK}.css         ${THEME_DIR}/gnome-shell/gnome-shell.css
  fi

  mkdir -p                                                                           ${THEME_DIR}/gtk-2.0
  cp -ur ${SRC_DIR}/src/gtk-2.0/{apps.rc,hacks.rc,main.rc,panel.rc}                  ${THEME_DIR}/gtk-2.0
  cp -ur ${SRC_DIR}/src/gtk-2.0/assets${ELSE_DARK}                                   ${THEME_DIR}/gtk-2.0/assets
  cp -ur ${SRC_DIR}/src/gtk-2.0/gtkrc${color}                                        ${THEME_DIR}/gtk-2.0/gtkrc

  cp -ur ${SRC_DIR}/src/gtk/assets                                                   ${THEME_DIR}/gtk-assets

  mkdir -p                                                                           ${THEME_DIR}/gtk-3.0
  ln -sf ../gtk-assets                                                               ${THEME_DIR}/gtk-3.0/assets
  cp -ur ${SRC_DIR}/src/gtk/3.0/gtk${color}${solid}.css                              ${THEME_DIR}/gtk-3.0/gtk.css
  [[ ${color} != '-dark' ]] && \
  cp -ur ${SRC_DIR}/src/gtk/3.0/gtk-dark${solid}.css                                 ${THEME_DIR}/gtk-3.0/gtk-dark.css

  mkdir -p                                                                           ${THEME_DIR}/gtk-4.0
  ln -sf ../gtk-assets                                                               ${THEME_DIR}/gtk-4.0/assets
  cp -ur ${SRC_DIR}/src/gtk/4.0/gtk${color}${solid}.css                              ${THEME_DIR}/gtk-4.0/gtk.css
  [[ ${color} != '-dark' ]] && \
  cp -ur ${SRC_DIR}/src/gtk/4.0/gtk-dark${solid}.css                                 ${THEME_DIR}/gtk-4.0/gtk-dark.css

  mkdir -p                                                                           ${THEME_DIR}/xfwm4
  cp -ur ${SRC_DIR}/src/xfwm4/assets${ELSE_LIGHT}/*.png                              ${THEME_DIR}/xfwm4
  cp -ur ${SRC_DIR}/src/xfwm4/themerc${ELSE_LIGHT}                                   ${THEME_DIR}/xfwm4/themerc

  cp -ur ${SRC_DIR}/src/plank                                                        ${THEME_DIR}
}

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -d|--dest)
      dest="${2}"
      if [[ ! -d "${dest}" ]]; then
        echo "ERROR: Destination directory does not exist."
        exit 1
      fi
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
    -c|--color)
      shift
      for color in "${@}"; do
        case "${color}" in
          standard)
            colors+=("${COLOR_VARIANTS[0]}")
            shift
            ;;
          light)
            colors+=("${COLOR_VARIANTS[1]}")
            shift
            ;;
          dark)
            colors+=("${COLOR_VARIANTS[2]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized color variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -s|--solid)
      shift
      for solid in "${@}"; do
        case "${solid}" in
          standard)
            colors+=("${SOLID_VARIANTS[0]}")
            shift
            ;;
          solid)
            colors+=("${SOLID_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized color variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unrecognized installation option '$1'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

for color in "${colors[@]:-${COLOR_VARIANTS[@]}}"; do
  for solid in "${solids[@]:-${SOLID_VARIANTS[@]}}"; do
    install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}" "${solid}"
  done
done

echo
echo Done.
