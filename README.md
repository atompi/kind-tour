## pull images

```
bash pull.sh
```

## create cluster

```
kind delete cluster --name kind
sudo rm -rf /data/kind
mkdir -p /data/kind/worker1/{data,local-path-provisioner}
rm -rf ~/.kube/config
mkdir -p charts/ingress-nginx/certs
# create self signature certs follow https://github.com/atompi/self-signature or copy from SNIT
bash create.sh
```

## delete cluster

```
kind delete cluster --name kind
```

## PS

```
curl -LO "https://dl.k8s.io/release/v1.31.2/bin/linux/amd64/kubectl"
wget https://github.com/kubernetes-sigs/kind/releases/download/v0.25.0/kind-linux-amd64 -O kind
wget https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz
tar -zxf helm-v3.16.2-linux-amd64.tar.gz
mv linux-amd64/helm ./helm
rm -r linux-amd64
rm helm-v3.16.2-linux-amd64.tar.gz
chmod +x kubectl kind helm
sudo ln -sf $PWD/kubectl /usr/local/bin/
sudo ln -sf $PWD/kind /usr/local/bin/
sudo ln -sf $PWD/helm /usr/local/bin/
```
