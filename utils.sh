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