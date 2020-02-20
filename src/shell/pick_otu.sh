#!/bin/bash
#===================================================
#Author:     Yang
#Email:      yiluheihei@gmail.com
#Date:       2019-01-20
#Description: validate mapping file, add qiime labels,
# and pick high confidence otu    
#===================================================

home_dir=".."
cd $home_dir

output_dir="output_silva"
if [ -e $output_dir ]; then
	rm -rf $output_dir
fi
mkdir -p $output_dir

# validate mapping file
validate_mapping_file.py -m mapping.txt -o ${output_dir}/validate_mapping -b -p -j Description

# add qiime labels
add_qiime_labels.py -i clean_data/first_epr -m mapping.txt -c InputFileName -o ${output_dir}/add_labels

# pick open reference otu
start_time=`date "+%Y-%m-%d %H:%M:%S"`
echo "pick otu start at $start_time"

pick_open_reference_otus.py -i ${output_dir}/add_labels/combined_seqs.fna -o ${output_dir}/pick_otus -s 0.1 -m usearch61 -r silva132_97.fna

end_time=`date "+%Y-%m-%d %H:%M:%S"`
echo "pick otu ending at $end_time"

duration=$(($(date +%s -d "${end_time}") - $(date +%s -d "${start_time}")))
echo "pick otu takes $((duration/60)) minutes"

