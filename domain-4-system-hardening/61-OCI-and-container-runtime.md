# Crictl
## Configure crictl
```sh
cat /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: true
```

## Get images
```sh
crictl images
```

## Pull image
```sh
crictl pull busybox
```

# Runc
## View help
```sh
runc --help
```

## Configure runc
```sh
# Install Docker
apt-get update
apt  install -y docker.io  

# create the top most bundle directory
mkdir /mycontainer
cd /mycontainer

# create the rootfs directory
mkdir rootfs

# export busybox via Docker into the rootfs directory
docker export $(docker create busybox) | tar -C rootfs -xvf -

# Generate runc config.json
cd ..
runc spec
```

## Launch container

```sh
runc run demo-container
```
Directly enter in container 


## In other console

```sh
# Get the list of containers
runc list
```

```sh
# Get process in the container
runc ps demo-container
```


