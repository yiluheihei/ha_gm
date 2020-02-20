#!/bin/bash
#===================================================
#Author:     Yang
#Email:      yiluheihei@gmail.com
#Date:       2019-04-09
#Description: Generate lefse input from qiime
#===================================================

home_dir=".."
cd $home_dir
summarize_taxa.py -i output/preprocess_otu/open_otu_28.biom -o output/preprocess_otu/summaryize_taxa_L6 -m mapping_0_14_28.txt --delimiter '|'
