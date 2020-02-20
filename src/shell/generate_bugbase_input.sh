#Author:     Yang
#Email:      yiluheihei@gmail.com
#Date:       2019-03-23
#Description: Generate otus biom for use in bugbase
#===================================================
filter_otus_from_otu_table.py -i ../output/preprocess_otu/open_otu_28.biom -o ../output/preprocess_otu/bugbase.biom -n 1
biom convert -i ../output/preprocess_otu/bugbase.biom -o ../output/preprocess_otu/bugbase_biom.txt --to-tsv --header-key taxonomy
biom convert -i ../output/preprocess_otu/bugbase_biom.txt -o ../output/preprocess_otu/bugbase_json.biom --table-type="OTU table" --to-json --process-obs-metadata taxonomy