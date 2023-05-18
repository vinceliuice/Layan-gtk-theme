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
COLOR_VARIANTS=('' '-Light' '-Dark')
SOLID_VARIANTS=('' '-Solid')

if [[ "$(command -v gnome-shell)" ]]; then
  gnome-shell --version
  SHELL_VERSION="$(gnome-shell --version | cut -d ' ' -f 3 | cut -d . -f -1)"
  if [[ "${SHELL_VERSION:-}" -ge "42" ]]; then
    GS_VERSION="44-0"
  elif [[ "${SHELL_VERSION:-}" -ge "42" ]]; then
    GS_VERSION="42-0"
  elif [[ "${SHELL_VERSION:-}" -ge "40" ]]; then
    GS_VERSION="40-0"
  else
    GS_VERSION="3-36"
  fi
  else
    echo "'gnome-shell' not found, using styles for last gnome-shell version available."
    GS_VERSION="44-0"
fi

usage() {
cat << EOF
Usage: $0 [OPTION]...

OPTIONS:
  -d, --dest DIR          Specify destination directory (Default: $DEST_DIR)

  -n, --name NAME         Specify theme name (Default: $THEME_NAME)

  -c, --color VARIANTS    Specify theme color variant(s) [standard|light|dark] (Default: All variants)

  -l, --libadwaita        Install link to gtk4 config for theming libadwaita

  -r, --remove,
  -u, --uninstall         Uninstall/Remove installed themes

  -h, --help              Show help
EOF
}

install() {
  local dest=${1}
  local name=${2}
  local color=${3}
  local solid=${4}

  [[ ${color} == '-Dark' ]] && local ELSE_DARK=${color}
  [[ ${color} == '-Light' ]] && local ELSE_LIGHT=${color}

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
  cp -ur ${SRC_DIR}/src/gnome-shell/shell-${GS_VERSION}/gnome-shell${ELSE_DARK}.css  ${THEME_DIR}/gnome-shell/gnome-shell.css

  mkdir -p                                                                           ${THEME_DIR}/gtk-2.0
  cp -ur ${SRC_DIR}/src/gtk-2.0/{apps.rc,hacks.rc,main.rc,panel.rc}                  ${THEME_DIR}/gtk-2.0
  cp -ur ${SRC_DIR}/src/gtk-2.0/assets${ELSE_DARK}                                   ${THEME_DIR}/gtk-2.0/assets
  cp -ur ${SRC_DIR}/src/gtk-2.0/gtkrc${color}                                        ${THEME_DIR}/gtk-2.0/gtkrc

  cp -ur ${SRC_DIR}/src/gtk/assets                                                   ${THEME_DIR}/gtk-assets

  mkdir -p                                                                           ${THEME_DIR}/gtk-3.0
  ln -sf ../gtk-assets                                                               ${THEME_DIR}/gtk-3.0/assets
  cp -ur ${SRC_DIR}/src/gtk/3.0/gtk${color}${solid}.css                              ${THEME_DIR}/gtk-3.0/gtk.css
  [[ ${color} != '-Dark' ]] && \
  cp -ur ${SRC_DIR}/src/gtk/3.0/gtk-Dark${solid}.css                                 ${THEME_DIR}/gtk-3.0/gtk-dark.css

  mkdir -p                                                                           ${THEME_DIR}/gtk-4.0
  ln -sf ../gtk-assets                                                               ${THEME_DIR}/gtk-4.0/assets
  cp -ur ${SRC_DIR}/src/gtk/4.0/gtk${color}${solid}.css                              ${THEME_DIR}/gtk-4.0/gtk.css
  [[ ${color} != '-Dark' ]] && \
  cp -ur ${SRC_DIR}/src/gtk/4.0/gtk-Dark${solid}.css                                 ${THEME_DIR}/gtk-4.0/gtk-dark.css

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
    -l|--libadwaita)
      libadwaita='true'
      shift
      ;;
    -r|-u|--remove|--uninstall)
      remove='true'
      shift
      ;;
    -c|--color)
      shift
      for color in "${@}"; do
        case "${color}" in
          standard)
            colors+=("${COLOR_VARIANTS[0]}")
            lcolors+=("${COLOR_VARIANTS[0]}")
            shift
            ;;
          light)
            colors+=("${COLOR_VARIANTS[1]}")
            lcolors+=("${COLOR_VARIANTS[1]}")
            shift
            ;;
          dark)
            colors+=("${COLOR_VARIANTS[2]}")
            lcolors+=("${COLOR_VARIANTS[2]}")
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
            solids+=("${SOLID_VARIANTS[0]}")
            shift
            ;;
          solid)
            solids+=("${SOLID_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized solid variant '$1'."
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

if [[ "${#colors[@]}" -eq 0 ]] ; then
  colors=("${COLOR_VARIANTS[@]}")
fi

if [[ "${#solids[@]}" -eq 0 ]] ; then
  solids=("${SOLID_VARIANTS[@]}")
fi

uninstall_link() {
  rm -rf "${HOME}/.config/gtk-4.0"/{assets,gtk.css,gtk-dark.css}
}

link_libadwaita() {
  local dest=${1}
  local name=${2}
  local lcolor=${3}
  local solid=${4}

  local THEME_DIR="${1}/${2}${3}${4}"

  echo -e "\nLink '$THEME_DIR/gtk-4.0' to '${HOME}/.config/gtk-4.0' for libadwaita..."

  mkdir -p                                                                      "${HOME}/.config/gtk-4.0"
  ln -sf "${THEME_DIR}/gtk-4.0/assets"                                          "${HOME}/.config/gtk-4.0/assets"
  ln -sf "${THEME_DIR}/gtk-4.0/gtk.css"                                         "${HOME}/.config/gtk-4.0/gtk.css"
  ln -sf "${THEME_DIR}/gtk-4.0/gtk-dark.css"                                    "${HOME}/.config/gtk-4.0/gtk-dark.css"
}

clean() {
  local dest=${1}
  local name=${2}
  local color=${3}
  local solid=${4}

  local THEME_DIR=${dest}/${name}${color}${solid}

  if [[  ${color} == '' && ${solid} == '' ]]; then
    this=empty
  elif [[ -d ${THEME_DIR} ]]; then
    rm -rf ${THEME_DIR}
    echo -e "Find: ${THEME_DIR} ! removing it ..."
  fi
}

link_theme() {
  for lcolor in "${lcolors[@]-${COLOR_VARIANTS[1]}}"; do
    for solid in "${solids[0]}"; do
      link_libadwaita "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${lcolor}" "${solid}"
    done
  done
}

clean_theme() {
  for color in '' '-light' '-dark'; do
    for solid in '' '-solid'; do
      clean "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}" "${solid}"
    done
  done
}

uninstall() {
  local dest=${1}
  local name=${2}
  local color=${3}
  local solid=${4}

  local THEME_DIR=${dest}/${name}${color}${solid}

  [[ -d "$THEME_DIR" ]] && rm -rf "$THEME_DIR" && echo -e "Uninstalling "$THEME_DIR" ..."
}

uninstall_theme() {
  for color in "${colors[@]}"; do
    for solid in "${solids[@]}"; do
      uninstall "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}" "${solid}"
    done
  done
}

install_theme() {
  for color in "${colors[@]}"; do
    for solid in "${solids[@]}"; do
      install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}" "${solid}"
    done
  done
}

clean_theme

if [[ "${remove:-}" != 'true' ]]; then
  install_theme

  if [[ "$libadwaita" == 'true' ]]; then
    uninstall_link && link_theme
  fi
else
  if [[ "$libadwaita" == 'true' ]]; then
    echo -e "\nUninstall ${HOME}/.config/gtk-4.0 links ..."
    uninstall_link
  else
    echo && uninstall_theme && uninstall_link
  fi
fi

echo
echo Done.
