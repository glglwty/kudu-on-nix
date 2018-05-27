# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
set -e
. $stdenv/setup
mkdir -p $out/lib
mkdir -p $out/include
arches="default avx2"
to_link=""
for arch in $arches ; do
arch_flag=""
if [ "$arch" == "avx2" ]; then
    arch_flag="-mavx2"
fi
tmp_obj=bitshuffle_''${arch}_tmp.o
dst_obj=bitshuffle_''${arch}.o
gcc $arch_flag -std=c99 -I$src/include -O3 -DNDEBUG -fPIC -c \
    "$src/src/bitshuffle_core.c" \
    "$src/src/bitshuffle.c" \
    "$src/src/iochain.c"
# Merge the object files together to produce a combined .o file.
ld -r -o $tmp_obj bitshuffle_core.o bitshuffle.o iochain.o
# For the AVX2 symbols, suffix them.
if [ "$arch" == "avx2" ]; then
    # Create a mapping file with '<old_sym> <suffixed_sym>' on each line.
    nm --defined-only --extern-only $tmp_obj | while read addr type sym ; do
    echo ''${sym} ''${sym}_''${arch}
    done > renames.txt
    objcopy --redefine-syms=renames.txt $tmp_obj $dst_obj
else
    mv $tmp_obj $dst_obj
fi
to_link="$to_link $dst_obj"
done
gcc $to_link -llz4 -shared -o $out/lib/libbitshuffle.so
cp $src/src/bitshuffle.h $src/src/bitshuffle_core.h $out/include/