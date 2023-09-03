# Authorization Mode should be Node and RBAC
vim /etc/kubernetes/manifests/kube-apiserver.yaml

 - --authorization-mode=Node,RBAC

# AlwaysPullImages Admission controller must be enabled.
vim /etc/kubernetes/manifests/kube-apiserver.yaml

 - --enable-admission-plugins=NodeRestriction,AlwaysPullImages

# Anonymous Auth is set to false for Kubelet
vim /var/lib/kubelet/config.yaml

apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false

# Certificate Authentication is enabled for ETCD
 vim /etc/kubernetes/manifests/etcd.yaml

  - --client-cert-auth=true

