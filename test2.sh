#!/bin/bash
i=1
for param in "$*"
do
echo "参数$i = $param"
i=$[ $i + 1 ]
done

j=1
for param in "$@"
do
echo "参数$j = $param"
j=$[ $j + 1 ]
done
