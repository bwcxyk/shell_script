#!/bin/bash
while true ; do
for o in $(journalctl -n 10 -o cat | grep -o  -E 'orphaned pod \\"((\w|-)+)\\' | cut -d" " -f3 | grep -oE '(\w|-)+' | uniq); do
  p="/var/lib/kubelet/pods/$o/volumes"
  if [ -d $p ] ; then
    echo "Orphaned Pod $o Found"
    echo "Removing $p/kubernetes.io~csi/"*"/vol_data.json"
    rm -rf "$p/kubernetes.io~csi/"*"/vol_data.json"
    loop=1
    echo "$p/kubernetes.io~csi/"*"/vol_data.json Removed"
    echo "Rechecking"
  else
    echo "No Orphaned Pods Found"
    loop=2
  fi
done
if [ $loop = 1 ] ; then
  sleep 2
else
  echo "Exiting"
  break
fi
done
