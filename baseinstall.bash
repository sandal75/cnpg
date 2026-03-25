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
curl -L https://github.com/cloudnative-pg/cloudnativepg/releases/download/v1.28.0/kubectl-cnpg_1.28.1_linux_x86_64.rpm --output kube-plugin.rpm
sudo dnf --disablerepo=* localinstall -y kube-plugin.rpm

# Deploy PG cluster
curl -o cluster-example.yaml https://cloudnativepg.io/documentation/1.28/samples/cluster-example.yaml
cat cluster-example.yaml

kubectl apply -f cluster-example.yaml
kubectl get pods -o wide
kubectl cnpg status cluster-example

