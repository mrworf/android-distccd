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

# This file will setup the required path for distccd
export NDK_ROOT=$(cd /opt/ndk/android*/ ; pwd)
export NDK_BIN=${NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin/

# Now, generate fake wrappers
for F in ${NDK_BIN}/*; do
    NAME=$(basename $F)
    ln -s /wrapper/distcc_wrapper.sh /wrapper/bin/${NAME}
done

export PATH=/wrapper/bin/:$PATH

cat /image.info
echo ""

echo "Generating compiler match list"
mkdir /root/.distcc
find $BIN1 -type f -executable >  /DISTCC_CMDLIST
export DISTCC_CMDLIST=/DISTCC_CMDLIST
chmod 666 /DISTCC_CMDLIST

echo "DISTCCd running on port 3632 (please use -p to expose the port) accepting upto ${DISTCC_JOBS} jobs"
distccd --no-detach --daemon --allow 0.0.0.0/0 --log-stderr --jobs ${DISTCC_JOBS} 
