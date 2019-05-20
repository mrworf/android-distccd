#!/bin/sh
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

# Due to Android clang issue, we quiet the unused-arguments warning
# or the -Werror will cause distcc to fail. It has no impact on
# resulting code.
#
/usr/bin/distcc_org $@ -Qunused-arguments
exit $?
