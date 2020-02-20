#!/bin/bash
#===================================================
#Author:     Yang
#Email:      yiluheihei@gmail.com
#Date:       2019-01-19
#Description: qiime中add_qiime_labels需要各fasta文件在同一目录下
# 把所有样本fasta文件拷贝到文件夹first_expr, second_epr中仅有
# 第一阶段30个样本的结果
#===================================================
for file in ../clean_data/first_epr/*; do
    if [ -d $file ]; then
        cp $file/*fna ../clean_data/first_epr
    fi
done

for file in ../clean_data/second_epr/*; do
    if [ -d $file ]; then
        cp $file/*fna ../clean_data/second_epr
		cp $file/*fna ../clean_data/first_epr
    fi
done
