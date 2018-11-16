# DownloadHGDP
Framework to download and collate WGS data for several hundred [*Human Genome Diversity Project*](https://en.wikipedia.org/wiki/Human_Genome_Diversity_Project) samples.

Thousands of *GRCh38* BAM files for HGDP samples are publicly available on the [European Nucleotide Archive](https://www.ebi.ac.uk/ena/data/view/PRJEB6463). The framework here downloads alignments in key regions of interest from each of these files. It then merges the data for all ~730 samples into a single sorted and indexed BAM file, where the resulting alignments have proper read groups that directly correspond to HGDP sample identifiers. 

Please not that although the current framework works, care is required to delete and redownload files that failed to appropriately extract alignments


```
# Populate regions_of_interest.bed with the regions from which you'd like to extract alignments
# The file should contain three columns: CHROM, START and END.
@ It shouldn't have any header lines and CHROM should be a number (1-22), X or Y without a chr prefix

cd by_sample_bams
./download_regions

# Delete files in which some alignments were not properly extracted
./download_regions.sh
# Continue these iterations until all files are properly downloaded
cd ../

cd merged_bam
./merge_bams.sh
cd ../

# The final merged BAM will be in merged_bam/merged_alns.sorted.bam

```
