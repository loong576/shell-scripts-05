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
