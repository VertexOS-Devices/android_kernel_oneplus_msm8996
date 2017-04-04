#!/bin/bash
export Changelog=Changelog.txt

if [ -f $Changelog ];
then
    rm -f $Changelog
fi

touch $Changelog

echo ${bldppl}"Listing down the new stuff..."${txtrst}

for i in $(seq 5);
do
export After_Date=`date --date="$i days ago" +%m-%d-%Y`
k=$(expr $i - 1)
    export Until_Date=`date --date="$k days ago" +%d-%b-%Y`

    # Line with after --- until was too long for a small ListView
    echo '====================' >> $Changelog;
    echo  "     "$Until_Date    >> $Changelog;
    echo '====================' >> $Changelog;
    git log --pretty=format:"%h  %s" --decorate --after=$After_Date --until=$Until_Date >> $Changelog
    echo >> $Changelog;
    echo >> $Changelog;
done

sed -i 's/project/   */g' $Changelog
