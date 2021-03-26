#!/bin/bash
i=1
cat myfile | while read myline
do
echo "第$i行: $myline"
i=$[ $i + 1]
done
