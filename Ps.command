#!/bin/zsh
#chmod u+x xxx/Ps.command
#xattr -rc xxx/Ps.command
cd `dirname $0`
#orgfilename
touch `date +%d%H%M-%S`.csv
newcsv=$(ls -1t *.csv | head -1)
array=($(grep -a 'pageMax\\\"\:\d\}\"' /xxx/*.har | sed 's/ //g' | cut -c 1-6000 ))
echo ${#array[*]} #counter
#冗長
newarray=($(for ((i=1; i<300; i++));do echo ${array[i]};done))
echo ${#newarray[*]} #counter

#冗長 try Parallel processing
for ((i=1;i<500;i++))
do echo ${newarray[i]} > tmp.txt
grep -ao 'dai\\\"\:\\\"[0-9]\{4\}\\\"\,\\\"c' tmp.txt | grep -ao '[0-9]\{4\}' | tr "\n" "," | >>$newcsv
grep -ao '累計ゲーム\\\"\,\\\"item\\\"\:\[[0-9]\{1,\}\,\|累計ゲーム\\\"\,\\\"item\\\"\:\[null\,[0-9]\{1,\}\,' tmp.txt | grep -ao '[0-9]\{1,\}' | tr "\n" "," | >>$newcsv
grep -ao 'BIG\\\"\,\\\"item\\\"\:\[[0-9]\{1,\}\|BIG\\\"\,\\\"item\\\"\:\[null\,[0-9]\{1,\}' tmp.txt | grep -ao '[0-9]\{1,\}' | tr "\n" "," | >>$newcsv
grep -ao 'REG\\\"\,\\\"item\\\"\:\[[0-9]\{1,\}\|REG\\\"\,\\\"item\\\"\:\[null\,[0-9]\{1,\}' tmp.txt | grep -ao '[0-9]\{1,\}' | tr "\n" "," | >>$newcsv
grep -ao 't\\\"\:[0-9]\{1,\}\,\\\"value\\\"\:[-0-9]\{1,\}\,\\\"YMD_biz\\\"\:[0-9]\{8\}\,\\\"L' tmp.txt | head -1 | grep -ao '\:[-0-9]\{1,\}\,\\\"Y' | grep -ao '[-0-9]\{1,\}' | tr "\n" "," | >>$newcsv
grep -ao 't\\\"\:[0-9]\{1,\}\,\\\"value\\\"\:[-0-9]\{1,\}\,\\\"YMD_biz\\\"\:[0-9]\{8\}\,\\\"L' tmp.txt | head -1 | grep -ao 't\\\"\:[0-9]\{1,\}\,' | grep -ao '[0-9]\{1,\}' | tr "\n" "," | >>$newcsv
grep -ao 'name\\\"\:\\\"\D\+\\\"\,' tmp.txt | grep -ao '[^name\\\"\:\,]\+' | >>$newcsv
done

sort -uk 1n -t "," $newcsv | > tmp.txt
er=($( cut -f 1 -d "," tmp.txt ))
daiban="null"
for ((i=1;i<1+`echo ${#er[*]}`;i++))
do
test $daiban = null && daiban=$er[i]
if [ $daiban -eq $er[i] ]; then
echo "ok$er[i]"
daiban=$((daiban + 1))
else
	while [ $daiban -ne $er[i] ]
	do
	echo $daiban
	daiban=`expr 1 + $daiban`
	done
daiban=`expr 1 + $daiban`
echo "ok$er[i]"
fi
done
cat tmp.txt > $newcsv
exit
