#!/bin/bash

path=$1
sample=$2

samtools view -H $path > $sample.sam
while read line
do
    chrom=`echo $line | awk '{print $1}'`
    start=`echo $line | awk '{print $2}'`
    end=`echo $line   | awk '{print $3}'`
    samtools view $path "chr"$chrom:$start-$end >> $sample.sam
done < ../regions_of_interest.bed

samtools sort -n -O SAM $sample.sam | uniq -u | samtools sort - > $sample.bam
rm $sample.sam

cram_index=`echo $path | sed "s/\// /g" | awk '{print $NF}'`
rm $cram_index.crai
