#! /bin/bash
# $Id: init.sh,v 1.1.1.1 2004/09/24 15:27:16 mkalbere Exp $
for file in /morphix/rc.m/*
do
  echo "Running $file"
  $file start  1>/dev/null  
done
