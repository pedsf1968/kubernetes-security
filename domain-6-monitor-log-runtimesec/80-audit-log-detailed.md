
#### Step 1 Create a directory for storing audit logs and audit policy:
```sh
cd /etc/kubernetes/
mkdir audit
```
#### Step 2 - Mount the directory as HostPath Volumes in kube-apiserver:
```sh

volumeMounts:
  - mountPath: /etc/kubernetes/audit/audit-policy.yaml
    name: audit
    readOnly: true
  - mountPath: /etc/kubernetes/audit/
    name: audit-log
    readOnly: false

volumes:
- name: audit
  hostPath:
    path: /etc/kubernetes/audit/audit-policy.yaml
    type: File
- name: audit-log
  hostPath:
    path: /etc/kubernetes/audit/
    type: DirectoryOrCreate

```
#### Step 3 - Add Auditing Related Configuration in kube-apiserver:
```sh
- --audit-policy-file=/etc/kubernetes/audit/audit-policy.yaml
- --audit-log-path=/etc/kubernetes/audit/audit.log
```

### Simple auditing policy audit-policy1.yaml
vim audit-policy.yaml
```sh
apiVersion: audit.k8s.io/v1 
kind: Policy
rules:
  - level: Metadata
    resources:
    - group: ""
      resources: ["secrets"]
```

### Remove logs for specific object and namespace audit-policy2.yaml

```sh
kubectl create namespace production
```
vim audit-policy.yaml

```sh
apiVersion: audit.k8s.io/v1 
kind: Policy
rules:
  - level: None
    resources:
    - group: ""
      resources: ["secrets"]
    namespaces: ["kube-system"]

  - level: Metadata
    resources:
    - group: ""
      resources: ["secrets"]
```
kube-apiserver must be restarted add label in manifest
vim /etc/kubernetes/manifests/kube-apiserver.yaml
```sh
  labels:
    component: kube-apiserver
    tier: control-plane
    modify: change01
  name: kube-apiserver
```

#### Remove logs from user kube-controller-manager audit-policy3.yaml

vim audit-policy.yaml

```sh
apiVersion: audit.k8s.io/v1
kind: Policy
rules:

  - level: None
    resources:
    - group: ""
      resources: ["secrets"]
    namespaces: ["kube-system"]

  - level: None
    users: ["system:kube-controller-manager"]
    resources:
    - group: ""
      resources: ["secrets"]

  - level: Metadata
    resources:
    - group: ""
      resources: ["secrets"]
```
vim /etc/kubernetes/manifests/kube-apiserver.yaml
```sh
  labels:
    component: kube-apiserver
    tier: control-plane
    modify: change02
  name: kube-apiserver
```

#### Change level Metadata to RequestResponse audit-policy4.yaml

vim audit-policy.yaml

```sh
apiVersion: audit.k8s.io/v1
kind: Policy
rules:

  - level: None
    resources:
    - group: ""
      resources: ["secrets"]
    namespaces: ["kube-system"]

  - level: None
    users: ["system:kube-controller-manager"]
    resources:
    - group: ""
      resources: ["secrets"]

  - level: RequestResponse
    resources:
    - group: ""
      resources: ["secrets"]
```
vim /etc/kubernetes/manifests/kube-apiserver.yaml
```sh
  labels:
    component: kube-apiserver
    tier: control-plane
    modify: change03
  name: kube-apiserver
```

```sh
tail -f audit.log
```
from other console
```sh
kubectl get secrets
kubectl create secret generic demo-secret --from-literal=admin=password
```

#### Omit stages RequestReceived audit-policy4.yaml

vim audit-policy.yaml

```sh
apiVersion: audit.k8s.io/v1
kind: Policy
omitStages:
  - "RequestReceived"

rules:

  - level: None
    resources:
    - group: ""
      resources: ["secrets"]
    namespaces: ["kube-system"]

  - level: None
    users: ["system:kube-controller-manager"]
    resources:
    - group: ""
      resources: ["secrets"]

  - level: RequestResponse
    resources:
    - group: ""
      resources: ["secrets"]
```
vim /etc/kubernetes/manifests/kube-apiserver.yaml
```sh
  labels:
    component: kube-apiserver
    tier: control-plane
    modify: change04
  name: kube-apiserver
```

#### Omit Change rules order audit-policy5.yaml

vim audit-policy.yaml

```sh
apiVersion: audit.k8s.io/v1
kind: Policy
omitStages:
  - "RequestReceived"

rules:

  - level: RequestResponse
    resources:
    - group: ""
      resources: ["secrets"]

  - level: None
    resources:
    - group: ""
      resources: ["secrets"]
    namespaces: ["kube-system"]

  - level: None
    users: ["system:kube-controller-manager"]
    resources:
    - group: ""
      resources: ["secrets"]
```

vim /etc/kubernetes/manifests/kube-apiserver.yaml
```sh
  labels:
    component: kube-apiserver
    tier: control-plane
    modify: change05
  name: kube-apiserver
```
We can see secrets data. we must use level:None rules before

#### Our Final Audit Policy:
vim audit-policy.yaml
```sh
apiVersion: audit.k8s.io/v1
kind: Policy
omitStages:
  - "RequestReceived"

rules:

  - level: None
    resources:
    - group: ""
      resources: ["secrets"]
    namespaces: ["kube-system"]

  - level: None
    users: ["system:kube-controller-manager"]
    resources:
    - group: ""
      resources: ["secrets"]

  - level: RequestResponse
    resources:
    - group: ""
      resources: ["secrets"]
```
