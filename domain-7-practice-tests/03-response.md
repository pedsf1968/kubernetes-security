# audit-policy.yaml
## Log all namespace events at RequestResponse

apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  - level: RequestResponse
    resources:
    - group: ""
      resources: ["namespaces"]

## Log all PODS events at Request.
  - level: Request
    resources:
    - group: ""
      resources: ["pods"]

## No configmaps related events should be logged.
  - level: None
    resources:
    - group: ""
      resources: ["configmaps"]

## All other events should be stored at metadata level.
 - level: Metadata

## File audit-policy.yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  - level: None
    resources:
    - group: ""
      resources: ["configmaps"]
  - level: Request
    resources:
    - group: ""
      resources: ["pods"]
  - level: RequestResponse
    resources:
    - group: ""
      resources: ["namespaces"]
  - level: Metadata

# kube-apiserver.yaml configuration
## There should be maximum log files of 3.
--audit-log-maxbackup=3

## Policy configuration should be available at /etc/kubernetes/audit-policy.yaml
- --audit-policy-file=/etc/kubernetes/audit-policy.yaml
  
## Logs should be stored in a /var/log/audit.log
- --audit-log-path=/var/log/audit.log

## volumeMounts:
  - mountPath: /etc/kubernetes/audit-policy.yaml
    name: audit
    readOnly: true
  - mountPath: /var/log/
    name: audit-log
    readOnly: false

## volumes:
- name: audit
  hostPath:
    path: /etc/kubernetes/audit-policy.yaml
    type: File

- name: audit-log
  hostPath:
    path: /var/log/
    type: DirectoryOrCreate