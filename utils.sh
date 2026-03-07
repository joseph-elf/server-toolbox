#!/usr/bin/env bash


if [[ "${UTILS_LOADED:-0}" -eq 1 ]]; then
    return
fi
UTILS_LOADED=1






print_variable() {
    local name=$1
    local verbose=${2:-1}

    # Check variable existence
    if [[ -z "${!name+x}" ]]; then
        [[ $verbose -eq 1 ]] && echo "⚠️ print_variable : Variable $name not set" >&2
        return 0
    fi

    # Detect variable type
    local type
    type=$(declare -p "$name" 2>/dev/null)

    # Array case
    if [[ $type == declare\ -a* ]]; then
        local arr_ref="${name}[@]"
        echo
        for item in "${!arr_ref}"; do
            echo $'\t'"* $item"
        done
        return 0
    fi

    # Associative array case
    if [[ $type == declare\ -A* ]]; then
        local arr_ref="${name}[@]"
        echo
        for item in "${!arr_ref}"; do
            echo $'\t'"* $item"
        done
        return 0
    fi

    # Scalar case
    echo "${!name}"
}




check_variable() {
  OPTIND=1

  local verbose=0
  local exit_if_missing=0
  local args=()

  # Parse arguments
  for arg in "$@"; do
    case "$arg" in
    #flags
      -*) 
        for ((i=1; i<${#arg}; i++)); do
          flag="${arg:$i:1}"
          case "$flag" in
            v) verbose=1 ;;
            r) exit_if_missing=1 ;;
          esac
        done
        ;;
    # other
      *)
        args+=("$arg")
        ;;
    esac
  done

  local name="${args[0]}"

  # Variable check
  if declare -p "$name" &>/dev/null; then
    local value="${!name}"

    if [[ $verbose -eq 1 ]]; then
      echo -n "✅ $name: " >&2
      print_variable "$name" >&2

    fi
    # return the value
    #printf '%s' "$value"
    return 0
  else
    if [[ $exit_if_missing -eq 1 ]]; then
      echo "❌ Error: required variable $name missing" >&2
      exit 1
      return 1
    fi

    if [[ $verbose -eq 1 ]]; then
      echo "⚠️ Warning: $name is not set." >&2
      return 0
    fi

    
    
  fi
  
}






load_config_and_check() {
    # default config file
    local config_file="config-server.sh"
    local flags=""
    local vars=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--config)
                config_file="$2"
                shift 2
                ;;

            -*)
                flags="$1"
                shift
                ;;

            *)
                vars+=("$1")
                shift
                ;;
        esac
    done

    echo "🚀 Reading $config_file..."
    source "./$config_file" || {
        echo "❌ Config load failed" >&2
        exit 1
    }

    for v in "${vars[@]}"; do
        check_variable "$flags" "$v"
    done
}








update_apt() {

  local OPTIND=1
  local opt

  local VERBOSE=0
  local LOG="/tmp/apt_update.log"
  local TIME=86400
  local APT_STAMP="/var/lib/apt/periodic/update-success-stamp"

  # ---- Parse flags ----
  while getopts "vf:" opt; do
      case "$opt" in
          v) VERBOSE=1 ;;
          f) LOG="$OPTARG" ;;
          *)
              echo "Usage: update_apt [-v] [-f LOGFILE] [TIME_SECONDS]"
              return 1
              ;;
      esac
  done

  shift $((OPTIND - 1))

  # ---- Optional TIME argument ----
  if [[ -n "$1" ]]; then
      TIME="$1"
  fi

  local now stamp_age need_update

  if [[ ! -f "$APT_STAMP" ]]; then
      need_update=1
      [[ $VERBOSE -eq 1 ]] && echo "🔍 apt stamp not found → update required"
  else
      now=$(date +%s)
      stamp_age=$(( now - $(stat -c %Y "$APT_STAMP") ))

      if (( stamp_age > TIME )); then
          need_update=1
          [[ $VERBOSE -eq 1 ]] && echo "🕐 apt cache older than $TIME seconds → updating"
      else
          need_update=0
          [[ $VERBOSE -eq 1 ]] && echo "✨ apt cache still fresh → skipping"
      fi
  fi

  if [[ "$need_update" -eq 1 ]]; then
      [[ $VERBOSE -eq 1 ]] && echo "🔄 Running apt update..."

      mkdir -p "$(dirname $LOG)" && touch $LOG

      echo "Running: sudo apt update" >> "$LOG"
      if ! sudo apt update >>"$LOG" 2>&1; then
          echo "❌ apt update failed"
          return 1
      fi

      [[ $VERBOSE -eq 1 ]] && echo "✅ apt update completed"
  fi
}



confirm() {
    while true; do
        read -rp "$1 [y/n]: " answer
        case "$answer" in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            [Nn]|[Nn][Oo]) return 1 ;;
            *) echo "Please answer yes or no." ;;
        esac
    done
}
