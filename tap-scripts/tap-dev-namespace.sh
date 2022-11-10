
#read -p "Enter custom registry url (harbor/azure registry etc): " registry_url
#read -p "Enter custom registry user: " registry_user
#read -p "Enter custom registry password: " registry_password

#!/bin/bash
source var.conf

export TAP_REGISTRY_SERVER=$registry_url
export TAP_REGISTRY_USER=$registry_user
export TAP_REGISTRY_PASSWORD=$registry_password
#export TAP_DEV_NAMESPACE="default"

tanzu secret registry add registry-credentials --server $registry_url \
--username $registry_user --password $registry_password --namespace  "${TAP_DEV_NAMESPACE}"

cat <<EOF | kubectl -n "${TAP_DEV_NAMESPACE}" apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: tap-registry
  annotations:
    secretgen.carvel.dev/image-pull-secret: ""
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: e30K
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: default
secrets:
  - name: registry-credentials
imagePullSecrets:
  - name: registry-credentials
  - name: tap-registry
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: default-permit-deliverable
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: deliverable
subjects:
  - kind: ServiceAccount
    name: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: default-permit-workload
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: workload
subjects:
  - kind: ServiceAccount
    name: default
EOF