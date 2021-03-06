#!/bin/bash
# Very ugly way to generate input for cgo -godefs

# Change working dir to directory of this script
cd "${0%/*}" || exit 1

echo 'package go_fs_playground
// #include "ext4_simple.h"
import "C"' > ext4_simple.go

grep "^struct" ext4_simple.h|awk '{
raw[1] = $2;
while ( match($2, /(.*)([a-z0-9])_([a-z])(.*)/, cap)){
    $2 = cap[1] cap[2] toupper(cap[3]) cap[4];
    }
print "type " $2 " C.struct_" raw[1]
}' >> ext4_simple.go

echo "const (" >> ext4_simple.go
grep "^#define" ext4_simple.h|awk 'NF > 2 {print $2 " = C." $2}' >> ext4_simple.go
echo ")" >> ext4_simple.go

go tool cgo -godefs ext4_simple.go > ../ext4_defs.go
