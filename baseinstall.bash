## "Scripted" setup of kubernetes cluster for cllound native PG

## Test setup:
# Oracle Virtual Box
# 1 Virtual Linux (CentOS 9 - redhat deviant) with 4 virtual CPUs and 8 GB RAM
# Network: NAT, port forward 1333 to 22 (connect to localhost, port 1333 to logon)

## Other things to remember/nice to have
#
# sudo dnf install git
#
# make link to psql in newly installed postgresql server from /usr/local/bin  (ln -s)
#
#

## INSTALL ##


# install KIND
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.31.0/kind-linux-amd64

chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# install kubectl
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.35/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.35/rpm/repodata/repomd.xml.key
EOF

sudo yum install -y kubectl


# install helm
sudo dnf install -y helm


# install docker
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker


# create cluster
kind create cluster --name pg
kubectl get nodes
kubectl get -A pods


# CNPG Operator
kubectl apply --server-side -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.28/releases/cnpg-1.28.1.yaml
kubectl get nodes
kubectl get -A pods
kubectl get deployment -n cnpgsystem cnpg-controller-manager

# CNPG plugin
curl -sSfL \
  https://github.com/cloudnative-pg/cloudnative-pg/raw/main/hack/install-cnpg-plugin.sh | \
  sudo sh -s -- -b /usr/local/bin

#curl -L https://github.com/cloudnative-pg/cloudnativepg/releases/download/v1.28.0/kubectl-cnpg_1.28.1_linux_x86_64.rpm --output kube-plugin.rpm
#sudo dnf --disablerepo=* localinstall -y kube-plugin.rpm

# Deploy PG cluster
curl -o cluster-example.yaml https://cloudnative-pg.io/docs/assets/files/cluster-example-0a961e59ba2e2313c983c3386be1d7e7.yaml
cat cluster-example.yaml

kubectl apply -f cluster-example.yaml
kubectl get pods -o wide
echo "When 'kubectl get pods -o wide' show 3 cluster nodes running"
echo "you can check status with:"
echo "kubectl cnpg status cluster-example"

read -p "Press enter to continue"

kubectl cnpg status cluster-example


