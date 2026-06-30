MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BOUNDARY"

--BOUNDARY
Content-Type: application/node.eks.aws

---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: ${cluster_id}
    apiServerEndpoint: ${cluster_endpoint}
    certificateAuthority: ${cluster_ca}
    cidr: ${service_cidr}

--BOUNDARY
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
# Fix for EKS Local Clusters: nodeadm generates --cluster-name but
# the IAM authenticator on local clusters requires --cluster-id (UUID).
# This script patches the kubeconfig after nodeadm generates it.

if [[ "${cluster_id}" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; then
  # Wait for nodeadm to generate the kubeconfig
  for i in $(seq 1 30); do
    [ -f /var/lib/kubelet/kubeconfig ] && break
    sleep 2
  done
  if [ -f /var/lib/kubelet/kubeconfig ]; then
    sed -i 's/--cluster-name/--cluster-id/' /var/lib/kubelet/kubeconfig
    systemctl restart kubelet
  fi
fi

--BOUNDARY--
