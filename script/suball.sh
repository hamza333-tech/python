#!/bin/sh

##
## This shell script applies M4 to all of the TPL files in a source directory and creates
## from them TQL files in a target directory.  
##
## Arguments: a file of macros for a specific environment
##            a directory of source files (*.tpl)
##            a directory into which to write the corresponding TQL files (*.tql)
##
## Note: The target directory will be created if it does not alredy exist
##
## Example: from the tql directory run:
##   ./script/suball.sh ./env-m4/a_o_pg_ST.m4 ./a_o ./a_o_ST
##
## which will create the directory tql/a_o_ST and fill it with the tql files.
##

mkdir -p $3
for FILE in $(ls $2); 
do 
 
echo $FILE; 
V=$(echo $FILE | wc -c);
#echo $V
srcpath=$2"/"$FILE
echo $srcpath
num=$((V - 4))
#echo $num
newfile=$3"/"$(echo $FILE | cut -c1-$num)"tql" 
echo $newfile
m4 $1 $srcpath > $newfile
done

##m4 dev.m4 artnet_ops.core.GalleryType_LOAD.tql
