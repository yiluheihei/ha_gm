#!/bin/bash
#===================================================
#Author:     Yang
#Email:      yiluheihei@gmail.com
#Date:       2019-03-20
#Description: Generate otus for use in picrust
#===================================================

home_dir=".."
cd $home_dir
# 去除低丰度otu
filter_otus_from_otu_table.py -i output/pick_outs/day_all/otu_table_mc2_w_tax_no_pynast_failures.biom -o output/preprocess_otu/open_otu.biom --min_count_fraction 0.00005

# 选择样本
filter_samples_from_otu_table.py -i output/preprocess_otu/open_otu.biom --sample_id_fp keep_samples.txt -o output/preprocess_otu/open_otu_28.biom

# closed otu
filter_otus_from_otu_table.py -i output/preprocess_otu/open_otu_28.biom -o output/preprocess_otu/closed_otu_table.biom --negate_ids_to_exclude -e 97_otus.fasta

# 去除为0的otu
filter_otus_from_otu_table.py -i output/preprocess_otu/closed_otu_table.biom -o output/preprocess_otu/picrust.biom -n 1

biom summarize-table -i output/preprocess_otu/picrust.biom -o output/preprocess_otu/picrust_summary.txt
