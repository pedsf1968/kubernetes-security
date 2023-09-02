# Question 16 -  Static Analysis

Following are the two files of deployment and Dockerfile. Modify this file to remove security configuration and store it in the following path:

/tmp/secure-pod.yaml
/tmp/secure-Dockerfile
Note: Do not add/remove lines, just modify existing lines.

POD Configuration (Fix 1 security misconfiguration)

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
      privileged: true
      readOnlyRootFilesystem: true
Dockerfile (fix 2 security misconfiguration)

The application requires Ubuntu 16.04 image. Fix two security misconfiguration

FROM ubuntu:latest
COPY apps /opt/apps/
RUN opkg update
RUN useradd app-user 
USER root
CMD ["/opt/apps/loop_app"]