# ChuZone - DevOps POC Project

Projet DevOps complet incluant CI/CD, Infrastructure as Code, Kubernetes et GitOps.

## 📋 Structure du Projet

```
devops/
├── src/                    # Application React
├── .github/workflows/      # GitHub Actions (CI/CD)
├── terraform/              # Infrastructure AWS (IaC)
├── gitops/                 # Manifests Kubernetes (GitOps)
└── scripts/                # Scripts d'installation et configuration
```

## 🚀 Phase 1 : Intégration Continue (GitHub Actions)

### Prérequis
- Compte GitHub
- Compte Docker Hub
- Secrets GitHub configurés :
  - `DOCKER_USERNAME` : Votre nom d'utilisateur Docker Hub
  - `DOCKER_PASSWORD` : Votre token Docker Hub

### Configuration des Secrets GitHub

1. Allez dans votre dépôt GitHub > Settings > Secrets and variables > Actions
2. Ajoutez les secrets suivants :
   - `DOCKER_USERNAME`
   - `DOCKER_PASSWORD`

### Workflow CI

Le workflow `.github/workflows/ci.yml` :
- Se déclenche sur Pull Request vers `main`
- Build l'application
- Exécute les tests unitaires (bloquants)
- Build une image Docker
- Push l'image sur Docker Hub avec le tag `1.0.0-RC1`

### Utilisation

```bash
# Installer les dépendances
npm install

# Lancer les tests
npm test

# Build local
npm run build

# Tester le Dockerfile localement
docker build -t chuzone-app:test .
docker run -p 8080:80 chuzone-app:test
```

## 🏷️ Phase 2 : Promotion de Release

Le workflow `.github/workflows/release-approve.yml` :
- Se déclenche automatiquement lors du merge d'une PR vers `main`
- Récupère l'image `1.0.0-RC1` depuis Docker Hub
- Retag l'image en `1.0.0` sans reconstruction
- Push l'image `1.0.0` sur Docker Hub
- Crée un tag Git `v1.0.0`

## ☁️ Phase 3 : Infrastructure AWS & Kubernetes

### Prérequis
- AWS CLI configuré
- Terraform installé
- Une clé SSH AWS créée

### Création de la clé SSH AWS

```bash
# Générer une clé SSH
ssh-keygen -t rsa -b 4096 -f ~/.ssh/k8s-keypair

# Importer dans AWS
aws ec2 import-key-pair --key-name k8s-keypair --public-key-material fileb://~/.ssh/k8s-keypair.pub
```

### Configuration Terraform

1. Copier le fichier de variables :
```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

2. Modifier `terraform/terraform.tfvars` selon vos besoins :
```hcl
aws_region          = "us-east-1"
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
instance_type      = "t2.medium"
key_pair_name      = "k8s-keypair"
```

### Déploiement de l'Infrastructure

```bash
cd terraform

# Initialiser Terraform
terraform init

# Vérifier le plan
terraform plan

# Appliquer (créer les ressources)
terraform apply

# Récupérer les outputs
terraform output
```

### Configuration Kubernetes

Une fois les instances créées :

1. **Sur le master node** :
```bash
# Se connecter au master
ssh -i ~/.ssh/k8s-keypair.pem ubuntu@<MASTER_PUBLIC_IP>

# Vérifier que le cluster est initialisé
kubectl get nodes

# Récupérer la commande kubeadm join
kubeadm token create --print-join-command
```

2. **Sur chaque worker node** :
```bash
# Se connecter au worker
ssh -i ~/.ssh/k8s-keypair.pem ubuntu@<WORKER_PUBLIC_IP>

# Exécuter la commande kubeadm join (du master)
sudo kubeadm join <MASTER_IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>
```

3. **Vérification** (sur le master) :
```bash
kubectl get nodes
# Les 3 nœuds doivent être en état Ready
```

## 🔄 Phase 4 : GitOps avec Argo CD

### Installation d'Argo CD

```bash
# Exécuter le script d'installation
chmod +x scripts/install-argocd.sh
./scripts/install-argocd.sh

# Ou manuellement
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Exposer Argo CD (NodePort)
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
kubectl get svc argocd-server -n argocd
```

### Installation NGINX Ingress Controller

```bash
chmod +x scripts/install-ingress-nginx.sh
./scripts/install-ingress-nginx.sh
```

### Configuration du Dépôt GitOps

1. **Créer un nouveau dépôt Git** pour les manifests Kubernetes
2. **Copier les fichiers du dossier `gitops/`** dans ce dépôt
3. **Modifier les fichiers** :
   - `gitops/deployment.yaml` : Remplacer `YOUR_DOCKER_USERNAME` par votre nom d'utilisateur Docker Hub
   - `gitops/ingress.yaml` : Remplacer `YOUR_DOMAIN.duckdns.org` par votre domaine DuckDNS
   - `gitops/argocd-application.yaml` : Mettre à jour l'URL du dépôt GitOps

4. **Push vers la branche `main`** du dépôt GitOps

### Configuration DuckDNS

1. Créer un compte sur [DuckDNS](https://www.duckdns.org)
2. Créer un domaine (ex: `chuzone`)
3. Noter votre token
4. Utiliser le script pour mettre à jour l'IP :
```bash
chmod +x scripts/duckdns-update.sh
./scripts/duckdns-update.sh chuzone YOUR_TOKEN
```

### Création de l'Application Argo CD

```bash
# Appliquer la configuration Argo CD Application
kubectl apply -f gitops/argocd-application.yaml

# Ou créer manuellement via Argo CD CLI
argocd app create chuzone-app \
  --repo https://github.com/YOUR_USERNAME/YOUR_GITOPS_REPO.git \
  --path gitops \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace examen-26 \
  --sync-policy automated \
  --self-heal \
  --auto-prune
```

### Accès à l'Application

1. **Via Argo CD UI** :
   - URL : `http://<MASTER_IP>:<ARGOCD_NODEPORT>`
   - Username : `admin`
   - Password : (récupérer avec `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`)

2. **Via Ingress (DNS)** :
   - Une fois l'Ingress configuré et DuckDNS pointant vers l'IP publique
   - Accéder à : `https://YOUR_DOMAIN.duckdns.org`

## 📝 Notes Importantes

- **Secrets** : Aucun secret ne doit être commité dans Git. Utiliser les Secrets GitHub et les Secrets Kubernetes
- **Version Kubernetes** : Le projet utilise Kubernetes v1.34.0
- **Namespace** : L'application est déployée dans le namespace `examen-26`
- **Image Docker** : Utilisez l'image `1.0.0` (stable) pour le déploiement, pas la RC

## 🔧 Dépannage

### Problèmes Kubernetes

```bash
# Vérifier l'état des pods
kubectl get pods -n examen-26

# Voir les logs
kubectl logs -n examen-26 <pod-name>

# Décrire un pod pour debug
kubectl describe pod -n examen-26 <pod-name>
```

### Problèmes Argo CD

```bash
# Vérifier l'état d'Argo CD
kubectl get pods -n argocd

# Voir les logs Argo CD
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server

# Forcer une synchronisation
argocd app sync chuzone-app
```

## 📚 Ressources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [DuckDNS](https://www.duckdns.org)

## 🎯 Validation du Projet

✅ Phase 1 : CI Pipeline fonctionnel avec tests et Docker
✅ Phase 2 : Promotion automatique de release
✅ Phase 3 : Cluster Kubernetes opérationnel avec 3 nœuds
✅ Phase 4 : Déploiement GitOps avec Argo CD et DNS public

---

**Auteur** : Projet DevOps ING5 SE  
**Date** : 2024
