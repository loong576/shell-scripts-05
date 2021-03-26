#!/bin/bash
read  -n1 -p  "是否继续 Enter[Y/N]? " option

case $option in
Y | y) echo
echo "继续执行下一步: Hello World!";;
N | n) echo
echo "中断执行"
exit;;
esac
