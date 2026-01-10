# Guide de Configuration Rapide

## 🔐 Configuration des Secrets GitHub

### 1. Docker Hub Secrets

Dans votre dépôt GitHub, allez dans :
**Settings > Secrets and variables > Actions > New repository secret**

Ajoutez ces secrets :
- `DOCKER_USERNAME` : Votre nom d'utilisateur Docker Hub
- `DOCKER_PASSWORD` : Votre token Docker Hub (pas votre mot de passe)

Pour créer un token Docker Hub :
1. Connectez-vous à [Docker Hub](https://hub.docker.com/)
2. Allez dans **Account Settings > Security**
3. Cliquez sur **New Access Token**
4. Copiez le token généré

## 📦 Modification des Manifests GitOps

### 1. Remplacer les placeholders

Dans le dossier `gitops/`, modifiez ces fichiers :

#### `deployment.yaml`
```yaml
# Remplacer
image: YOUR_DOCKER_USERNAME/chuzone-app:1.0.0

# Par
image: votrenomdockerhub/chuzone-app:1.0.0
```

#### `ingress.yaml`
```yaml
# Remplacer
- host: YOUR_DOMAIN.duckdns.org

# Par
- host: votredomaine.duckdns.org
```

#### `argocd-application.yaml`
```yaml
# Remplacer
repoURL: https://github.com/YOUR_USERNAME/YOUR_GITOPS_REPO.git

# Par
repoURL: https://github.com/votreusername/votrerepo-gitops.git
```

## ☁️ Configuration AWS

### 1. Créer une clé SSH

```bash
# Générer une clé SSH
ssh-keygen -t rsa -b 4096 -f ~/.ssh/k8s-keypair

# Importer dans AWS EC2
aws ec2 import-key-pair \
  --key-name k8s-keypair \
  --public-key-material fileb://~/.ssh/k8s-keypair.pub \
  --region us-east-1
```

### 2. Configurer Terraform

```bash
cd terraform

# Créer terraform.tfvars
cat > terraform.tfvars <<EOF
aws_region          = "us-east-1"
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
instance_type      = "t2.medium"
key_pair_name      = "k8s-keypair"
EOF

# Initialiser et déployer
terraform init
terraform plan
terraform apply
```

## 🚀 Déploiement Kubernetes

### 1. Se connecter au Master Node

```bash
# Récupérer l'IP du master
cd terraform
MASTER_IP=$(terraform output -raw master_public_ip)

# Se connecter
ssh -i ~/.ssh/k8s-keypair ubuntu@$MASTER_IP
```

### 2. Sur le Master - Initialisation

Le script `master-init.sh` s'exécute automatiquement au démarrage, mais si besoin :

```bash
# Vérifier l'état
kubectl get nodes

# Si le cluster n'est pas initialisé :
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Configurer kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Installer Flannel CNI
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

### 3. Obtenir la commande kubeadm join

Sur le master :
```bash
kubeadm token create --print-join-command
```

Copiez cette commande pour l'utiliser sur les workers.

### 4. Sur les Workers - Joindre le cluster

```bash
# Se connecter au worker
cd terraform
WORKER1_IP=$(terraform output -raw worker1_public_ip)
ssh -i ~/.ssh/k8s-keypair ubuntu@$WORKER1_IP

# Exécuter la commande kubeadm join (copiée du master)
sudo kubeadm join <MASTER_IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>

# Répéter pour worker2
```

### 5. Vérification

Sur le master :
```bash
kubectl get nodes
# Les 3 nœuds doivent être Ready
```

## 🔄 Installation Argo CD

Sur le master node ou depuis votre machine avec kubectl configuré :

```bash
# Option 1 : Via script
chmod +x scripts/install-argocd.sh
./scripts/install-argocd.sh

# Option 2 : Manuellement
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Attendre que tout soit prêt
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Exposer Argo CD
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
ARGOCD_PORT=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[?(@.name=="server")].nodePort}')

# Récupérer le mot de passe admin
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

# Accéder à Argo CD
echo "Argo CD URL: http://$(terraform output -raw master_public_ip):$ARGOCD_PORT"
echo "Username: admin"
```

## 🌐 Configuration DNS (DuckDNS)

### 1. Créer un compte DuckDNS

1. Allez sur [DuckDNS](https://www.duckdns.org)
2. Connectez-vous avec votre compte (Google, GitHub, etc.)
3. Créez un domaine (ex: `chuzone`)
4. Notez votre token

### 2. Mettre à jour l'IP

```bash
# Récupérer l'IP publique du master
MASTER_IP=$(terraform output -raw master_public_ip)

# Mettre à jour DuckDNS (manuellement)
curl "https://www.duckdns.org/update?domains=chuzone&token=VOTRE_TOKEN&ip=$MASTER_IP"

# Ou utiliser le script
chmod +x scripts/duckdns-update.sh
./scripts/duckdns-update.sh chuzone VOTRE_TOKEN
```

### 3. Configurer un Cron Job (optionnel)

Pour mettre à jour automatiquement l'IP :

```bash
# Créer un cron job (sur le master ou votre machine)
crontab -e

# Ajouter cette ligne (mise à jour toutes les 5 minutes)
*/5 * * * * curl "https://www.duckdns.org/update?domains=chuzone&token=VOTRE_TOKEN"
```

## 📝 Création du Dépôt GitOps

1. **Créer un nouveau dépôt GitHub** (ex: `chuzone-gitops`)

2. **Copier les manifests** :
```bash
# Créer le dépôt GitOps
mkdir chuzone-gitops
cd chuzone-gitops

# Copier les fichiers
cp -r ../gitops/* .

# Modifier les placeholders (voir section ci-dessus)
# ...

# Initialiser Git
git init
git add .
git commit -m "Initial commit: GitOps manifests"
git branch -M main
git remote add origin https://github.com/votreusername/chuzone-gitops.git
git push -u origin main
```

3. **Créer l'Application Argo CD** :

```bash
# Modifier argocd-application.yaml avec votre URL de dépôt
# Puis appliquer :
kubectl apply -f gitops/argocd-application.yaml

# Ou via Argo CD CLI :
argocd app create chuzone-app \
  --repo https://github.com/votreusername/chuzone-gitops.git \
  --path gitops \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace examen-26 \
  --sync-policy automated \
  --self-heal \
  --auto-prune
```

## ✅ Checklist de Validation

- [ ] Secrets GitHub configurés (DOCKER_USERNAME, DOCKER_PASSWORD)
- [ ] Workflow CI testé (Pull Request vers main)
- [ ] Image Docker `1.0.0-RC1` pushée sur Docker Hub
- [ ] Workflow release testé (merge vers main)
- [ ] Image Docker `1.0.0` pushée sur Docker Hub
- [ ] Tag Git `v1.0.0` créé
- [ ] Infrastructure Terraform déployée (3 EC2)
- [ ] Cluster Kubernetes initialisé (master)
- [ ] 2 workers joints au cluster
- [ ] Tous les nœuds en état Ready
- [ ] Argo CD installé et accessible
- [ ] Dépôt GitOps créé avec manifests
- [ ] Application Argo CD configurée avec auto-sync
- [ ] DuckDNS configuré et pointant vers le cluster
- [ ] Ingress configuré pour l'accès DNS
- [ ] Application accessible via URL publique

---

**Note** : Remplacez tous les placeholders (`YOUR_*`, `VOTRE_*`) par vos valeurs réelles avant de déployer.
