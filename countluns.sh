#!/sbin/sh
# Author Nyka Jaroslaw 
# ver 0.3 b
#
# Script for faster count lun size
# and filesystem usage by project DB name on HPUX
#
# Tested version on HP-UX B.11.31 U ia64
#
# exampe:
# luncount.sh test
#
# output:
# ./luncount.sh test
#     test    24401 61312
# v 0.2b add debug permanent and remove -i from grep
# v 0.3b add Gb floor output
#        +-- the best run this script from little for
#        +-- ./luncountAll.sh
#        +-- db.list



vgname=$1
hostname=`hostname`

#grep all vgnames and cut lvs
devvg=`mount | grep $vgname | awk '{print $3}' | cut -d "/" -f1-3| sort | uniq`

#Make new list of mount points
#for mountp in `mount | grep -i $vgname | awk '{print $1}'`;do
#               printf "%-8s %8s \n" $vgname $mountp
#done

#count all File System size useage by mount point with vgname = $fsize
#mount -l | grep $vgname

fsize=`mount -l | grep $vgname | awk '{printf $1 " "}' | xargs df -Pk | awk 'NR>1 {sum+=$2};END {printf "%5.0f\n",sum/1024/1024}'`
sumvgsize=0

#make look by all vgnames involve by project db
for i in $devvg;do
		#multiply PE size and Total PE, delete line with Free words, awk cut 4 column for PE size and 2 column for Total PE
		vgsize=`vgdisplay $i | grep -E "PE Size|Total PE"|grep -v "Free" | awk 'FNR ==1{printf $4 "*" } FNR == 2 {print  $3}'| bc`

		#this echo is for debug
#        echo PVSIZE=:$i = $vgsize
		#sum counted vgsize per vg
		sumvgsize=`echo "$sumvgsize + $vgsize/1024"|bc`
done;

#echo "all data in MB"
#printf "%-8s %8s %4s\n" "vgname" "SumVgSize" "FS size"
printf "%-8s %8s %4s\n" $vgname $sumvgsize $fsize
#printf "%-8s %8s %4s\n" $vgname $sumvgsize $fsize >>logs.out
