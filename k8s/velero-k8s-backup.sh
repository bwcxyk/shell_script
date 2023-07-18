#!/bin/bash
NS_NAME=$(kubectl get ns |awk '{if(NR>1){print $1}}')
DATE=$(date +%Y%m%d%H%M%S)
cd /data/velero/

for i in $NS_NAME;do
  /usr/local/bin/velero backup create ${i}-ns-backup-${DATE} \
  --include-cluster-resources=true \
  --include-namespaces ${i} \
  --kubeconfig=/root/.kube/config
done
