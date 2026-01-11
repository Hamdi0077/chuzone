# ☁️ Infrastructure AWS avec Terraform - Phase 3

## 📋 Vue d'ensemble

Ce dossier contient la configuration Terraform pour déployer :
- **1 nœud master** (control-plane Kubernetes)
- **2 nœuds worker** (Kubernetes workers)
- **VPC, Subnet, Security Groups** configurés pour Kubernetes
- **Installation automatique** de Kubernetes v1.34 avec kubeadm

## 🔧 Prérequis

Avant de déployer, assurez-vous d'avoir :

1. ✅ Terraform installé (`terraform --version`)
2. ✅ AWS CLI installé et configuré (`aws sts get-caller-identity`)
3. ✅ Compte AWS avec permissions pour créer EC2, VPC, Security Groups
4. ✅ Clé SSH AWS créée (voir ci-dessous)

## 🔑 Étape 1 : Créer une clé SSH AWS

### Générer une clé SSH

```bash
# Sur Windows (PowerShell)
ssh-keygen -t rsa -b 4096 -f $env:USERPROFILE\.ssh\k8s-keypair -N ""

# Sur Linux/Mac
ssh-keygen -t rsa -b 4096 -f ~/.ssh/k8s-keypair -N ""
```

### Importer la clé dans AWS

```bash
# Sur Windows
aws ec2 import-key-pair `
  --key-name k8s-keypair `
  --public-key-material fileb://$env:USERPROFILE\.ssh\k8s-keypair.pub `
  --region us-east-1

# Sur Linux/Mac
aws ec2 import-key-pair \
  --key-name k8s-keypair \
  --public-key-material fileb://~/.ssh/k8s-keypair.pub \
  --region us-east-1
```

**⚠️ Important :** Utilisez la même région que celle configurée dans `terraform.tfvars`

## ⚙️ Étape 2 : Configurer Terraform

### Vérifier/Créer terraform.tfvars

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Puis éditez `terraform.tfvars` avec vos paramètres :
- `aws_region` : Votre région AWS préférée
- `key_pair_name` : Le nom de votre clé SSH (par défaut: `k8s-keypair`)

## 🚀 Étape 3 : Déployer l'Infrastructure

### Initialiser Terraform

```bash
cd terraform
terraform init
```

Cette commande télécharge le provider AWS.

### Vérifier le plan

```bash
terraform plan
```

Cette commande montre ce qui sera créé **sans créer** les ressources.

**Vérifiez :**
- ✅ 3 instances EC2 (1 master, 2 workers)
- ✅ 1 VPC
- ✅ 1 Subnet
- ✅ 1 Internet Gateway
- ✅ 1 Security Group
- ✅ Routes et associations

### Déployer

```bash
terraform apply
```

Tapez `yes` quand demandé.

**⏱️ Temps estimé :** 5-10 minutes

### Noter les outputs

Une fois le déploiement terminé :

```bash
terraform output
```

**⚠️ IMPORTANT :** Sauvegardez ces informations :
- `master_public_ip` : IP publique du master
- `master_private_ip` : IP privée du master
- `worker1_public_ip` : IP publique du worker 1
- `worker2_public_ip` : IP publique du worker 2

## 🔧 Étape 4 : Vérifier l'Installation Kubernetes

### Se connecter au master

```bash
# Récupérer l'IP du master
MASTER_IP=$(terraform output -raw master_public_ip)

# Se connecter (Windows PowerShell)
ssh -i $env:USERPROFILE\.ssh\k8s-keypair ubuntu@$MASTER_IP

# Sur Linux/Mac
ssh -i ~/.ssh/k8s-keypair ubuntu@$MASTER_IP
```

### Vérifier que Kubernetes est initialisé

Sur le master :

```bash
# Attendre quelques minutes si nécessaire (l'installation peut prendre 5-10 min)
kubectl get nodes

# Vous devriez voir :
# NAME          STATUS   ROLES           AGE   VERSION
# k8s-master    Ready    control-plane   5m    v1.34.0
```

Si le master n'est pas encore Ready :
```bash
# Vérifier les logs
sudo journalctl -xeu kubelet

# Vérifier le status
sudo systemctl status kubelet
```

### Obtenir la commande join pour les workers

Sur le master :

```bash
kubeadm token create --print-join-command
```

**⚠️ COPIEZ CETTE COMMANDE** - vous en aurez besoin pour les workers.

## 👥 Étape 5 : Joindre les Workers au Cluster

### Worker 1

Dans un nouveau terminal (gardez la session master ouverte) :

```bash
# Récupérer l'IP du worker 1
cd terraform
WORKER1_IP=$(terraform output -raw worker1_public_ip)

# Se connecter
ssh -i $env:USERPROFILE\.ssh\k8s-keypair ubuntu@$WORKER1_IP

# Sur le worker, exécuter la commande join (celle copiée du master)
sudo kubeadm join <MASTER_IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>
```

### Worker 2

Répétez pour le worker 2 :

```bash
WORKER2_IP=$(terraform output -raw worker2_public_ip)
ssh -i $env:USERPROFILE\.ssh\k8s-keypair ubuntu@$WORKER2_IP

# Exécuter la même commande join
```

### Vérification finale

Retour sur le master :

```bash
kubectl get nodes
```

**Vous devriez voir 3 nœuds tous en état Ready :**
```
NAME          STATUS   ROLES           AGE   VERSION
k8s-master    Ready    control-plane   10m   v1.34.0
k8s-worker1   Ready    <none>          2m    v1.34.0
k8s-worker2   Ready    <none>          2m    v1.34.0
```

## 📋 Étape 6 : Configurer kubectl Localement (Optionnel)

Pour utiliser kubectl depuis votre machine :

```bash
# Sur le master
cat ~/.kube/config

# Copier le contenu

# Sur votre machine locale
mkdir -p ~/.kube  # ou $env:USERPROFILE\.kube sur Windows
# Coller le contenu du kubeconfig dans ~/.kube/config

# Vérifier
kubectl get nodes
```

## 🗑️ Étape 7 : Nettoyer (Quand vous avez fini)

**⚠️ IMPORTANT :** Supprimez les ressources pour éviter les coûts AWS !

```bash
cd terraform
terraform destroy
```

Tapez `yes` quand demandé.

**⏱️ Temps estimé :** 2-3 minutes

## 💰 Coûts AWS

**Estimations (si les instances tournent 24/7) :**
- 3 × EC2 t2.medium : ~$0.0416/heure par instance
- **Total : ~$9-10/mois**
- **Storage (16 Go × 3) : ~$2/mois**

**Total estimé : ~$11-12/mois**

**💡 Astuce :** N'oubliez pas de faire `terraform destroy` quand vous avez fini !

## 🔧 Dépannage

### Les instances ne démarrent pas
- Vérifiez les logs dans AWS Console → EC2 → Instances → Instance State
- Vérifiez que votre quota AWS permet de créer 3 instances

### Kubernetes n'est pas initialisé
- Les scripts user_data prennent du temps (5-10 min)
- Vérifiez les logs : `sudo journalctl -xeu kubelet` sur le master
- Vérifiez que containerd fonctionne : `sudo systemctl status containerd`

### Les workers ne peuvent pas joindre le cluster
- Vérifiez que les Security Groups permettent la communication entre les instances
- Vérifiez que le token kubeadm n'a pas expiré (tokens expirent après 24h par défaut)
- Créez un nouveau token : `kubeadm token create --print-join-command`

### Erreur de permissions AWS
- Vérifiez que votre utilisateur AWS a les permissions nécessaires :
  - EC2 (FullAccess ou CreateInstances, DescribeInstances, etc.)
  - VPC (FullAccess)
  - IAM (pour créer des rôles si nécessaire)

## 📚 Ressources

- **Terraform AWS Provider** : https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **AWS EC2 Pricing** : https://aws.amazon.com/ec2/pricing/
- **Kubernetes Documentation** : https://kubernetes.io/docs/
- **kubeadm Documentation** : https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/

---

**📝 Note :** Les scripts d'installation Kubernetes (`master-init.sh` et `worker-init.sh`) s'exécutent automatiquement au démarrage des instances via `user_data`.




