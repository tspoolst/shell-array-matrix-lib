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


#[of]:ansort() {
ansort() {
#[of]:  usage
  if [[ $# -lt 2 ]] ; then
    echo "Usage: asort {-|array} [val val val ...]"
    echo "Error: must have at least 2 args"
    echo "Description:"
    echo "  sorts an array"
    echo "Examples:"
    echo '  i.e.  asort a "${a[@]}"'
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[cf]
  typeset lc_asort_tmp lc_asort_size lc_asort_index
  unset lc_asort_array
#[of]:  array bubble sort
  aset lc_asort_array "$@"
  ashift ! lc_asort_array
  lc_asort_size=${#lc_asort_array[@]}
  ((lc_asort_size-=1))
  while [[ ${lc_asort_size} -gt 0 ]] ; do
    lc_asort_index=0    
    while [[ ${lc_asort_index} -lt ${lc_asort_size} ]] ; do
      if [[ "${lc_asort_array[${lc_asort_index}]}" > "${lc_asort_array[$((lc_asort_index+1))]}" ]] ; then
        lc_asort_tmp="${lc_asort_array[$((lc_asort_index+1))]}"
        lc_asort_array[$((lc_asort_index+1))]="${lc_asort_array[${lc_asort_index}]}"
        lc_asort_array[${lc_asort_index}]="${lc_asort_tmp}"
      fi
      ((lc_asort_index+=1))
    done
    ((lc_asort_size-=1))
  done
#[cf]
  if [[ "$1" = "-" ]] ; then
    echo "${lc_asort_array[@]}"
  else
    eval "aset $1 \"\${lc_asort_array[@]}\""
  fi
  unset lc_asort_array
  return 0
}
#[cf]

#[of]:asplit() {
asplit() {
#[of]:  usage
  if [ $# -lt 2 ] ; then
    echo "Usage: asplit {array} {delimiter} [string]"
    echo "Error: must have at least 2 args"
    echo "Description:"
    echo "  splits a string into an array list"
    echo "  this emulates the perl function join"
    echo "Examples:"
    echo '  i.e.  asplit b : "part1:part2:part3:part4"'
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[cf]
  local _esc
  if [ "$1" = "-e" ] ; then
    _esc=true
    shift
  fi
#[of]:  if [ -z "$2" ] ; then
  if [ -z "$2" ] ; then
    eval "
      shift;shift
      local _string=\"\$*\"
      local _aindex
      _aindex=0

      if isnum \"$1\" ; then
        while [ \${#_string} -gt 0 ] ; do
          [ \"$1\" -eq \"\${_aindex}\" ] && {
            echo \"\${_string%\"\${_string#?}\"}\"
            break
          }
          _string=\"\${_string#?}\"
          : \$((_aindex=_aindex+1))
        done
      else
        while [ \${#_string} -gt 0 ] ; do
          aset $1[\${_aindex}] \"\${_string%\"\${_string#?}\"}\"
          _string=\"\${_string#?}\"
          : \$((_aindex=_aindex+1))
        done
      fi
    "
#[cf]
#[of]:  elif ${_esc\:-false} ; then
  elif ${_esc:-false} ; then
    eval "
      shift;shift
      local _char
      local _lit=false
      local _index=0
      local _string=\"\$*\"

      if isnum \"$1\" ; then
        while [ \${#_string} -gt 0 ] ; do
          _char=\"\${_string%\"\${_string#?}\"}\"
          _string=\"\${_string#?}\"
          if [ \"\${_char}\" = \"\\\\\" ] ; then
            _lit=true
            continue
          elif ! \${_lit} && [ \"\${_char}\" = \"$2\" ] ; then
            [ \"$1\" -eq \"\${_index}\" ] && {
              echo \"\${_entry}\"
              break
            }
            unset _entry
            : \$((_index=_index+1))
            continue
          fi
          _lit=false
          local _entry=\"\${_entry}\${_char}\"
        done
        [ \"$1\" -eq \"\${_index}\" ] && {
          echo \"\${_entry}\"
        }
      else
        while [ \${#_string} -gt 0 ] ; do
          _char=\"\${_string%\"\${_string#?}\"}\"
          _string=\"\${_string#?}\"
          if [ \"\${_char}\" = \"\\\\\" ] ; then
            _lit=true
            continue
          elif ! \${_lit} && [ \"\${_char}\" = \"$2\" ] ; then
            aset $1[\${_index}] \"\${_entry}\"
            unset _entry
            : \$((_index=_index+1))
            continue
          fi
          _lit=false
          local _entry=\"\${_entry}\${_char}\"
        done
        aset $1[\${_index}] \"\${_entry}\"
      fi
    "
#[cf]
#[of]:  else
  else
    eval "
      shift;shift
      local IFS=\"$2\"
      local _string=\"\$*\"
      if isnum \"$1\" ; then
        set -- \$@
        eval \"echo \\\"\\\$\$(($1 +1))\\\" \"
      else
        if [ \"\${_string%$2}\" = \"\$*\" ] ; then
          aset $1 \$@
        else
          aset $1 \$@ \"\"
        fi
      fi
    "
#[cf]
  fi
}
##if first arg is a number it is a zero based position in the string
##ugh.  yet another lovely backslash forrest.
#[cf]
#[of]:ajoin() {
ajoin() {
#[of]:  usage
  if [ $# -lt 2 ] ; then
    echo "Usage: ajoin {-|var} {delimiter} [val val val ...]"
    echo "Error: must have at least 2 args"
    echo "Description:"
    echo "  joins a list into a single string"
    echo "  this emulates the perl function join"
    echo "Examples:"
    echo '  i.e.  ajoin a : "${a[@]}"'
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[cf]
  eval "
    shift;shift
    local IFS=\"$2\"
    if [ \"$1\" = \"-\" ] ; then
      echo \"\$*\"
    else
      $1=\"\$*\"
    fi
  "
}
#[cf]

#[of]:apush() {
apush() {
#[of]:  usage
  if [[ $# -eq 0 ]] ; then
    echo "Usage: apush {array} [val val val ...]"
    echo "Error: must have at least 2 args"
    echo "Description:"
    echo "  adds new element/s to the end of an array"
    echo "  this emulates the perl function unshift"
    echo "Examples:"
    echo '  i.e.  apush b "a string"'
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[cf]
  eval "
    shift
    aset $1 \"\${$1[@]}\" \"\$@\"
  "
}
#[cf]
#[of]:apop() {
apop() {
#[of]:  usage
  if [[ $# -ne 2 ]] ; then
    echo "Usage: apop {!|-|var} {array}"
    echo "Error: must have at least 2 args"
    echo "Description:"
    echo "  shift an array 1 element right and return that element in var"
    echo "  this emulates the perl function shift"
    echo "Examples:"
    echo '  i.e.  apop b a'
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[cf]
  eval "
    if [[ \${#$2[@]} -gt 0 ]] ; then
      if [[ \"$1\" = \"!\" ]] ; then
        :
      elif [[ \"$1\" = \"-\" ]] ; then
        echo \"\${$2[\$((\${#$2[@]} -1))]}\"
      else
        $1=\"\${$2[\$((\${#$2[@]} -1))]}\"
      fi
      unset $2[\$((\${#$2[@]} -1))]
    else
      return 1
    fi
  "
  return 0
}
#[cf]

#[of]:aunshift() {
aunshift() {
#[of]:  usage
  if [[ $# -eq 0 ]] ; then
    echo "Usage: aunshift {array} [val val val ...]"
    echo "Error: must have at least 2 args"
    echo "Description:"
    echo "  adds new element/s to the beginning of an array"
    echo "  this emulates the perl function unshift"
    echo "Examples:"
    echo '  i.e.  aunshift b "a string"'
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[cf]
  eval "
    shift
    aset $1 \"\$@\" \"\${$1[@]}\"
  "
}
#[cf]
#[of]:ashift() {
ashift() {
#[of]:  usage
  if [[ $# -ne 2 ]] ; then
    echo "Usage: ashift {!|-|var} {array}"
    echo "Error: must have at least 2 args"
    echo "Description:"
    echo "  shift an array 1 element left and return that element in var"
    echo "  this emulates the perl function shift"
    echo "Examples:"
    echo '  i.e.  ashift b a'
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[cf]
  eval "
    if [[ \${#$2} -gt 0 ]] ; then
      if [[ \"$1\" = \"!\" ]] ; then
        :
      elif [[ \"$1\" = \"-\" ]] ; then
        echo \"\${$2[0]}\"
      else
        $1=\"\${$2[0]}\"
      fi
      unset $2[0]
      aset $2 \"\${$2[@]}\"
    else
      return 1
    fi
  "
  return 0
}
#[cf]

#[of]:awalkl() {
awalkl() {
#[of]:  usage
  if [ $# -ne 2 ] ; then
    echo "Usage: awalkl {left array} {right array}"
    echo "Error: must have at least 2 args"
    echo "Description:"
    echo "  walks/moves array elements  <---  right to left"
    echo "Examples:"
    echo '  i.e.  awalkl nodes args'
    echo "Returns:"
    echo "  0 success"
    echo "  1 if right array is empty"
    exit 1
  fi
#[cf]
  ashift lc_awalkl_tmp $2 || return $?
  apush $1 "${lc_awalkl_tmp}"
  unset lc_awalkl_tmp
  return 0
}
#[cf]
#[of]:awalkr() {
awalkr() {
#[of]:  usage
  if [ $# -ne 2 ] ; then
    echo "Usage: awalkr {left array} {right array}"
    echo "Error: must have at least 2 args"
    echo "Description:"
    echo "  walks/moves array elements  --->  left to right"
    echo "Examples:"
    echo '  i.e.  awalkr args nodes'
    echo "Returns:"
    echo "  0 success"
    echo "  1 if left array is empty"
    exit 1
  fi
#[cf]
  apop lc_awalkl_tmp $1 || return $?
  aunshift $2 "${lc_awalkl_tmp}"
  unset lc_awalkl_tmp
  return 0
}
#[cf]



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
      _i=$(
        for _i in $(akeys - $2);do
          _i="$(aget - $2[${_i}])"
          [ -z "${_i##*\'*}" -a -n "${_i}" ] && {
            a="";b="${_i}";_i=""
            while [ -n "${b}" ] ; do
              a="${b%${b#?}}";b="${b#?}"
              [ "${a}" = "'" ] && a="'\''"
              _i="${_i}${a}"
            done
          }
          echo -n "'${_i}' "
        done
      )
      if [ "$1" = "-" ] ; then
        eval "echo \"\${_i% }\""
      else
        eval "$1=\"\${_i% }\""
      fi
    fi
  }
#[c]
#[cf]
#[of]:    akeys() {
  akeys() {
    local _i
    eval "_i=\$(set | while read -r _i;do [ -z \"\${_i##${2}_*}\" ] && _i=\"\${_i%%=*}\" && echo -n \"\${_i##*_} \";done)"

    [ -n "${_i}" ] && _i=$(ansort - ${_i})

    if [ "$1" = "-" ] ; then
      eval "echo \"${_i% }\""
    else
      eval "$1=\"\${_i% }\""
    fi
  }
#[c]
#[c]
#[cf]
#[of]:    ansort() {
ansort() {
#[of]:  usage
  if [ $# -lt 2 ] ; then
    echo "Usage: asort {-|array} [val val val ...]"
    echo "Error: must have at least 2 args"
    echo "Description:"
    echo "  sorts an array"
    echo "Examples:"
    echo '  i.e.  asort a "${a[@]}"'
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[cf]
  local lc_asort_var lc_asort_input lc_asort_tmp lc_asort_output
  local lc_asort_val1 lc_asort_val2
  local lc_asort_didSwap

  lc_asort_var="$1"
  shift
  lc_asort_input="$@"
  
  ###I tried doing the array lib 100% in dash.  though this sorting algorithm works, it still sucks cuz it's slow.
  ###Using the "sort" command for anything over 100 entries.  :-/
  if [ $# -gt 100 ] ; then
    #this shell call is not quoted.  the newlines should be stripped from output, but it's not.  :-/
    lc_asort_output=$( for _i in ${lc_asort_input};do echo ${_i};done | sort -n | (while read _i;do echo -n "${_i} ";done) )
  else
    lc_asort_didSwap=true
    while ${lc_asort_didSwap} && [ -n "${lc_asort_input}" ] ; do
      lc_asort_didSwap=false
      if [ -z "${lc_asort_input##* *}" ] ; then
        lc_asort_val1="${lc_asort_input%% *}"
        lc_asort_input="${lc_asort_input#* }"
      else
        lc_asort_val1="${lc_asort_input}"
        lc_asort_input=""
      fi
      while [ -n "${lc_asort_input}" ] ; do
        if [ -z "${lc_asort_input##* *}" ] ; then
          lc_asort_val2="${lc_asort_input%% *}"
          lc_asort_input="${lc_asort_input#* }"
        else
          lc_asort_val2="${lc_asort_input}"
          lc_asort_input=""
        fi
        if [ ${lc_asort_val1} -lt ${lc_asort_val2} ] ; then
          lc_asort_tmp="${lc_asort_tmp}${lc_asort_val1} "
          lc_asort_val1="${lc_asort_val2}"
        else
          lc_asort_tmp="${lc_asort_tmp}${lc_asort_val2} "
          lc_asort_didSwap=true
        fi
      done
      if ${lc_asort_didSwap} ; then
        lc_asort_input="${lc_asort_tmp% }"
        lc_asort_tmp=""
        lc_asort_output="${lc_asort_val1}${lc_asort_output:+ }${lc_asort_output}"
      else
        lc_asort_tmp="${lc_asort_tmp% }"
        lc_asort_output="${lc_asort_tmp}${lc_asort_tmp:+ }${lc_asort_val1}${lc_asort_output:+ }${lc_asort_output}"
      fi
    done
  fi
  if [ "${lc_asort_var}" = "-" ] ; then
    eval "echo \"${lc_asort_output}\""
  else
    eval "${lc_asort_var}=\"\${lc_asort_output}\""
  fi
}
#[cf]
#[of]:    ansort2() {
ansort2() {
  ###first try at bubble sort in dash
  ###about 10x slower than the current asort
  local lc_asort_var lc_asort_input lc_asort_tmp lc_asort_output
  local lc_asort_val1 lc_asort_val2
  local lc_asort_didSwap

  lc_asort_var="$1"
  shift
  lc_asort_input="$@"
   
  lc_asort_output=$(
    lc_akeys_doSwap=false
    lc_akeys_size=$#
    set -- ${lc_asort_input}
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

  if [ "${lc_asort_var}" = "-" ] ; then
    eval "echo \"${lc_asort_output}\""
  else
    eval "${lc_asort_var}=\"\${lc_asort_output}\""
  fi
}
#[cf]
#[of]:    apush() {
apush() {
#[of]:  usage
  if [ $# -eq 0 ] ; then
    echo "Usage: apush {array} [val val val ...]"
    echo "Error: must have at least 2 args"
    echo "Description:"
    echo "  adds new element/s to the end of an array"
    echo "  this emulates the perl function unshift"
    echo "Examples:"
    echo '  i.e.  apush b "a string"'
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[cf]
  eval "
    shift
    aset $1 $(aget - $1) \"\$@\"
  "
}
#[cf]
#[of]:    apop() {
apop() {
#[of]:  usage
  if [ $# -ne 2 ] ; then
    echo "Usage: apop {!|-|var} {array}"
    echo "Error: must have at least 2 args"
    echo "Description:"
    echo "  shift an array 1 element right and return that element in var"
    echo "  this emulates the perl function shift"
    echo "Examples:"
    echo '  i.e.  apop b a'
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[cf]
  local _s
  _s=$(asize - $2)
  if [ ${_s} -gt 0 ] ; then
    aget $1 $2[$((_s-1))]
    aunset $2[$((_s-1))]
  else
    return 1
  fi
  return 0
}
#[cf]
#[of]:    aunshift() {
aunshift() {
#[of]:  usage
  if [ $# -eq 0 ] ; then
    echo "Usage: aunshift {array} [val val val ...]"
    echo "Error: must have at least 2 args"
    echo "Description:"
    echo "  adds new element/s to the beginning of an array"
    echo "  this emulates the perl function unshift"
    echo "Examples:"
    echo '  i.e.  aunshift b "a string"'
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[cf]
  eval "
    shift
    aset $1 \"\$@\" $(aget - $1)
  "
}
#[cf]
#[of]:    ashift() {
ashift() {
#[of]:  usage
  if [ $# -ne 2 ] ; then
    echo "Usage: ashift {!|-|var} {array}"
    echo "Error: must have at least 2 args"
    echo "Description:"
    echo "  shift an array 1 element left and return that element in var"
    echo "  this emulates the perl function shift"
    echo "Examples:"
    echo '  i.e.  ashift b a'
    echo "Returns:"
    echo "  0 success"
    exit 1
  fi
#[cf]
  local _s
  _s=$(asize - $2)
  if [ ${_s} -gt 0 ] ; then
    aget $1 $2[0]
    aunset $2[0]
    eval aset $2 $(aget - $2)
  else
    return 1
  fi
  return 0
}
#[cf]
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
    if [ -z "${1##*\[*}" ] ; then
      _n="${1%%\[*}"
      _i="${1##${_n}\[}";_i="${_i%%\]*}"
      unset ${_n}_${_i}
    else
      eval $(eval "set | while read -r _i;do [ -z \"\${_i##$1_*}\" ] && echo \"unset \\\"\${_i%%=*}\\\"\";done")
      unset $1
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
          [ -z "${_i##${_an}_[[:digit:]]*}" ] && {
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
  local _dm _v _a _ar _i _s
  unset _dm _v _a _ar _i _s
  local _dm _v _a _ar _i _s
  
  local _indexFlag
  _indexFlag=false

  [ "$1" = "-i" ] && {
    _indexFlag=true
    shift
  }
  
  ! isnum "$2" && { _v="$1";shift; }
  _a="$1"
  _ar="$1"
  isset "${_a}" || return 1
  isaheader "${_a}" && eval _dm=\"\${${_a}:-1}\" || _dm=1

  shift
  while [ ${_dm} -gt 1 ] ; do
    [ $# -eq 0 ] && break
    _a="${_a}_$1"
    _ar="${_ar} $1"
    : $((_dm=_dm-1))
    shift
  done
  _s="$1"

  if [ ${_dm} -eq 1 ] ; then
    ! isset "${_a}_size" && asize ${_a}_size "${_a}"
  else
    ! isset "${_a}_size" && msize ${_a}_size ${_ar}
  fi

  if isset "${_a}_index" ; then
    eval ": \$((${_a}_index=\${${_a}_index:-0}+${_s:-1}))"
    if eval "[ \${${_a}_index} -lt 0 -o \${${_a}_index} -ge \${${_a}_size} ]" ; then
      if [ ${_dm} -eq 1 ] ; then
        areset "${_a}"
      else
        mreset "${_a}"
      fi
      return 1
    fi
  else
    eval ${_a}_index=0
  fi

  if [ ${_dm} -eq 1 ] && ! ${_indexFlag} ; then
    isset "_v" && eval aget \"\${_v}\" \"${_a}[\${${_a}_index:-0}]\"
  else
    if [ "${_v}" = "-" ] ; then
      eval echo \"\${${_a}_index:-0}\"
    else
      eval "${_v}=\"\${${_a}_index:-0}\""
    fi
  fi
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
    [ $# -eq 0 ] && break
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
  
  local _indexFlag
  _indexFlag=false

  [ "$1" = "-i" ] && {
    _indexFlag=true
    shift
  }
  
  _v="$1"
  shift
  _a="$1"
  isset "${_a}" || return 1
  isaheader "${_a}" && eval _dm=\"\${${_a}:-1}\" || _dm=1
  
  shift
  while [ ${_dm} -gt 1 ] ; do
    [ $# -eq 0 ] && break
    _a="${_a}_$1"
    : $((_dm=_dm-1))
    shift
  done

  if isset "${_a}_index" ; then
    if [ ${_dm} -eq 1 ] && ! ${_indexFlag} ; then
      eval aget \"\${_v}\" \"\${_a}[\${${_a}_index}]\"
    else
      if [ "${_v}" = "-" ] ; then
        eval echo \"\${${_a}_index:-0}\"
      else
        eval "${_v}=\"\${${_a}_index:-0}\""
      fi
    fi
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
#[of]:  msize() {
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
    _in=$(
      eval "_i=( \${!${_an}*} )"
      _j=0;k=""
      for _i in "${_i[@]}" ; do
        [ -z "${_i##*_[[:digit:]]*}" ] && {
          _i="${_i#${_an}_}"
          _i="${_i%%_*}"
          [ ${_j} -eq 0 ] && { _k="${_i}";: $((_j=_j+1));continue; }
          [ "${_k}" != "${_i}" ] && { _k="${_i}";: $((_j=_j+1)); }
        }
      done
      echo ${_j}
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

