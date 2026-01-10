# 🚀 Guide de Démarrage Rapide

## ✅ Vérification des Prérequis

Avant de commencer, assurez-vous d'avoir :

- [ ] Node.js 18+ installé (`node --version`)
- [ ] npm installé (`npm --version`)
- [ ] Git installé (`git --version`)
- [ ] Docker installé (`docker --version`)
- [ ] Compte GitHub avec un dépôt créé
- [ ] Compte Docker Hub
- [ ] Terraform installé (pour Phase 3) (`terraform --version`)
- [ ] AWS CLI configuré (pour Phase 3) (`aws --version`)
- [ ] Compte AWS avec credentials configurés

## 📋 Plan d'Action Séquentiel

### ÉTAPE 1 : Préparation Locale (5 min)

```bash
# 1. Installer les dépendances du projet
npm install

# 2. Vérifier que tout fonctionne localement
npm test          # Tests doivent passer ✅
npm run build     # Build doit réussir ✅

# 3. Tester le Dockerfile localement
docker build -t chuzone-app:test .
docker run -d -p 8080:80 --name chuzone-test chuzone-app:test
# Ouvrir http://localhost:8080 dans votre navigateur
docker stop chuzone-test && docker rm chuzone-test
```

### ÉTAPE 2 : Phase 1 - Configuration CI/CD (10 min)

#### 2.1. Créer un dépôt GitHub

```bash
# Si vous n'avez pas encore créé le dépôt
git init
git add .
git commit -m "Initial commit: DevOps POC project"
git branch -M main
git remote add origin https://github.com/VOTRE_USERNAME/VOTRE_REPO.git
git push -u origin main
```

#### 2.2. Configurer les Secrets GitHub

1. Allez sur GitHub.com → Votre dépôt → **Settings** → **Secrets and variables** → **Actions**
2. Cliquez sur **New repository secret**
3. Ajoutez ces secrets :

   **Secret 1 :**
   - Name: `DOCKER_USERNAME`
   - Value: Votre nom d'utilisateur Docker Hub

   **Secret 2 :**
   - Name: `DOCKER_PASSWORD`
   - Value: Votre token Docker Hub (créez-le sur hub.docker.com → Account Settings → Security → New Access Token)

#### 2.3. Tester le Workflow CI

```bash
# Créer une branche de feature
git checkout -b feature/test-ci

# Faire un petit changement
echo "# Test CI" >> TEST.md
git add TEST.md
git commit -m "Test: Trigger CI workflow"
git push origin feature/test-ci

# Créer une Pull Request sur GitHub
# Le workflow CI devrait se déclencher automatiquement
# Vérifier dans GitHub → Actions que le workflow passe ✅
```

#### 2.4. Merger vers main (déclenche Phase 2)

```bash
# Une fois la PR approuvée, merger vers main
# Le workflow release-approve.yml créera automatiquement :
# - Image 1.0.0 sur Docker Hub
# - Tag Git v1.0.0
```

### ÉTAPE 3 : Phase 2 - Vérification Release (2 min)

```bash
# Vérifier que les images sont sur Docker Hub
docker pull VOTRE_DOCKER_USERNAME/chuzone-app:1.0.0-RC1
docker pull VOTRE_DOCKER_USERNAME/chuzone-app:1.0.0

# Vérifier le tag Git
git fetch --tags
git tag -l
# Vous devriez voir v1.0.0 ✅
```

### ÉTAPE 4 : Phase 3 - Infrastructure AWS (30-45 min)

#### 4.1. Créer une clé SSH AWS

```bash
# Générer une clé SSH
ssh-keygen -t rsa -b 4096 -f ~/.ssh/k8s-keypair -N ""

# Importer dans AWS (remplacer us-east-1 par votre région)
aws ec2 import-key-pair \
  --key-name k8s-keypair \
  --public-key-material fileb://~/.ssh/k8s-keypair.pub \
  --region us-east-1
```

#### 4.2. Configurer Terraform

```bash
cd terraform

# Créer le fichier de configuration
cat > terraform.tfvars <<EOF
aws_region          = "us-east-1"  # Changez si nécessaire
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
instance_type      = "t2.medium"
key_pair_name      = "k8s-keypair"
EOF

# Initialiser Terraform
terraform init

# Vérifier le plan (ne crée rien encore)
terraform plan

# Si tout est OK, créer l'infrastructure
terraform apply
# Tapez 'yes' quand demandé

# Notez les IPs sorties (sauvegardez-les !)
terraform output
```

#### 4.3. Attendre l'Initialisation des Instances (5-10 min)

Les scripts user_data s'exécutent automatiquement, mais cela prend du temps.

```bash
# Vérifier que les instances sont running
aws ec2 describe-instances --filters "Name=tag:Name,Values=k8s-master,k8s-worker1,k8s-worker2" --query "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value|[0],State.Name,PublicIpAddress]"
```

#### 4.4. Se Connecter au Master et Configurer

```bash
# Récupérer l'IP du master
cd terraform
MASTER_IP=$(terraform output -raw master_public_ip)

# Se connecter
ssh -i ~/.ssh/k8s-keypair ubuntu@$MASTER_IP

# Une fois connecté au master :
# 1. Vérifier que Kubernetes est initialisé
kubectl get nodes

# 2. Si pas encore prêt, attendre quelques minutes puis :
sudo systemctl status kubelet

# 3. Une fois le master Ready, récupérer la commande join
kubeadm token create --print-join-command
# ⚠️ COPIEZ CETTE COMMANDE - vous en aurez besoin pour les workers
```

#### 4.5. Joindre les Workers au Cluster

Dans un nouveau terminal (gardez la session master ouverte) :

```bash
# Worker 1
cd terraform
WORKER1_IP=$(terraform output -raw worker1_public_ip)
ssh -i ~/.ssh/k8s-keypair ubuntu@$WORKER1_IP

# Sur le worker, exécuter la commande join (celle copiée du master)
sudo kubeadm join <MASTER_IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>

# Répéter pour Worker 2 (nouveau terminal)
WORKER2_IP=$(terraform output -raw worker2_public_ip)
ssh -i ~/.ssh/k8s-keypair ubuntu@$WORKER2_IP
# Exécuter la même commande join
```

#### 4.6. Vérifier le Cluster

Retour sur le master (ou configurez kubectl localement) :

```bash
# Sur le master
kubectl get nodes
# Vous devriez voir 3 nœuds, tous en état Ready ✅

# Copier le kubeconfig pour utiliser kubectl localement
mkdir -p ~/.kube
# Sur votre machine locale :
scp -i ~/.ssh/k8s-keypair ubuntu@$MASTER_IP:~/.kube/config ~/.kube/config

# Tester localement
kubectl get nodes
```

### ÉTAPE 5 : Phase 4 - GitOps avec Argo CD (20-30 min)

#### 5.1. Installer Argo CD

```bash
# Sur votre machine (avec kubectl configuré)
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Attendre que tout soit prêt (2-3 minutes)
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Exposer Argo CD
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
ARGOCD_PORT=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[?(@.name=="server")].nodePort}')

# Récupérer le mot de passe admin
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
# ⚠️ Notez ce mot de passe !

# Accéder à Argo CD
MASTER_IP=$(cd terraform && terraform output -raw master_public_ip)
echo "Argo CD URL: http://$MASTER_IP:$ARGOCD_PORT"
echo "Username: admin"
```

#### 5.2. Installer NGINX Ingress

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Attendre
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s
```

#### 5.3. Préparer le Dépôt GitOps

```bash
# 1. Créer un nouveau dépôt GitHub pour GitOps
# (allez sur GitHub.com et créez un nouveau dépôt vide, ex: chuzone-gitops)

# 2. Modifier les manifests dans gitops/
cd gitops

# Modifier deployment.yaml - remplacer YOUR_DOCKER_USERNAME
# Modifier ingress.yaml - remplacer YOUR_DOMAIN.duckdns.org
# Modifier argocd-application.yaml - remplacer l'URL du dépôt GitOps

# 3. Initialiser et push le dépôt GitOps
git init
git add .
git commit -m "Initial GitOps manifests"
git branch -M main
git remote add origin https://github.com/VOTRE_USERNAME/chuzone-gitops.git
git push -u origin main
```

#### 5.4. Configurer DuckDNS

```bash
# 1. Créer un compte sur https://www.duckdns.org
# 2. Créer un domaine (ex: chuzone)
# 3. Noter votre token

# 4. Mettre à jour l'IP
MASTER_IP=$(cd ../terraform && terraform output -raw master_public_ip)
curl "https://www.duckdns.org/update?domains=chuzone&token=VOTRE_TOKEN&ip=$MASTER_IP"

# 5. Vérifier que ça fonctionne
curl http://chuzone.duckdns.org
```

#### 5.5. Créer l'Application Argo CD

```bash
# Modifier gitops/argocd-application.yaml avec votre URL de dépôt GitOps
# Puis appliquer :
kubectl apply -f gitops/argocd-application.yaml

# Vérifier dans Argo CD UI ou :
kubectl get application -n argocd
argocd app get chuzone-app
```

#### 5.6. Accéder à l'Application

```bash
# Via NodePort directement
MASTER_IP=$(cd terraform && terraform output -raw master_public_ip)
curl http://$MASTER_IP:30080

# Ou via votre domaine DuckDNS (une fois l'Ingress configuré)
curl http://chuzone.duckdns.org
```

## 🎯 Checklist Finale

- [ ] Tests locaux passent
- [ ] Docker build fonctionne localement
- [ ] Secrets GitHub configurés
- [ ] Workflow CI passe sur GitHub
- [ ] Images Docker sur Docker Hub (1.0.0-RC1 et 1.0.0)
- [ ] Tag Git v1.0.0 créé
- [ ] Infrastructure AWS créée (3 EC2)
- [ ] Cluster Kubernetes opérationnel (3 nœuds Ready)
- [ ] Argo CD installé et accessible
- [ ] Dépôt GitOps créé et pushé
- [ ] Application Argo CD configurée avec auto-sync
- [ ] DuckDNS configuré
- [ ] Application accessible via URL publique

## ⚠️ Problèmes Courants

### Les tests échouent localement
```bash
# Vérifier Node.js version
node --version  # Doit être 18+

# Réinstaller les dépendances
rm -rf node_modules package-lock.json
npm install
```

### Docker build échoue
```bash
# Vérifier Docker
docker info

# Nettoyer
docker system prune -a
```

### Terraform erreur de credentials
```bash
# Vérifier AWS credentials
aws sts get-caller-identity

# Configurer si nécessaire
aws configure
```

### Kubernetes nodes pas Ready
```bash
# Sur chaque nœud, vérifier :
sudo systemctl status kubelet
sudo journalctl -xeu kubelet

# Vérifier le CNI (Flannel)
kubectl get pods -n kube-flannel
```

### Argo CD ne se connecte pas au repo
```bash
# Vérifier que le repo est public ou configurer les credentials
# Dans Argo CD UI : Settings > Repositories > Add Repo
```

---

**Besoin d'aide ?** Consultez `README.md` pour plus de détails ou `SETUP.md` pour la configuration avancée.
