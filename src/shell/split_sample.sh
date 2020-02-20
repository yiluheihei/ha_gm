#!/bin/bash
#===================================================
#Author:     Yang
#Email:      yiluheihei@gmail.com
#Date:       2019-01-19
#Description: 结果共90个样本，其中有30个是第一次实验结果，
# 60个是第二次实验结果。把它们分别拷贝到first_epr,
# second_epr文件夹内。
#===================================================
group=("HA" "CR")
day=(0 14 28)

for g in ${group[@]}; do
    for d in ${day[@]}; do
        for i in $(seq 1 10); do
            cp -r ../clean_data/${g}.${d}.${i} ../clean_data/first_epr
        done
    done
done

for g in ${group[@]}; do
    for d in ${day[@]}; do
        for i in $(seq 11 15); do
            cp -r ../clean_data/${g}.${d}.${i}  ../clean_data/second_epr
        done
    done
done

