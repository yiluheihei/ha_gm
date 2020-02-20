#!/bin/bash
#===================================================
#Author:     Yang
#Email:      yiluheihei@gmail.com
#Date:       2019-01-21
#Description: remove low confidence otu, summary otu 
#table, and convert it to otu tab-delimited tsv tables.
#para: $1, the min fraction of a otu reads to the total 
#sequencen, required
#===================================================

if [ ! -n "$1" ]; then
	echo "you must specify the first para to specify th fraction of the total sequence count"
	exit 1
fi

home_dir=".."
cd $home_dir

if [ ! -e output/preprocess_otu ]; then
	mkdir -p output/preprocess_otu
fi

# remove low confidence otu
filter_otus_from_otu_table.py -i output/pick_otus/otu_table_mc2_w_tax_no_pynast_failures.biom -o output/preprocess_otu/otu_$1.biom --min_count_fraction $1

# summary otu table
biom summarize-table -i output/preprocess_otu/otu_$1.biom -o output/preprocess_otu/otu_summary_$1.txt

# convert to tab-delimited tsv
biom convert -i output/preprocess_otu/otu_$1.biom -o output/preprocess_otu/otu_table_$1.txt --to-tsv --header-key taxonomy

# convert to json
biom convert -i output/preprocess_otu/otu_table_$1.txt -o output/preprocess_otu/out_table_$1.json --table-type="OTU table" --to-json
