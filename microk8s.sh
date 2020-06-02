#!/bin/sh
###
# MicroK8s + Rancher installer
##

# 輸入您的 email 
EMAIL=

# 如果您的環境不是在 GCP 請自行調整以下變數
EXTERNAL_IP=$(curl -s 169.254.169.254/computeMetadata/v1beta1/instance/network-interfaces/0/access-configs/0/external-ip)

sudo snap install microk8s --channel=1.18 --classic
sudo microk8s.enable dns dashboard storage ingress helm3 rbac

sudo sh -c 'echo "--allow-privileged=true" >> /var/snap/microk8s/current/args/kube-apiserver'
sudo systemctl restart snap.microk8s.daemon-apiserver.service

sudo microk8s.helm3 repo add jetstack https://charts.jetstack.io
sudo microk8s.kubectl create namespace cert-manager
sudo microk8s.kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
sudo microk8s.helm3 install cert-manager jetstack/cert-manager --namespace cert-manager --version v0.15.1 --set installCRDs=true

while [ `sudo microk8s.kubectl get po -n cert-manager | grep '1/1' | wc -l` -lt 3 ]
do
  sleep 5
  echo "等待 cert-manager 服務啟動 ..."
done

sudo microk8s.helm3 repo add rancher-stable https://releases.rancher.com/server-charts/stable
sudo microk8s.kubectl create namespace cattle-system
sudo microk8s.helm3 install rancher rancher-stable/rancher  --namespace cattle-system --set replicas=1 --set hostname=rancher.${EXTERNAL_IP}.nip.io --set ingress.tls.source=letsEncrypt --set letsEncrypt.email=${EMAIL}

while [ `sudo microk8s.kubectl get po -n cattle-system | grep ^rancher | grep '1/1' | wc -l` -eq 0 ]
do
  sleep 10
  echo "Rancher 啟動中請稍候 ... "
done

echo "----------------------------------------"
echo "安裝完成"
echo "現在您可以開啟 https://rancher.${EXTERNAL_IP}.nip.io"
echo "----------------------------------------"
