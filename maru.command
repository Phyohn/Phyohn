#!/bin/zsh
#chmod u+x xxx/maru.command
#xattr -rc xxx/maru.command
cd `dirname $0`
cat .../*.c.*j* | sed 's/ //g'| sed -e 's/\:443\,\"path\"\:\"\/api\/v1\.7\.4/\n/g' | >new.txt
loop=($(cat new.txt | grep '/hall/machines","query":"date'|sed 's/.*hall_code=\([0-9]\{4\}\)&model_code=\([0-9]\{6\}\)".*202[0-9]\{5\}\(.*\)\(202[0-9]\{5\}\)\(.*\)\(202[0-9]\{5\}\).*/\6,\2,\1,\5/g'))

echo ${#loop[*]} #elementcounter
echo -n > data.txt # be empty

#Data part.Split one variable $code into elements.no sort and uniqe
for ((i=1; i<1+`echo ${#loop[*]}`; i++))
do echo ${loop[i]} > tmp.txt
code=($(grep -ao '^[0-9]\{8\},[0-9]\{6\},[0-9]\{4\}' tmp.txt))
cat tmp.txt | sed 's/machine_number/\n/g'| grep 'machine_id' | tr -d \\\\\"\: | sed -E "s/^([0-9]{4}),machine_id(.*),number_of_all_starts([0-9]{1,}|null),availabletrue.*([0-9]{1,}|null),number_of_rbs([0-9]{1,}|null),.*/\2,\1,\3,\4,\5,$code/g" | sed 's/null/0/g' | tr -cd '0123456789\n\,' | tee -a data.txt
done

grep -c '' data.txt #row counter

#slump part. multi
cat new.txt | grep '/machine\/slump\/compare\"\,\"query\"\:\"date' | sed 's/machine_id/\n/g' | grep 'max\\\"\:[1-9]000\,\\\"min\\\"\:-[1-9]000'| tr -d \}\,\{\\\"time\\\"\:\\\" | tr -d \\\"\,\\\"value\\\"\: |sed 's/\\\\\\/,/g' | tr -d \\ | sed -E 's/\[\]/,0/g' | sed 's/\(.*\)x.*\([0-9]\{4\}\)nsbd.*\,\([-0-9]\{1,\}\).*/\3,\1/g' | sed -E 's/([-0-9]{1,}),[^0-9]*([0-9]*)[^0-9]*([0-9]*)[^0-9]*([0-9]*)[^0-9]*([0-9]*).*/\2\3\4\5,\1/g'| tee tmp.txt
#slump part2 solo
cat new.txt | grep 'machine\/slump\"\,\"query\"\:\"date' | sed 's/.*machine_id\=\(.*\)HTTP\/1\.1\"\,\"headers\".*value\\\"\:\([-0-9]\{1,\}\)\(.*\)/\2,\1/g'| sed -E 's/\%20//g'|sed -E 's/([-0-9]{1,}),[^0-9]*([0-9]*)[^0-9]*([0-9]*)[^0-9]*([0-9]*)[^0-9]*([0-9]*).*/\2\3\4\5,\1/g'  | tee -a tmp.txt

sort -uk 1n -t , tmp.txt | > slump.txt

#machine part
ksyu=($(cat new.txt | grep -m 1 'machine/models?hall' | sed -E 's/\{\\\"model_code\\\"\:\\\"/\n/g' | sed -E 's/^([0-9]{6}).*model_name\\\"\:\\\"(.*)\\\"\,\\\"count\\.*/\1,\2/g' | grep '\\u' | sed -E 's/\\\\/\\/g'))

echo ${#ksyu[*]} #counter
#✨🔥unicode escape to utf-8japanese by zsh echo
echo $ksyu | sed 's/ /\n/g' | tee ksyu.txt

python maru.py

import cv2
import base64
import numpy as np
from PIL import Image
import io
import os
import pathlib
import datetime
import time
import platform
import codecs
import pandas as pd

slump = pd.read_csv('slump.txt',names=('koyu','range'))
data = pd.read_csv('data.txt',names=('koyu','number','start','B','R','day','model','hole'))
merged = pd.merge(slump, data)
#duplicate
merged = merged.drop_duplicates()

ksyu = pd.read_csv('ksyu.txt', header=None)
#tolist 冗長
model = (ksyu.iloc[:,0]).values.tolist()
kisyumei = (ksyu.iloc[:,1]).values.tolist()
#🚀
merged = merged.replace(model,kisyumei)
comp = merged.reindex(columns=('number','start','B','R','range','day','model'))
comp = comp.sort_values('number')

#origfilename
now = datetime.datetime.now()
strdate = now.strftime('%m:%d %H:%M:%S')
comp.to_csv(f'../{strdate}.csv', header=False, index=False)
quit()

print "完了"
