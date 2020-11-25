#!/bin/bash
set -eo pipefail
source ~/tianff/codes/202011_XasWater32Qe/local_env.sh

cd $work_dir
rm -f tm_tt.dat
for N in $loopfile
do
echo "$N `head -n 1 Oxygen_${N}/tm.dat`" >> tm_tt.dat
#cat Oxygen_${N}/tm.dat >> tm_tt.dat
done
