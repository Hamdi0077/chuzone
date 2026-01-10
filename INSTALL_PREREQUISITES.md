# 🔧 Installation des Prérequis - Phase 3 & 4

## 📋 Prérequis pour Phase 3 (Infrastructure AWS & Kubernetes)

Pour déployer l'infrastructure AWS et Kubernetes, vous devez installer :

### 1. Terraform

#### Installation sur Windows

**Option 1 : Via Chocolatey (Recommandé)**
```powershell
# Si Chocolatey n'est pas installé, installez-le d'abord
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Installer Terraform
choco install terraform -y
```

**Option 2 : Installation manuelle**
1. Téléchargez Terraform : https://www.terraform.io/downloads
2. Extrayez le fichier `terraform.exe`
3. Ajoutez le chemin au PATH système
4. Ou placez `terraform.exe` dans un dossier qui est déjà dans le PATH (ex: `C:\Windows\System32`)

**Option 3 : Via Scoop**
```powershell
scoop install terraform
```

**Vérification :**
```bash
terraform --version
# Devrait afficher : Terraform v1.x.x
```

### 2. AWS CLI

#### Installation sur Windows

**Option 1 : Via MSI Installer (Recommandé)**
1. Téléchargez l'installer MSI : https://awscli.amazonaws.com/AWSCLIV2.msi
2. Exécutez l'installer
3. Suivez les instructions d'installation

**Option 2 : Via Chocolatey**
```powershell
choco install awscli -y
```

**Vérification :**
```bash
aws --version
# Devrait afficher : aws-cli/2.x.x
```

#### Configuration AWS CLI

Une fois AWS CLI installé, configurez vos credentials :

```bash
aws configure
```

Vous devrez entrer :
- **AWS Access Key ID** : Votre clé d'accès AWS
- **AWS Secret Access Key** : Votre clé secrète AWS
- **Default region name** : `us-east-1` (ou votre région préférée)
- **Default output format** : `json`

**Note :** Pour obtenir vos clés d'accès AWS :
1. Connectez-vous à AWS Console : https://console.aws.amazon.com
2. Allez dans **IAM** → **Users** → Votre utilisateur → **Security credentials**
3. Cliquez sur **Create access key**
4. Copiez l'Access Key ID et Secret Access Key

**⚠️ Important :** Ne partagez JAMAIS vos clés d'accès AWS !

**Vérification :**
```bash
aws sts get-caller-identity
# Devrait afficher vos informations AWS
```

### 3. Git (Déjà installé ✅)

Vérification :
```bash
git --version
# Devrait afficher : git version 2.x.x
```

## 📋 Prérequis pour Phase 4 (GitOps avec Argo CD)

### kubectl (Kubernetes CLI)

Une fois le cluster Kubernetes déployé, vous aurez besoin de `kubectl` pour interagir avec le cluster.

#### Installation sur Windows

**Option 1 : Via Chocolatey**
```powershell
choco install kubernetes-cli -y
```

**Option 2 : Via Scoop**
```powershell
scoop install kubectl
```

**Option 3 : Installation manuelle**
1. Téléchargez kubectl : https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
2. Ajoutez au PATH

**Vérification :**
```bash
kubectl version --client
```

### Argo CD CLI (Optionnel mais recommandé)

Une fois Argo CD installé, vous pouvez installer le CLI pour une meilleure expérience.

```powershell
# Via Chocolatey
choco install argocd -y

# Ou téléchargez depuis : https://argo-cd.readthedocs.io/en/stable/cli_installation/
```

## ✅ Checklist d'Installation

Avant de continuer avec Phase 3, vérifiez :

- [ ] Terraform installé (`terraform --version`)
- [ ] AWS CLI installé (`aws --version`)
- [ ] AWS CLI configuré (`aws sts get-caller-identity`)
- [ ] Compte AWS actif avec credentials valides
- [ ] Permissions AWS pour créer EC2, VPC, Security Groups
- [ ] kubectl installé (pour Phase 4) (`kubectl version --client`)

## 🔗 Ressources Utiles

- **Terraform Downloads** : https://www.terraform.io/downloads
- **AWS CLI Downloads** : https://awscli.amazonaws.com/AWSCLIV2.msi
- **kubectl Installation** : https://kubernetes.io/docs/tasks/tools/
- **Argo CD CLI** : https://argo-cd.readthedocs.io/en/stable/cli_installation/
- **AWS Console** : https://console.aws.amazon.com
- **AWS IAM** : https://console.aws.amazon.com/iam

## 💰 Coûts AWS (Important)

Le déploiement de l'infrastructure AWS entraînera des coûts :
- **3 instances EC2 t2.medium** : ~$0.0416/heure par instance (~$3/mois par instance)
- **Total estimé** : ~$9-10/mois si les instances tournent 24/7
- **N'oubliez pas de supprimer les ressources** avec `terraform destroy` quand vous avez fini !

---

**📝 Note** : Si vous ne pouvez pas installer ces outils maintenant, vous pouvez toujours :
1. Préparer la configuration Terraform (c'est déjà fait ✅)
2. Finaliser Phase 1 et 2 (CI/CD) qui sont indépendantes
3. Préparer Phase 4 (GitOps manifests) qui sont déjà créés ✅
