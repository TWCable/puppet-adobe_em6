#!/bin/bash

. /data/tools/functions.include

[ $# -lt 2 ] && usage_missing_mode_arg $0 admin_password
setCqPropsByOption $1

CQ5_HOST=localhost
CQ5_USER=admin
CQ5_PASS=$2

#echo "Files older then 7 days"
#find ${CQ_DS_DIR}/* -mtime +7 -type f

#echo -n "Database Bytes to be saved: "
#find ${CQ_DS_DIR}/* -mtime +7 -type f -exec ls -l {} \; | awk '{ s+=$5 } END { print s }'

echo "Running GCs againts:"
echo -e "\tHOST: ${CQ5_HOST}"
echo -e "\tPORT: ${CQ5_PORT}"
echo -e "\tUSER: ${CQ5_USER}"

echo "Changing DataStoreGarbageCollectionDelay value to 1"
curl -v -u "${CQ5_USER}:${CQ5_PASS}" -X POST --data value=1 -H "Referer: http://${CQ5_HOST}:${CQ5_PORT}/system/console/jmx/com.adobe.granite%3Atype%3DRepository/a/DataStoreGarbageCollectionDelay" -H "X-Requested-With: XMLHttpRequest" http://${CQ5_HOST}:${CQ5_PORT}/system/console/jmx/com.adobe.granite%3Atype%3DRepository/a/DataStoreGarbageCollectionDelay

echo "Running JAVA Garbage Collection"
curl -v -u "${CQ5_USER}:${CQ5_PASS}" -X POST --data command=gc -H "Referer: http://${CQ5_HOST}:${CQ5_PORT}/system/console/memoryusage" -H "X-Requested-With: XMLHttpRequest" http://${CQ5_HOST}:${CQ5_PORT}/system/console/memoryusage

echo "Running JCR Garbage Collection (delete=false)"
curl -v -u "${CQ5_USER}:${CQ5_PASS}" -X POST --data delete=false -H "Referer: http://${CQ5_HOST}:${CQ5_PORT}/system/console/jmx/com.adobe.granite%3Atype%3DRepository" http://${CQ5_HOST}:${CQ5_PORT}/system/console/jmx/com.adobe.granite%3Atype%3DRepository/op/runDataStoreGarbageCollection/java.lang.Boolean

echo "Running JCR Garbage Collection (delete=true)"
curl -v -u "${CQ5_USER}:${CQ5_PASS}" -X POST --data delete=true -H "Referer: http://${CQ5_HOST}:${CQ5_PORT}/system/console/jmx/com.adobe.granite%3Atype%3DRepository" http://${CQ5_HOST}:${CQ5_PORT}/system/console/jmx/com.adobe.granite%3Atype%3DRepository/op/runDataStoreGarbageCollection/java.lang.Boolean

echo "Reverting DataStoreGarbageCollectionDelay value to 7"
curl -v -u "${CQ5_USER}:${CQ5_PASS}" -X POST --data value=7 -H "Referer: http://${CQ5_HOST}:${CQ5_PORT}/system/console/jmx/com.adobe.granite%3Atype%3DRepository/a/DataStoreGarbageCollectionDelay" -H "X-Requested-With: XMLHttpRequest" http://${CQ5_HOST}:${CQ5_PORT}/system/console/jmx/com.adobe.granite%3Atype%3DRepository/a/DataStoreGarbageCollectionDelay
