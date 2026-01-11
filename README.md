# ChuZone - Projet DevOps POC

Projet DevOps complet pour l'examen ING5 SE - Mise en place d'une chaîne CI/CD complète avec GitHub Actions, Terraform, Kubernetes et Argo CD.

## 📋 Structure du Projet

```
devops/
├── src/                      # Application React
├── .github/workflows/        # GitHub Actions (CI/CD)
├── terraform/                # Infrastructure AWS (IaC) - Phase 3
├── gitops/                   # Manifests Kubernetes (GitOps) - Phase 4
└── scripts/                  # Scripts d'installation
```

---

## ✅ Phase 1 : Intégration Continue (GitHub Actions) - COMPLÈTE

### Configuration Réalisée

- ✅ Application React avec 5 tests unitaires (Vitest)
- ✅ Dockerfile multi-stage avec Nginx
- ✅ Workflow GitHub Actions (`.github/workflows/ci.yml`)
  - Se déclenche sur Pull Request vers `main`
  - Build l'application
  - Exécute les tests unitaires (bloquants)
  - Build une image Docker
  - Push l'image sur Docker Hub avec le tag `1.0.0-RC1`

### Résultat

- ✅ Workflow CI opérationnel
- ✅ Image Docker : `hamdilh/chuzone-app:1.0.0-RC1` sur Docker Hub
- ✅ Tests : 5/5 passent

---

## ✅ Phase 2 : Promotion de Release (Versioning) - COMPLÈTE

### Configuration Réalisée

- ✅ Workflow GitHub Actions (`.github/workflows/release-approve.yml`)
  - Se déclenche automatiquement lors du merge d'une PR vers `main`
  - Récupère l'image `1.0.0-RC1` depuis Docker Hub
  - Retag l'image en `1.0.0` sans rebuild
  - Push l'image `1.0.0` sur Docker Hub
  - Crée un tag Git `v1.0.0`

### Résultat

- ✅ Workflow Release opérationnel
- ✅ Image Docker : `hamdilh/chuzone-app:1.0.0` sur Docker Hub
- ✅ Tag Git : `v1.0.0` créé automatiquement

---

## 📝 Phase 3 : Infrastructure & Kubernetes (Terraform) - CODE PRÊT

### Configuration Réalisée

Le code Terraform est complet et prêt à être déployé (non exécuté faute de compte AWS).

#### Infrastructure AWS

**Fichiers Terraform :**
- `terraform/main.tf` : Configuration principale (VPC, EC2, Security Groups)
- `terraform/variables.tf` : Variables Terraform
- `terraform/data.tf` : Data sources (AMI Ubuntu)
- `terraform/outputs.tf` : Outputs (IPs des instances)
- `terraform/terraform.tfvars` : Configuration par défaut

#### Ressources Créées

Le code Terraform provisionne :
- **1 nœud master** (control-plane Kubernetes) - t2.medium, 16 Go
- **2 nœuds worker** - t2.medium, 16 Go chacun
- **1 VPC** avec subnet publique
- **1 Security Group** configuré pour Kubernetes
- **Internet Gateway** et routes

#### Installation Kubernetes

**Scripts d'installation automatique :**
- `terraform/scripts/master-init.sh` : Installation Kubernetes v1.34 sur le master
  - Installation de containerd
  - Installation de kubelet, kubeadm, kubectl
  - Initialisation du cluster avec kubeadm
  - Installation du plugin réseau Flannel (CNI)
  
- `terraform/scripts/worker-init.sh` : Installation Kubernetes v1.34 sur les workers
  - Installation de containerd
  - Installation de kubelet, kubeadm, kubectl
  - Préparation pour rejoindre le cluster

#### Pour Déployer (quand compte AWS disponible)

```bash
cd terraform
terraform init
terraform plan
terraform apply  # Crée l'infrastructure AWS
terraform output  # Récupère les IPs des instances

# Se connecter au master
ssh -i ~/.ssh/k8s-keypair ubuntu@[MASTER_IP]

# Sur le master, obtenir la commande join
kubeadm token create --print-join-command

# Sur chaque worker, exécuter la commande join
# Vérifier : kubectl get nodes (3 nœuds Ready)
```

---

## 📝 Phase 4 : Déploiement GitOps avec Argo CD - CODE PRÊT

### Configuration Réalisée

#### Manifests Kubernetes

**Fichiers dans `gitops/` :**
- `namespace.yaml` : Namespace `examen-26`
- `deployment.yaml` : Deployment avec image `hamdilh/chuzone-app:1.0.0`
- `service.yaml` : Service NodePort (port 30080)
- `configmap.yaml` : ConfigMap avec version de l'application
- `ingress.yaml` : Ingress pour accès DNS public (DuckDNS)
- `argocd-application.yaml` : Configuration Argo CD Application
- `kustomization.yaml` : Kustomization pour gestion des manifests

#### Configuration Argo CD

- Application pointant vers : `https://github.com/Hamdi0077/chuzone.git`
- Path : `gitops/`
- Auto-sync activé
- Self-heal activé
- Namespace de destination : `examen-26`

#### Scripts d'Installation

- `scripts/install-argocd.sh` : Installation Argo CD
- `scripts/install-ingress-nginx.sh` : Installation NGINX Ingress Controller
- `scripts/install-cert-manager.sh` : Installation cert-manager (pour TLS)
- `scripts/duckdns-update.sh` : Script pour mettre à jour DuckDNS

#### Pour Déployer (après Phase 3)

```bash
# Installer Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Installer NGINX Ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Configurer DuckDNS (optionnel)
# Sur https://www.duckdns.org, créer un domaine et mettre à jour l'IP

# Créer l'Application Argo CD
kubectl apply -f gitops/argocd-application.yaml

# Vérifier
kubectl get application -n argocd
kubectl get pods -n examen-26
```

---

## 🔑 Secrets et Configuration

### GitHub Secrets (Configurés)

- `DOCKER_USERNAME` : `hamdilh`
- `DOCKER_PASSWORD` : Token Docker Hub

### Docker Hub

- Repository : `hamdilh/chuzone-app`
- Images disponibles :
  - `1.0.0-RC1` (Release Candidate)
  - `1.0.0` (Release Stable)

---

## 📊 Résumé des Phases

| Phase | Statut | Description |
|-------|--------|-------------|
| **Phase 1** | ✅ **COMPLÈTE** | CI Pipeline - Build, Tests, Docker Push (1.0.0-RC1) |
| **Phase 2** | ✅ **COMPLÈTE** | Release Promotion - Retag 1.0.0, Tag Git v1.0.0 |
| **Phase 3** | 📝 **CODE PRÊT** | Infrastructure AWS + Kubernetes (Terraform prêt) |
| **Phase 4** | 📝 **CODE PRÊT** | GitOps avec Argo CD (Manifests prêts) |

---

## 🚀 Utilisation

### Phase 1 & 2 (Opérationnel)

1. Créer une Pull Request → Déclenche automatiquement le workflow CI
2. Le workflow build, teste et push l'image `1.0.0-RC1`
3. Merger la PR → Déclenche automatiquement le workflow Release
4. Le workflow crée l'image `1.0.0` et le tag Git `v1.0.0`

### Phase 3 (Code Prêt - Non Déployé)

Le code Terraform est complet. Pour déployer :
1. Avoir un compte AWS configuré
2. Installer Terraform et AWS CLI
3. Créer une clé SSH AWS
4. Exécuter `terraform init && terraform apply`

### Phase 4 (Code Prêt - Non Déployé)

Les manifests Kubernetes sont complets. Pour déployer :
1. Avoir Phase 3 complétée (cluster Kubernetes opérationnel)
2. Installer Argo CD sur le cluster
3. Appliquer les manifests depuis `gitops/`
4. Configurer DuckDNS (optionnel) pour l'accès DNS public

---

## 📁 Fichiers Principaux

### CI/CD
- `.github/workflows/ci.yml` : Workflow CI (Phase 1)
- `.github/workflows/release-approve.yml` : Workflow Release (Phase 2)

### Infrastructure (Phase 3)
- `terraform/main.tf` : Configuration infrastructure AWS
- `terraform/variables.tf` : Variables Terraform
- `terraform/scripts/master-init.sh` : Installation Kubernetes master
- `terraform/scripts/worker-init.sh` : Installation Kubernetes workers

### GitOps (Phase 4)
- `gitops/deployment.yaml` : Deployment Kubernetes
- `gitops/service.yaml` : Service Kubernetes
- `gitops/ingress.yaml` : Ingress pour DNS public
- `gitops/argocd-application.yaml` : Configuration Argo CD

---

## 🔗 Liens Utiles

- **GitHub Repository** : https://github.com/Hamdi0077/chuzone
- **GitHub Actions** : https://github.com/Hamdi0077/chuzone/actions
- **Docker Hub** : https://hub.docker.com/r/hamdilh/chuzone-app
- **Tags Docker** : https://hub.docker.com/r/hamdilh/chuzone-app/tags

---

## ✅ Validation du Projet

### Phase 1 ✅
- [x] Workflow CI fonctionnel
- [x] Tests unitaires automatisés (5 tests)
- [x] Build automatique
- [x] Image Docker `1.0.0-RC1` sur Docker Hub

### Phase 2 ✅
- [x] Workflow Release fonctionnel
- [x] Image Docker `1.0.0` sur Docker Hub
- [x] Tag Git `v1.0.0` créé automatiquement

### Phase 3 📝
- [x] Code Terraform complet
- [x] Configuration 3 EC2 (1 master, 2 workers)
- [x] Scripts d'installation Kubernetes v1.34
- [ ] Infrastructure déployée (non exécuté - pas de compte AWS)

### Phase 4 📝
- [x] Manifests Kubernetes complets
- [x] Configuration Argo CD prête
- [x] Scripts d'installation prêts
- [ ] Argo CD installé (non exécuté - nécessite Phase 3)

---

**Projet réalisé pour l'examen ING5 SE - DevOps**  
**Auteur : Hamdi Louhichi**  
**Date : 2026-01-10**