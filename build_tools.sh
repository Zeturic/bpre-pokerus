#!/bin/sh

unset CC
unset CXX
unset AS
unset AR
unset OBJCOPY
unset STRIP
unset NM
unset RANLIB

make -C tools/scaninc $BUILD_TOOLS_TARGET
make -C tools/preproc $BUILD_TOOLS_TARGET
