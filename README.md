## 一、专题背景

最近使用了个自动化平台（详见[自动化运维平台Spug测试](https://blog.51cto.com/3241766/2537675)）进行每周的变更，效果很不错，平台将大量重复繁琐的操作通过脚本分发方式标准化自动化了，平台核心是下发到各个服务器的shell脚本，感觉有必要对shell脚本做个总结，所以有了写本专题的想法。本专题将结合运维实际介绍shell脚本的各项用法，预计10篇左右，将包括系统巡检、监控、ftp上传下载、数据库查询、日志清理、时钟同步、定时任务等，里面会涉及shell常用语法、注意事项、调试排错等。

## 二、本文前言

本文是该专题的第五篇。

文章主要介绍如何在脚本执行时传参、如何对传入的参数做基本的处理、如何处理选项、怎样执行用户输出。

## 三、环境说明

| 主机名 |  操作系统版本   |      ip      |      备注       |
| :----: | :-------------: | :----------: | :-------------: |
| shell  | Centos 7.6.1810 | 172.16.7.100 | shell测试服务器 |

## 四、脚本测试

### 1.命令行参数

```bash
[root@shell param]# more test1.sh 
#!/bin/bash

name=$(basename $0)
total=$[ $4 * $5 ]

echo 这是第一个参数: $1
echo 这是第二个参数: $2
echo 这是第三个参数: $3
echo 这是第四个参数: $4
echo 这是第五个参数: $5

echo 脚本名称为 $name
echo $4乘以$5的值为 $total

[root@shell param]# ./test1.sh 1 a "b c" 4 5
这是第一个参数: 1
这是第二个参数: a
这是第三个参数: b c
这是第四个参数: 4
这是第五个参数: 5
脚本名称为 test1.sh
4乘以5的值为 20
```

![image-20210324151529584](https://i.loli.net/2021/03/26/duvTpHnLWtfRAgN.png)

传入的参数可以是数字、字符和字符串

 \$0 是脚本名， \$1是第一个参数， \$2 是第二个参数，依次类推，直到第九个参数 $9

### 2.判断参数个数

```bash
[root@shell param]# ./test1.sh 
./test1.sh:行4: *  : 语法错误: 期待操作数 （错误符号是 "*  "）
这是第一个参数:
这是第二个参数:
这是第三个参数:
这是第四个参数:
这是第五个参数:
脚本名称为 test1.sh
乘以的值为
```

当脚本执行时未加参数则执行报错，此时需要对脚本进行优化，可以使用特殊变量$#判断传入脚本的参数个数。

```bash
[root@shell param]# more test1.sh 
#!/bin/bash

if [ $# -ne 5 ]
then
    echo 参数个数有误，请重新输入
else
    name=$(basename $0)
    total=$[ $4 * $5 ]
    echo 这是第一个参数: $1
    echo 这是第二个参数: $2
    echo 这是第三个参数: $3
    echo 这是第四个参数: $4
    echo 这是第五个参数: $5
    echo 脚本名称为 $name
    echo $4乘以$5的值为 $total
fi
[root@shell param]# ./test1.sh 
参数个数有误，请重新输入
[root@shell param]# ./test1.sh  1 2 3 4
参数个数有误，请重新输入
[root@shell param]# ./test1.sh  1 2 3 
参数个数有误，请重新输入
[root@shell param]# ./test1.sh  1 2 3 4 5 6 
参数个数有误，请重新输入
[root@shell param]# ./test1.sh 1 a "b c" 4 5
这是第一个参数: 1
这是第二个参数: a
这是第三个参数: b c
这是第四个参数: 4
这是第五个参数: 5
脚本名称为 test1.sh
4乘以5的值为 20
```

![image-20210324152227970](https://i.loli.net/2021/03/26/8BepGaXgF6TJOrf.png)

只有传入的参数个数为5时脚本才能正常运行，避免因为参数个数传入有误造成脚本执行报错。

### 3.获取所有的参数

```bash
[root@shell param]# more test2.sh 
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
[root@shell param]# ./test2.sh  a b c
参数1 = a b c
参数1 = a
参数2 = b
参数3 = c
```

![image-20210324153824611](https://i.loli.net/2021/03/26/63LBsCDPXjWHcnp.png)

\$*和\$@都可以获取到左右的传入参数，区别是 \$\*变量会将所有参数当成单个参数，而 \$@变量会单独处理每个参数。

### 4.遍历参数

使用shift命令默认情况下它会将每个参数变量向左移动一个位置，可以使用这个方法遍历所有传入的参数。

```bash
[root@shell param]# more test3.sh 
#!/bin/bash
i=1
while [ -n "$1" ]
do
  echo "参数$i = $1"
  i=$[ $i + 1 ]
  shift
done
[root@shell param]# ./test3.sh  a b c
参数1 = a
参数2 = b
参数3 = c
```

![image-20210324162018725](https://i.loli.net/2021/03/26/ohpdsjwxT2E9MVe.png)

使用while先判断输入的参数1是否存在，如果非空则执行下面的操作：先输出参数$1，然后使用shift将参数\$2移动为新的\$1，如此循环，直至所有参数被遍历。

### 5.选项处理

```bash
[root@shell param]# more test4.sh
#!/bin/bash

name=$(basename $0)

case $1  in
'start')
        systemctl start docker
        ;;
'stop')
        systemctl stop docker
        ;;
'restart')
        systemctl restart docker
        ;;
'status')
        systemctl status docker
        ;;
*)    
        echo "Usage: sh $name {start|stop|restart|status}"
        exit 3
esac
[root@shell param]# ./test4.sh
Usage: sh test4.sh {start|stop|restart|status}
[root@shell param]# ./test4.sh abc
Usage: sh test4.sh {start|stop|restart|status}
[root@shell param]# ./test4.sh stop
[root@shell param]# ./test4.sh start
[root@shell param]# ./test4.sh status
```

![image-20210325095340188](https://i.loli.net/2021/03/26/Dl8VaNRj7ruXQCW.png)

case 语句会检查每个参数是不是有效选项。如果是的话，就运行对应 case 语句中的命令。

当参数为start、stop、restart和status时执行对应的命令，若为其它参数则提醒需输入正确命令并退出。

### 6.用户输入

#### 6.1基本读取

使用read可以从标准输入（键盘）或另一个文件描述符中接受输入，在收到输入后， read 命令会将数据放进一个变量。

```bash
[root@shell param]# more test5.sh 
#!/bin/bash
read  -n1 -p  "是否继续 Enter[Y/N]? " option

case $option in
Y | y) echo
echo "继续执行下一步: Hello World!";;
N | n) echo
echo "中断执行"
exit;;
esac
[root@shell param]# ./test5.sh 
是否继续 Enter[Y/N]? y
继续执行下一步: Hello World!
[root@shell param]# ./test5.sh 
是否继续 Enter[Y/N]? N
中断执行
```

![image-20210325164922501](https://i.loli.net/2021/03/26/ruyGgvtBDYiERhH.png)

 -p 选项可以指定提示符“是否继续 Enter[Y/N]?”，-n 选项和值 1 一起使用，告诉 read 命令在接受单个字符后退出。

#### 6.2隐藏读取

```bash
[root@shell param]# more test6.sh 
#!/bin/bash
read -t 5 -s -p "Enter your password: " pass
echo
echo "显示输入的密码： $pass "
[root@shell param]# ./test6.sh 
Enter your password: 
显示输入的密码： abc123! 

```

![image-20210325171358253](https://i.loli.net/2021/03/26/FUCMKJQgNTORtY4.png)

-s 选项可以避免在 read 命令中输入的数据出现在显示器上（实际上，数据会被显示，只是read 命令会将文本颜色设成跟背景色一样）

 -t 选项来指定一个计时器，即5秒钟后没输入退出程序。

#### 6.3文件读取

```bash
[root@shell param]# more test7.sh 
#!/bin/bash
i=1
cat myfile | while read myline
do
echo "第$i行: $myline"
i=$[ $i + 1]
done
[root@shell param]# more myfile 
abc123!
123abc!
!123abc
abc!123
123!abc
!abc123
[root@shell param]# ./test7.sh 
第1行: abc123!
第2行: 123abc!
第3行: !123abc
第4行: abc!123
第5行: 123!abc
第6行: !abc123
```

![image-20210325172041797](https://i.loli.net/2021/03/26/PLzo7C15IAH49TB.png)

本例使用 read 命令来读取文件数据，对文件使用 cat 命令，将结果通过管道直接传给含有 read 的 while 命令，也可以使用输出重定向方式，参见[shell脚本专题(04)：循环](https://blog.51cto.com/3241766/2652205)中的“2.批量新增用户”

## 五、本文总结

参数传入是脚本执行时的一个重要的方式，可以让脚本的执行更加灵活方便，交互的界面使脚本执行更具可读性。本文介绍了三种交互方式：命令行参数、选项和read方式。掌握了这三种方式会让脚本更优雅功能性更强。





&nbsp;

&nbsp;


**更多请点击：**[shell专题](https://blog.51cto.com/3241766/category18.html)
