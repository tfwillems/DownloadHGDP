import collections
import os.path
import pandas
import sys

def main():
    samples_to_exclude = set()
    data = open("../samples_to_exclude.txt", "r")
    for line in data:
        samples_to_exclude.add(line.strip())
    data.close()

    accession_to_hgdp = {}
    data = open("../sample_accession_to_HGDP.txt", "r")
    for line in data:
        tokens = line.strip().split()
        accession_to_hgdp[tokens[0]] = tokens[1]
    data.close()

    sample_counts = collections.defaultdict(int)
    ebi_df        = pandas.read_csv("../PRJEB6463.txt", sep="\t")
    for _,row in ebi_df.iterrows():
        sample = row["secondary_sample_accession"]
        if sample in samples_to_exclude:
            continue
    
        bam_path = "../by_sample_bams/" + row["submitted_ftp"].split("/")[-1].replace(".cram", ".bam")
        if not os.path.exists(bam_path):
            sys.stderr.write("WARNING: missing data for file %s\n"%(bam_path))
            continue

        hgdp_sample = accession_to_hgdp[row["secondary_sample_accession"]]
        if hgdp_sample not in sample_counts:
            sample_counts[hgdp_sample] = 0
        sample_counts[hgdp_sample] += 1

        new_rg_name = "RG:Z:" + hgdp_sample + "_" + str(sample_counts[hgdp_sample])
        print("\t".join([bam_path, row["secondary_sample_accession"], row["run_accession"], hgdp_sample, new_rg_name]))



if __name__ == "__main__":
    main()
