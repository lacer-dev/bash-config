#
# ~/.bash_functions
#

############################################################################
# invokes windows's "explorer.exe" with a unix-style path.
alias explorer=uexplorer
function uexplorer() {
  local SEEHELP="See $FUNCNAME --help for more info"
  # identify path-conversion tool
  local conv_tool_path 
  if command -v wslpath &>/dev/null; then 
    conv_tool_path='wslpath'
  elif command -v cygpath &>/dev/null; then
    conv_tool_path='cygpath'
  else
    echo "$FUNCNAME: this platform is not supported" >&2
    echo "$SEEHELP" >&2
    return 2;
  fi
  
  # locate Windows Explorer
  local explorer_path="$("$conv_tool_path" -ua 'C:/Windows/explorer.exe')"
  if ! command -v "$explorer_path" &>/dev/null; then
    echo "$FUNCNAME: explorer.exe was not found" >&2
    echo "$SEEHELP" >&2
    return 2
  fi
  
  # process arguments
  args=$(getopt -a -n "$FUNCNAME" -o 'hs' -l 'help,strip,no-symlinks' -- "${@:1}")
  if [[ $? -eq 0 ]]; then
    eval set -- $args
  elif [[ $? -ne 0 ]]; then
    echo "$FUNCNAME: invalid arguments" >&2
    echo "$SEEHELP" >&2
    return 1
  fi

  local no_symlinks=n
  while [ $# -gt 0 ]; do
    case $1 in
      (--help|-h) 
        echo "Usage: uexplorer DIR"
        echo "Opens DIR in the Windows File Explorer."
        echo "Options:"
        echo "    -s, --strip, --no-symlinks    if DIR is a symlink, don't expand it."
        echo "                                   Only works with MSYS2 and Cygwin."
        echo "Exit status:"
        echo "  0  if OK,"
        echo "  1  if DIR does not exist, is not a directory, or the user lacks reading"
        echo "      permissions, or"
        echo "  2  if explorer.exe can't be located, or neither wslpath or cygpath"
        echo "      are available on this system."
        echo "Notes:"
        echo "  --no-symlinks may cause issues if Developer Mode is not enabled (through"
        echo "   Windows settings), as symlinks are not supported on regular Windows."
        echo "  Windows shortcuts (.lnk files) are not supported and are interpreted"
        echo "   as regular files."
        return 0 ;;
      (-s|--strip|--no-symlinks)
        no_symlinks=y ;;
      (--) 
        shift
        break ;;
      (*) 
        break ;;
    esac
    shift
  done

  if [ $# -gt 1 ]; then
    for arg in "${@:2}"; do
      echo "$FUNCNAME: invalid argument \"$arg\"" >&2
    done
    echo "$SEEHELP" >&2
    return 1
  elif [[ $# -eq 0 ]]; then
    echo "$FUNCNAME: not enough arguments" >&2
    echo "$SEEHELP" >&2
    return 1
  fi

  local unixpath="$1"
  # don't traverse symlinks if --no-symlinks
  if [[ $no_symlinks == y ]]; then
    unixpath="$(realpath -s "$unixpath")"
  else
    unixpath="$(realpath "$unixpath")"
  fi
  # verify that path exists
  if [[ ! -e "$unixpath" ]]; then
    echo "$FUNCNAME: path '$1' does not exist" >&2
    echo "$SEEHELP" >&2
    return 1
  fi
  # verify that path is a directory
  if [[ ! -d "$unixpath" ]]; then
    echo "$FUNCNAME: '$1' is not a directory" >&2
    echo "$SEEHELP" >&2
    return 1
  fi
  # verify that user can access the directory
  if [[ ! -r "$unixpath" ]]; then
    echo "$FUNCNAME: permissions denied '$1'" >&2
    echo "$SEEHELP" >&2
    return 1
  fi
  # convert path to windows format and open in windows explorer
  "$explorer_path" "$("$conv_tool_path" -wa "$unixpath")"
  return 0
}

############################################################################
# Petar Marinov, http:/geocities.com/h2428, this is public domain
alias cd=cd_func
function cd_func() {
  local x2 the_new_dir adir index
  local -i cnt

  if [[ $1 ==  "--" ]]; then
    dirs -v
    return 0
  fi

  the_new_dir=$1
  [[ -z $1 ]] && the_new_dir=$HOME

  if [[ ${the_new_dir:0:1} == '-' ]]; then
    #
    # Extract dir N from dirs
    index=${the_new_dir:1}
    [[ -z $index ]] && index=1
    adir=$(dirs +$index)
    [[ -z $adir ]] && return 1
    the_new_dir=$adir
  fi
  # '~' has to be substituted by ${HOME}
  [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"
  # Now change to the new dir and add to the top of the stack
  pushd "${the_new_dir}" > /dev/null
  [[ $? -ne 0 ]] && return 1
  the_new_dir=$(pwd)
  # Trim down everything beyond 11th entry
  popd -n +11 2>/dev/null 1>/dev/null
  # Remove any other occurence of this dir, skipping the top of the stack
  for ((cnt=1; cnt <= 10; cnt++)); do
    x2=$(dirs +${cnt} 2>/dev/null)
    [[ $? -ne 0 ]] && return 0
    [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
    if [[ "${x2}" == "${the_new_dir}" ]]; then
      popd -n +$cnt 2>/dev/null 1>/dev/null
      cnt=cnt-1
    fi
done

  return 0
}

listpath() { 
  local SPLITPATH
  IFS=: read -a SPLITPATH <<< "$PATH" && for path in ${SPLITPATH[@]}; do echo "$path":; done
}
