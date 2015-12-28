#!/bin/bash

# get Apache PIDs
pid=$(ps -e -o pid,cmd | grep '[/]usr/sbin/apache' | awk '{ print $1 }')

# kill all Apache PIDs
kill -9 $pid

# restart Apache
/usr/sbin/service apache2 start
