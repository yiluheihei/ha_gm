#!/bin/bash
#===================================================
#Author:     Yang
#Email:      yiluheihei@gmail.com
#Date:       2019-03-20
#Description: convert the qiime taxa tables to the file that is compatible with 
# lefse, picrust and bugbase.
#===================================================

# remove low confidence otu
filter_otus_from_otu_table.py -i data/raw/qiime/otu_table_mc2_w_tax_no_pynast_failures.biom \
-o data/processed/open_otu_biom --min_count_fraction 0.00005

# filter samples on  day 28 
filter_samples_from_otu_table.py -i data/processed/open_otu_biom \
--sample_id_fp data/raw/keep_samples.txt -o data/processed/open_otu_28.biom

# qimme to lefse
summarize_taxa.py -i data/processed/open_otu_28.biom \
-o data/processed/summaryize_taxa_L6 -m data/raw/mapping_new.txt --delimiter '|'

# qiime to picrust, 97_otus.fasta is the reference sequence of greengene database
# you should downloaded it from ftp://greengenes.microbio.me/greengenes_release/gg_13_5/gg_13_5_otus.tar.gz
filter_otus_from_otu_table.py -i data/processed/open_otu_28.biom \
-o data/processed/closed_otu_28.biom --negate_ids_to_exclude -e data/raw/97_otus.fasta
filter_otus_from_otu_table.py -i data/processed/closed_otu_28.biom \
-o data/processed/picrust.biom -n 1

# qiime to bugbase
filter_otus_from_otu_table.py -i data/processed/open_otu_28.biom \
-o data/processed/bugbase.biom -n 1

biom convert -i data/processed/bugbase.biom \
-o data/processed/bugbase.txt --to-tsv --header-key taxonomy

biom convert -i data/processed/bugbase.txt \
-o data/processed/bugbase_json.biom --table-type="OTU table" --to-json \
--process-obs-metadata taxonomy
