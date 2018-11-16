#!/bin/bash

# Generate the required meta data
python generate_merge_metadata.py > merge_metadata.txt

# Construct a new BAM header by adding i) all relevant sequences and ii) all new read groups
echo "Generating a merged header"
samtools view -H ../by_sample_bams/18698_3#7.bam | grep ^@SQ > merged_alns.sam
count=0
while read line
do
    count=`expr $count + 1`
    rem=`expr $count % 100`
    if [ $rem -eq 0 ]
    then
	echo "    Processing file #$count"
    fi
    
    path=`echo $line | awk '{print $1}'`
    old_sample=`echo $line | awk '{print $2}'`
    run=`echo $line | awk '{print $3}'`
    new_sample=`echo $line | awk '{print $4}'`
    new_rg=`echo $line | awk '{print $5}' | sed "s/RG:Z://"`
    echo "@RG" "ID:$new_rg" "LB:$run" "SM:$new_sample" | awk -v OFS="\t" '{$1=$1; print $0}' >> merged_alns.sam
done < merge_metadata.txt
mv merged_alns.sam merged_header.sam

cp merged_header.sam merged_alns.sam

# Add the data for each alignment file one-by-one
# Replace the RG data on each line as we go and ensure all lines are converted
echo "Merging alignments"
count=0
while read line
do
    count=`expr $count + 1`
    rem=`expr $count % 100`
    if [ $rem -eq 0 ]
    then
	echo "    Processing file #$count"
    fi
    
    path=`echo $line | awk '{print $1}'`
    old_sample=`echo $line | awk '{print $2}'`
    run=`echo $line | awk '{print $3}'`
    new_sample=`echo $line | awk '{print $4}'`
    new_rg=`echo $line | awk '{print $5}'`
    
    # Extract the current RG id and ensure it applies to all records
    old_rg=`samtools view -H $path | grep ^@RG | tr '\t' '\n' | grep ^ID | sed "s/ID:/RG:Z:/"`
    nmissing=`samtools view $path | grep -v $old_rg | wc -l`
    if [ $nmissing -ne 0 ]
    then
	echo "Invalid RG found in $path. Exiting..."
	exit 1
    fi
    
    # Replace the RG id in all entries and output them to the merged SAM file
    samtools view $path | sed "s/$old_rg/$new_rg/" >> merged_alns.sam
done < merge_metadata.txt

# Sort and index the BAM
samtools sort -@ 5 -O BAM -o merged_alns.sorted.bam merged_alns.sam 
samtools index merged_alns.sorted.bam

# Remove the temporary files
rm merged_header.sam
rm merged_alns.sam
rm merge_metadata.txt

