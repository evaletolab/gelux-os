#!/bin/bash
#
# Copyright by Evalet Olivier 
# Distributed under the terms of the GNU General Public License v2
#
#



# clean directories
find /var/log -type f -exec rm {} \\;
find /var/run -type f -exec rm {} \\;
        
# remove installer
apt-get -qq remove gelux-node-installer 2>/dev/null
