#!/bin/bash

while read cram_line
do
    study=`echo $cram_line | awk '{print $1}'`
    if [ "$study" = "study_accession" ]
    then
	continue
    fi

    path=`echo $cram_line | awk '{print $15}'`
    sample=`echo $path | sed "s/\// /g" | awk '{print $NF}' | sed "s/\.cram//"`
    path=`echo $path | sed "s/#/%23/"`
    path="ftp://$path"
    name=`echo $cram_line | awk '{print $3}'`

    nlines=`grep $name ../samples_to_exclude.txt | wc -l`
    if [ $nlines -eq 0 ]
    then
	if [ ! -e $sample.bam ]
	then
	    echo $path $sample $name
	fi
    fi
done < ../PRJEB6463.txt | xargs -L 1 -P 30 ./download_sample.sh
