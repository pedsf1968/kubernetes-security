
# secure-pod.yaml

vim /tmp/secure-pod.yaml
cat /tmp/secure-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  volumes:
  - name: sec-ctx-vol
    emptyDir: {}
  containers:
  - name: sec-ctx-demo
    image: busybox
    command: [ "sh", "-c", "sleep 1h" ]
    volumeMounts:
    - name: sec-ctx-vol
      mountPath: /data/demo
    securityContext:
      privileged: false
      readOnlyRootFilesystem: true

# secure-Dockerfile
vim /tmp/secure-Dockerfile

cat /tmp/secure-Dockerfile
FROM ubuntu:16.04
COPY apps /opt/apps/
RUN opkg update
RUN useradd app-user
USER app-user
CMD ["/opt/apps/loop_app"]
