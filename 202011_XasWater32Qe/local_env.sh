#!/bin/bash
set -euo pipefail
source ~/tianff/codes/common/environment.sh
echo ==================================================================[local_env]
work_dir=~/tianff/202011_XasWater32Qe/server/
echo "work_dir=$work_dir"

qe_cohsex_water_bin=~/tianff/software/QuatumEspresso/qe_cohsex_water/bin/
echo "qe_cohsex_water_bin=$qe_cohsex_water_bin"

Templates_dir=~/tianff/202011_XasWater32Qe/server/Templates/
echo "Templates_dir=$Templates_dir"

O_num=32
echo "O_num=$O_num"

natoms=$[O_num*3]
echo "natoms=$natoms"

vbands=$[O_num*4]
echo "vbands=$vbands"

cbands=$[O_num*4]
echo "vbands=$cbands"

nbands=$[$vbands+$cbands]
echo "nbands=$nbands"

pseudo_dir=~/tianff/201903_XasIce8Qe/asist/zrsun/pseudo/
echo "pseudo_dir=$pseudo_dir"

celldm1=18.6655
echo "celldm1=$celldm1"

volume=`echo "${celldm1}^3"|bc`
echo "volume=$volume"

glines=?
echo "glines=$glines"

xascodes_bin=~/tianff/software/QuatumEspresso/xas-codes/
echo "xascodes_bin=${xascodes_bin}"

Oxygen1swf_dir=~/tianff/201903_XasIce8Qe/asist/zrsun/xas-ToTangfujie/Oxygen-1s-wf/
echo "Oxygen1swf_dir=${Oxygen1swf_dir}"

script_dir=~/tianff/codes/202011_XasWater32Qe/
echo "script_dir=${script_dir}"
echo ============================================================================
