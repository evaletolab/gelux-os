#! /bin/bash
# $Id: init.sh,v 1.2 2005/11/17 19:15:23 evaleto Exp $

. /MorphixCD/etc/morphix.d/color.sh
. /MorphixCD/etc/morphix.d/functions.sh

for file in /morphix/rc.m/*
do
  ebegin "Running $file"
  $file start
  eend $?
done

