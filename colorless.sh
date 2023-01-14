#!@BIN_SH@

# Copyright (c) 2023 Kimmo Suominen
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer
#    in the documentation and/or other materials provided with the
#    distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Use caller's PATH.

PROG="${0##*/}"

alias_commands()
{
    local cmd sep
    case "${syntax}" in
    csh)
	sep=' '
	;;
    *)
	sep='='
	;;
    esac
    known_options \
    | sed -n '/^#/ d; /:/ {s/:.*$//; p;}' \
    | sort -u \
    | while read cmd
    do
	echo "alias ${cmd}${sep}'${PROG}${mono:+ -m} ${cmd}';"
    done
}

find_options()
{
    local cmd
    cmd="${1}"
    known_options | sed -n "/^${cmd}:/ {s///; p; q;}"
}

known_options()
{
    if [ -r "${HOME}/.${PROG}.conf" ]
    then
	cat "${HOME}/.${PROG}.conf"
    fi
    if [ -r "@PREFIX@/share/${PROG}/${PROG}.conf" ]
    then
	cat "@PREFIX@/share/${PROG}/${PROG}.conf"
    fi
}

usage()
{
    cat <<EOF
Usage:	${PROG} [-m] command [args ...]
	${PROG} -a [-cms]
	${PROG} -h

Enable colorised command output and pipe it to less.

Options:
  -a	Output aliases for all known commands.
  -c	Use C shell syntax for alias commands.
  -h	Show this usage message.
  -m	Do not enable colorised output ("monochrome").
  -s	Use Bourne shell syntax for alias commands.
EOF
}

version()
{
    echo "colorless @VERSION@"
    sed -n '/Copyright/ {s/^# //; p; q;}' "${0}"
    echo 'https://kimmo.suominen.com/sw/colorless'
}

case "${SHELL:-/bin/sh}" in
*csh)
    syntax=csh
    ;;
*)
    syntax=sh
    ;;
esac

mode=
mono=

while getopts Vachms opt
do
    case "${opt}" in
    V)	version; exit 0;;
    a)	mode=alias;;
    c)	syntax=csh;;
    h)	usage; exit 0;;
    m)	mono=true;;
    s)	syntax=sh;;
    *)	usage 1>&2; exit 1;;
    esac
done
shift $((${OPTIND} - 1))

case "${mode}" in
alias)
    alias_commands
    exit 0
    ;;
esac

if [ ${#} -lt 1 ]
then
    usage 1>&2
    exit 1
fi

cmd="${1}"
shift

[ ! -t 1 ] && exec "${cmd}" "${@}"
case "${mono}" in
true)
    color=
    ;;
*)
    color="$(find_options "${cmd}")"
    ;;
esac
exec 3>&1
status=$(
    (
	( "${cmd}"${color:+ ${color}} "${@}"; echo $? >&4 ) \
	| less -+c -F -R 1>&3
    ) 4>&1
)
exit $status
