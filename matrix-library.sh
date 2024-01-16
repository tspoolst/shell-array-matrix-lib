#!/bin/bash
#[of]:functions
#[of]:test
#[of]:isnum() {
isnum() {
#[of]:  usage
  if false ; then
    echo "Usage: isnum arg"
    echo "Error: must have at least 1 argument"
    echo "Description: checks if arg is a number"
    echo "Examples:"
    echo '  "if isnum 50 ; then'
    echo '    echo is a number'
    echo '  else'
    echo '    echo is not a number'
    echo '  fi"'
    echo '  statement may also be negated'
    echo '    "if ! isnum 50 ; then"'
    echo "Returns:"
    echo "  0 true"
    echo "  1 false"
    exit 1
  fi
#[cf]
  [ "${1##*[![:digit:]+-]*}" ]
}
#[cf]
#[of]:isset() {
isset() {
#[of]:  usage
  if false ; then
    echo "Usage: isset var"
    echo "Error: must have at least 1 argument"
    echo "Description: checks if a given variable is set (i.e. exist)"
    echo "Examples:"
    echo '  "if isset your_var ; then'
    echo '    echo your variable is set'
    echo '  else'
    echo '    echo your variable is not set'
    echo '  fi"'
    echo '  statement may also be negated'
    echo '    "if ! isset your_var ; then"'
    echo "Returns:"
    echo "  0 true"
    echo "  1 false"
    exit 1
  fi
#[cf]
  eval "[ \"\${$1+1}\" ]"
}
#[cf]
#[cf]
#[of]:array
#[of]:asize() {
  asize() {
    if [[ "$1" = "-" ]] ; then
      eval "echo \${#${2}[@]}"
    else
      eval "$1=\"\${#${2}[@]}\""
    fi
  }
#[cf]
#[of]:akeys() {
  akeys() {
    if [[ "$1" = "-" ]] ; then
      eval "echo \"\${!${2}[@]}\""
    else
      eval "$1=\"\${!${2}[@]}\""
    fi
  }
#[cf]
#[of]:aget() {
  aget() {
    local _i
    if [ -z "${2##*\[*}" ] ; then
      if [ "$1" = "-" ] ; then
        eval "echo \"\${$2}\""
      else
        eval "$1=\"\${$2}\""
      fi
    else
      _i=$(eval "for _i in \"\${${2}[@]}\" ; do
        echo -n \"'\${_i//\\'/\\'\\\\\'\\'}' \"
      done")
      if [ "$1" = "-" ] ; then
        echo "${_i% }"
      else
        eval "$1=\"\${_i% }\""
      fi
    fi
  }
#[cf]
#[of]:astep() {
  astep() {
#[c]    astep v a 1
#[c]    astep v a
#[c]    astep a 1
#[c]    astep a

    #force local vars to be defined as unset without affecting parent vars in ksh/bash/dash
    local _v _a _i _s
    unset _v _a _i _s
    local _v _a _i _s
    case $# in
      3)
        _v="$1"
        _a="$2"
        _s="$3"
        ;;
      2)
        if isnum "$2" ; then
          _a="$1"
          _s="$2"
        else
          _v="$1"
          _a="$2"
        fi
        ;;
      1)
        _a=$1
        ;;
    esac
    isset "${_a}" || return 1
    ! isset "${_a}_size" && asize ${_a}_size "${_a}"
    if isset "${_a}_index" ; then
      eval ": \$((${_a}_index=\${${_a}_index:-0}+${_s:-1}))"
      if eval "[ \${${_a}_index} -lt 0 -o \${${_a}_index} -ge \${${_a}_size} ]" ; then
        areset "${_a}"
        return 1
      fi
    else
      eval ${_a}_index=0
    fi
    isset "_v" && eval aget \"\${_v}\" \"${_a}[\${${_a}_index:-0}]\"
  }
#[cf]
#[of]:areset() {
  areset() {
    unset $1_index $1_size
    [ $# -eq 2 ] && eval $1_index=\"\$2\"
  }
#[cf]
#[of]:acurrent() {
  acurrent() {
    if isset "$2" && isset "$2_index" ; then
      eval aget \"\$1\" \"\${2}[\${${2}_index}]\"
    else
      return 1
    fi
  }
#[cf]
#[of]:isaheader() {
  isaheader() {
    isset "$1" && ! isarray "$1"
  }
#[cf]

#[c]
#[of]:array ksh
if [ -n "${KSH_VERSION}" ] ; then
#[of]:  aset() {
  aset() {
    local _n
    _n="${1##=*}"
    if [ -z "${_n##*\[*}" ] ; then
      eval "${1}=\"\${2}\""
    else
      eval "
        shift
        set -A $1 -- \"\$@\"
      "
    fi
  }
#[cf]
#[of]:  aunset() {
    aunset() {
      eval $(eval "set | while read -r _i;do [ -z \"\${_i##$1_*}\" ] && echo \"unset \\\"\${_i%%=*}\\\"\";done")
      unset $1
    }
#[cf]
#[of]:  isarray() {
  isarray() {
    local _i
    _i=$(typeset -p "$1" 2>/dev/null)
    [ -n "${_i}" -a -z "${_i##set -A *}" ]
  }
#[cf]
#[cf]
#[of]:array bash
elif [ -n "${BASH_VERSION}" ] ; then
#[of]:  aset() {
  aset() {
    local _n
    _n="${1##=*}"
    if [ -z "${_n##*\[*}" ] ; then
      eval "${1}=\"\${2}\""
    else
      eval "
        shift
        $1=(\"\$@\")
      "
    fi
  }
#[cf]
#[of]:  aunset() {
  aunset() {
    eval unset \"\$1\" \${!${1}_*}
  }
#[cf]
#[of]:  isarray() {
  isarray() {
    local _i
    _i=$(typeset -p "$1" 2>/dev/null)
    [ -n "${_i}" -a -z "${_i##declare -a *}" ]
  }
#[cf]
#[cf]
else
#[of]:  array dash
  if ! type '[[' >/dev/null ; then
#[of]:    aset() {
  aset() {
    local _n _i
    _n="$1"
    if [ -z "${_n##*\[*}" ] ; then
      _n="${1%%\[*}"
      [ -n "${_n##*_*}" ] && ! isset "${_n}" && eval ${_n}=1
      _i="${1##${_n}\[}";_i="${_i%%\]*}"
      eval "${_n}_${_i}=\"\${2}\""
    else
      aunset "$1"
      _n="$1";shift
      [ -n "${_n##*_*}" ] && ! isset "${_n}" && eval ${_n}=1
      _i=0
      while [ $# -gt 0 ] ; do
        eval "${_n}_${_i}=\"\$1\""
        shift
        : $((_i=_i+1))
      done
    fi
  }
#[cf]
#[of]:    asize() {
  asize() {
    local _i
    eval "_i=\$(set | while read -r _i;do [ -z \"\${_i##${2}_[[:digit:]]*}\" ] && echo -n 1;done)"
    _i="${#_i}"
    if [ "$1" = "-" ] ; then
      echo "${_i}"
    else
      eval "$1=\"\${_i}\""
    fi
  }
#[cf]
#[of]:    aunset() {
  aunset() {
    eval $(eval "set | while read -r _i;do [ -z \"\${_i##$1_*}\" ] && echo \"unset \\\"\${_i%%=*}\\\"\";done")
    unset $1
  }
#[cf]
#[of]:    akeys() {
  akeys() {
    local _i
    eval "_i=\$(set | while read -r _i;do [ -z \"\${_i##${2}_*}\" ] && _i=\"\${_i%%=*}\" && echo -n \"\${_i##*_} \";done)"

    ###I tried doing the array lib 100% in dash.  though this sorting algorithm works, it still sucks cuz it's slow.
    ###Using the "sort" command for anything over 100 entries.  :-/
    if [ $(asize - $2) -gt 100 ] ; then
      #this shell call is not quoted.  the newlines should be stripped from output, but it's not.  :-/
      _i=$( for _j in ${_i% };do echo ${_j};done | sort -n | (while read _j;do echo -n "${_j} ";done) )
    else
      _i=$(
        lc_akeys_doSwap=false
        lc_akeys_size=$(asize - $2)
        set -- ${_i% }
        while [ ${lc_akeys_size} -gt 1 ] ; do
          lc_akeys_index=1
          lc_akeys_tmp=""
          lc_akeys_didSwap=false
          while [ ${lc_akeys_index} -lt ${lc_akeys_size} ] ; do
            ! ${lc_akeys_doSwap} && eval "lc_akeys_vara=\${${lc_akeys_index}}"
            eval "lc_akeys_varb=\${$((lc_akeys_index+1))}"
            if [ "${lc_akeys_vara}" -gt "${lc_akeys_varb}" ] ; then
              lc_akeys_tmp="${lc_akeys_tmp}${lc_akeys_varb} "
              lc_akeys_doSwap=true
              lc_akeys_didSwap=true
            else
              lc_akeys_tmp="${lc_akeys_tmp}${lc_akeys_vara} "
              lc_akeys_doSwap=false
            fi
            shift $((${lc_akeys_index}))
            if ${lc_akeys_doSwap} && [ ${lc_akeys_index} -eq $((lc_akeys_size-1)) ] ; then
              shift
              set -- ${lc_akeys_tmp}${lc_akeys_vara} $@
              lc_akeys_doSwap=false
            else
              set -- ${lc_akeys_tmp}$@
            fi
            : $((lc_akeys_index=lc_akeys_index+1))
          done
          : $((lc_akeys_size=lc_akeys_size-1))
          ${lc_akeys_didSwap} || break
        done
        echo $@
      )
    fi

    if [ "$1" = "-" ] ; then
      eval "echo \"${_i% }\""
    else
      eval "$1=\"\${_i% }\""
    fi
  }
#[c]
#[c]
#[cf]
#[of]:    aget() {
  aget() {
    local _i _n
    if [ -z "${2##*\[*}" ] ; then
      _n="${2%%\[*}"
      _i="${2##${_n}\[}";_i="${_i%%\]*}"
      if [ "$1" = "-" ] ; then
        eval "echo \"\${${_n}_${_i}}\""
      else
        eval "$1=\"\${${_n}_${_i}}\""
      fi
    else
      _i=$(for _i in $(akeys - $2);do echo -n "$(aget - $2[${_i}]) ";done)
      if [ "$1" = "-" ] ; then
        eval "echo \"\${_i% }\""
      else
        eval "$1=\"\${_i% }\""
      fi
    fi
  }
#[cf]
#[of]:    isarray() {
  isarray() {
    local _i
    eval "_i=\$(set | while read -r _i;do [ -z \"\${_i##${1}_*}\" ] && echo 1 && break;done)"
    [ "${_i}" = 1 ]
  }
#[cf]
#[of]:    isaheader() {
  isaheader() {
    isarray "$1"
  }
#[cf]
#[cf]
  else
    echo "not sure what shell this is"
  fi
fi
#[cf]
#[of]:matrix
#[of]:mset() {
mset() {
  local _an _dm _in
  _an="$1";shift
  _dm="$1";shift
  [ ${_dm} -gt 1 ] && {
    eval ${_an}="${_dm}"
  }
  _in=${_dm}
  while [ ${_in} -gt 1 ] ; do
    _an="${_an}_$1"
    shift
    : $((_in=_in-1))
  done

  if [ $# -eq 2 ] ; then
    _in="$1"
    shift
    aset ${_an}[${_in}] "$1"
    return $?
  elif [ $# -gt 2 ] ; then
    shift
    aset ${_an} "$@"
    return $?
  fi
  echo "not enough arguments for matrix size" >&2
  return 1
}
#[cf]
#[of]:mget() {
mget() {
  local _v _an _dm _in
  _v="$1";shift
  _an="$1";shift
  
  if ! isset "${_an}" ; then
    _dm=1
  else
    eval "_dm=\"\${${_an}}\""
  fi

  _in="${_dm}"

  while [ ${_in} -gt 1 ] ; do
    [ $# -gt 0 ] && { _an="${_an}_$1";shift; } || break
    : $((_in=_in-1))
  done

  if [ ${_in} -gt 1 ] ; then
    echo "not enough arguments for matrix size" >&2
    return 1
  elif [ $# = 0 ] ; then
    aget "${_v}" "${_an}"
    return $?
  elif [ $# = 1 ] ; then
    _in="$1";shift
    aget "${_v}" "${_an}[${_in}]"
    return $?
  fi
}
#[cf]
#[of]:msize() {
msize() {
  local _v _an _dm _in
  _v="$1";shift
  _an="$1";shift

  if ! isset "${_an}" ; then
    _dm=1
  else
    eval "_dm=\"\${${_an}}\""
  fi

  _in="${_dm}"
  [ $# -gt $((_in-1)) ] && { echo "matrix is not that big" >&2;return 1; }
  while [ ${_in} -gt 1 ] ; do
    [ $# -gt 0 ] && { _an="${_an}_$1";shift; } || break
    : $((_in=_in-1))
  done
  
  [ ${_in} -eq 1 ] && asize ${_v} "${_an}"
  [ ${_in} -gt 1 ] && {
    _in=$( set | (
        _j=0;_k=""
        while read -r _i;do
          [ -z "${_i##${_an}_*}" ] && {
            _i="${_i%%[\[=]*}"
            _i="${_i#${_an}_}"
            _i="${_i%%_*}"
            [ ${_j} -eq 0 ] && { _k="${_i}";: $((_j=_j+1));continue; }
            [ "${_k}" != "${_i}" ] && { _k="${_i}";: $((_j=_j+1)); }
          }
        done
        echo ${_j}
      )
    )
    if [ "${_v}" = "-" ] ; then
      eval "echo \"${_in% }\""
    else
      eval "${_v}=\"\${_in% }\""
    fi
  }

  return
}
#[cf]
#[of]:mstep() {
mstep() {
  #force local vars to be defined as unset without affecting parent vars in ksh/bash/dash
  local _dm _v _a _i _s
  unset _dm _v _a _i _s
  local _dm _v _a _i _s
  
  ! isnum "$2" && { _v="$1";shift; }
  _a="$1"
  isset "${_a}" || return 1
  isaheader "${_a}" && eval _dm=\"\${${_a}:-1}\" || _dm=1

  shift
  while [ ${_dm} -gt 1 ] ; do
    [ $# -eq 0 ] && { echo "not enough args for this matrix/array" >&2;return 1; }
    _a="${_a}_$1"
    : $((_dm=_dm-1))
    shift
  done
  _s="$1"

  ! isset "${_a}_size" && asize ${_a}_size "${_a}"
  if isset "${_a}_index" ; then
    eval ": \$((${_a}_index=\${${_a}_index:-0}+${_s:-1}))"
    if eval "[ \${${_a}_index} -lt 0 -o \${${_a}_index} -ge \${${_a}_size} ]" ; then
      areset "${_a}"
      return 1
    fi
  else
    eval ${_a}_index=0
  fi
  isset "_v" && eval aget \"\${_v}\" \"${_a}[\${${_a}_index:-0}]\"
}
#[cf]
#[of]:mreset() {
mreset() {
  #force local vars to be defined as unset without affecting parent vars in ksh/bash/dash
  local _dm _v _a _i _s
  unset _dm _v _a _i _s
  local _dm _v _a _i _s
  
  _a="$1"
  isset "${_a}" || return 1
  isaheader "${_a}" && eval _dm=\"\${${_a}:-1}\" || _dm=1
  
  shift
  while [ ${_dm} -gt 1 ] ; do
    [ $# -eq 0 ] && { echo "not enough args for this matrix/array" >&2;return 1; }
    _a="${_a}_$1"
    : $((_dm=_dm-1))
    shift
  done

  unset ${_a}_index ${_a}_size
  [ $# -eq 1 ] && eval ${_a}_index=\"\$1\"
}
#[cf]
#[of]:mcurrent() {
mcurrent() {
  #force local vars to be defined as unset without affecting parent vars in ksh/bash/dash
  local _dm _v _a
  unset _dm _v _a
  local _dm _v _a
  
  _v="$1"
  shift
  _a="$1"
  isset "${_a}" || return 1
  isaheader "${_a}" && eval _dm=\"\${${_a}:-1}\" || _dm=1
  
  shift
  while [ ${_dm} -gt 1 ] ; do
    [ $# -eq 0 ] && { echo "not enough args for this matrix/array" >&2;return 1; }
    _a="${_a}_$1"
    : $((_dm=_dm-1))
    shift
  done

  if isset "${_a}_index" ; then
    eval aget \"\${_v}\" \"\${_a}[\${${_a}_index}]\"
  else
    return 1
  fi
}
#[cf]
#[c]
#[of]:matrix ksh
if [ -n "${KSH_VERSION}" ] ; then
  :
#[cf]
#[of]:matrix bash
elif [ -n "${BASH_VERSION}" ] ; then
  :
#[cf]
else
#[of]:  matrix dash
  if ! type '[[' >/dev/null ; then
    :
#[cf]
  else
    echo "not sure what shell this is"
  fi
fi
#[cf]
#[cf]

