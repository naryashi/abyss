#!/usr/bin/env bash
# build.sh - post-install launcher with a checklist menu (like tasksel)
#
#   ./build.sh          open the menu
#   ./build.sh --list   only list the modules available for this distro
#
# Each file in modules/ is one checkbox. Header comments control it:
#   # DESC:    text shown in the menu
#   # DISTRO:  arch | rhel | debian | any   (default: any)
#   # DEFAULT: on | off               (default: off)
# Files run in filename order (10-..., 20-..., 30-...).

set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$DIR/modules"
LOG="$HOME/post-install-$(date +%F_%H%M%S).log"

# ---------- detect distro family ----------
# shellcheck disable=SC1091
. /etc/os-release
case " ${ID:-} ${ID_LIKE:-} " in
  *" arch "*) FAMILY=arch ;;
  *" rhel "*) FAMILY=rhel ;;   # AlmaLinux, Rocky, RHEL...
  *" debian "*|*" ubuntu "*) FAMILY=debian ;;   # Debian, Ubuntu, Mint, Pop!_OS...
  *)          FAMILY=other ;;
esac
export FAMILY

# ---------- discover modules ----------
meta() { sed -n "s/^# $2:[[:space:]]*//p" "$1" | head -n1; }

declare -A PATHS
ITEMS=()
for f in "$MODULES_DIR"/*.sh; do
  [[ -f $f ]] || continue
  base=$(basename "$f" .sh)
  tag=${base#[0-9][0-9]-}                       # "30-flatpak" -> "flatpak"
  desc=$(meta "$f" DESC);     desc=${desc:-$tag}
  distro=$(meta "$f" DISTRO); distro=${distro:-any}
  state=$(meta "$f" DEFAULT); state=${state:-off}
  [[ $distro == any || " $distro " == *" $FAMILY "* ]] || continue
  PATHS[$tag]=$f
  ITEMS+=("$tag" "$desc" "$state")
done

if [[ ${1:-} == --list ]]; then
  echo "Detected family: $FAMILY"
  for ((i = 0; i < ${#ITEMS[@]}; i += 3)); do
    printf '%-18s [%-3s] %s\n' "${ITEMS[i]}" "${ITEMS[i+2]}" "${ITEMS[i+1]}"
  done
  exit 0
fi

if ((${#ITEMS[@]} == 0)); then
  echo "No modules found for '$FAMILY' in $MODULES_DIR"
  exit 1
fi

# ---------- make sure whiptail exists ----------
if ! command -v whiptail >/dev/null; then
  echo "whiptail not found, installing it..."
  case $FAMILY in
    arch) sudo pacman -S --needed --noconfirm libnewt ;;
    rhel) sudo dnf install -y newt ;;
    debian) sudo apt-get install -y whiptail ;;
    *)    echo "Please install whiptail first."; exit 1 ;;
  esac
fi

# ---------- checklist menu ----------
height=$(( ${#ITEMS[@]} / 3 ))
((height > 14)) && height=14

choices=$(whiptail --title "Post-install  -  ${PRETTY_NAME:-$FAMILY}" \
  --separate-output \
  --checklist "SPACE = mark   ENTER = OK   TAB = switch buttons" \
  24 80 "$height" "${ITEMS[@]}" 3>&1 1>&2 2>&3) || { echo "Cancelled."; exit 0; }

[[ -z $choices ]] && { echo "Nothing selected."; exit 0; }
mapfile -t SELECTED <<<"$choices"

whiptail --title "Confirm" --yesno \
  "Run these modules?\n\n$(printf '  * %s\n' "${SELECTED[@]}")" \
  $((${#SELECTED[@]} + 8)) 50 || { echo "Cancelled."; exit 0; }

# ---------- sudo once, keep it alive ----------
sudo -v || exit 1
( while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) 2>/dev/null &
KEEPALIVE=$!
trap 'kill "$KEEPALIVE" 2>/dev/null' EXIT

# ---------- run ----------
OK=(); FAIL=()
for tag in "${SELECTED[@]}"; do
  printf '\n\033[1;36m==> %s\033[0m\n' "$tag"
  if bash "${PATHS[$tag]}" 2>&1 | tee -a "$LOG"; then
    OK+=("$tag")
  else
    FAIL+=("$tag")
  fi
done

# ---------- summary ----------
summary="Done: ${#OK[@]}   Failed: ${#FAIL[@]}\n"
((${#FAIL[@]} > 0)) && summary+="\nFailed:\n$(printf '  x %s\n' "${FAIL[@]}")\n"
summary+="\nLog: $LOG"
whiptail --title "Finished" --msgbox "$summary" 16 70
printf '\nEnd :3\n'
