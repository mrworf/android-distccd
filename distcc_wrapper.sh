#!/bin/bash
#
# This file is part of android-distccd (https://github.com/mrworf/android-distccd).
#
# android-distccd is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# android-distccd is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with android-distccd.  If not, see <http://www.gnu.org/licenses/>.
#

TOOLS=${NDK_BIN}
ROOT=${NDK_ROOT}
COMMAND=$(basename $0)
ARGS=()
# Find the relevant argument
RPATH=
for ARG in "$@" ; do
        if [ ${ARG:0:16} = "--gcc-toolchain=" ] ; then
                RPATH="$(echo "${ARG}" | sed 's/\([^=]*\)=\(.*\)\(toolchains.*\)/\2/g')"
                break
        fi
done
STR="$@"
ARGS="${STR//"${RPATH}"/"${NDK_ROOT}/"}"

if [ "${COMMAND:0:5}" = "clang" ]; then
    ARGS="$ARGS -Qunused-arguments"
fi
${TOOLS}/${COMMAND} ${ARGS}
exit $?