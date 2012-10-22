#!/bin/bash
# Copyright 2010 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

. ${HOME}/etc/shell.conf
. ${SHINCLUDE}/lg-functions
if [ -f "${LG_SAVERLOCK}" ]; then
    if [ "$( stat -c '%Z' "${LG_SAVERLOCK}" )" -ge "$( date --date="${LG_SAVERLOCK_MAX} seconds ago" +'%s' )" ]; then
        echo "lock encountered, adios"
        exit 0
    else
        echo "removing lock aged beyond ${LG_SAVERLOCK_MAX} seconds"
        rm -vf "${LG_SAVERLOCK}"
    fi
fi

list=${TOUCHSCRQRF:-/var/www/queries.txt}
out=${EARTH_QUERY}
# if touring the moon or mars, replace "earth" in this egrep
count=$( egrep -c '^earth.*' $list )
previous_file="/tmp/tour-previous.tmp"
previous=$( cat ${previous_file} 2>/dev/null )

# if reached last entry, start over
if [ ${previous:-1} -ge ${count} ]; then
    previous=0
    echo -n "${previous}" >${previous_file}
fi

new_query=$(( ${previous:-1}+1 ))
# if you'd like to tour the moon or mars, replace "earth" in this awk cmd
#query=$( awk -F'@' "/^earth/ {if (NR==${new_query}) print \$NF}" $list )
if [ "${LG_SCREENSAVER}" == "true" ]; then
    awk -F'@' "/^earth/ {if (NR==${new_query}) print \$NF}" $list | tee ${out}
    echo ${new_query} >${previous_file}
else
    echo "LG_SCREENSAVER=${LG_SCREENSAVER}, so:
    1 - not dropping line ${new_query} into ${out} 
    2 - not advancing to next line of ${list}"
fi

