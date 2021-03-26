#!/bin/bash
i=1
while [ -n "$1" ]
do
  echo "参数$i = $1"
  i=$[ $i + 1 ]
  shift
done
