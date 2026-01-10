# 🐳 Guide Docker Hub - Où trouver DOCKER_USERNAME et DOCKER_PASSWORD

## 📍 Étape 1 : Créer un compte Docker Hub

### 1.1. Aller sur Docker Hub
1. Ouvrez votre navigateur
2. Allez sur : **https://hub.docker.com**
3. Cliquez sur **Sign Up** (en haut à droite)

### 1.2. Créer votre compte
- Entrez un **username** (ex: `hamdi0077`, `votrenom`) - ce sera votre `DOCKER_USERNAME`
- Entrez votre **email**
- Créez un **mot de passe**
- Acceptez les conditions
- Cliquez sur **Sign Up**

**⚠️ IMPORTANT :** Notez votre **username** (c'est votre `DOCKER_USERNAME`)

## 🔑 Étape 2 : Trouver votre DOCKER_USERNAME

Votre `DOCKER_USERNAME` est simplement :
- **L'username que vous avez choisi lors de l'inscription**
- Il apparaît en haut à droite quand vous êtes connecté
- Il est visible dans l'URL quand vous allez sur votre profil : `https://hub.docker.com/u/VOTRE_USERNAME`

**Exemple :** Si votre URL est `https://hub.docker.com/u/hamdi0077`, alors votre `DOCKER_USERNAME` est `hamdi0077`

## 🔐 Étape 3 : Créer un Access Token (DOCKER_PASSWORD)

⚠️ **IMPORTANT :** Pour GitHub Actions, vous devez utiliser un **Access Token**, **PAS votre mot de passe** !

### 3.1. Accéder aux paramètres de sécurité
1. Connectez-vous à Docker Hub : https://hub.docker.com
2. Cliquez sur votre **profil** (icône utilisateur en haut à droite)
3. Cliquez sur **Account Settings** dans le menu déroulant

### 3.2. Créer un nouveau token
1. Dans le menu de gauche, cliquez sur **Security**
2. Vous verrez la section **Access Tokens**
3. Cliquez sur **New Access Token**

### 3.3. Configurer le token
1. **Description** : Donnez un nom descriptif (ex: `github-actions-chuzone`, `ci-cd-token`)
2. **Permissions** : Sélectionnez **Read, Write, Delete** (ou au minimum **Read & Write**)
3. Cliquez sur **Generate**

### 3.4. Copier le token ⚠️
**⚠️ TRÈS IMPORTANT :** 
- Le token s'affiche **UNE SEULE FOIS**
- **COPIEZ-LE IMMÉDIATEMENT** dans un endroit sûr (notepad, fichier texte, etc.)
- **Vous ne pourrez plus le voir après !**
- Si vous le perdez, vous devrez créer un nouveau token

**Exemple de token :** `dckr_pat_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

Ce token sera votre `DOCKER_PASSWORD` dans les secrets GitHub.

## 📋 Résumé : Où trouver chaque information

| Information | Où la trouver |
|------------|---------------|
| **DOCKER_USERNAME** | Username choisi lors de l'inscription<br>Visible en haut à droite sur Docker Hub<br>Visible dans l'URL : `hub.docker.com/u/VOTRE_USERNAME` |
| **DOCKER_PASSWORD** | Access Token créé dans Account Settings → Security → New Access Token<br>⚠️ À copier immédiatement car visible une seule fois |

## 🔒 Étape 4 : Ajouter les secrets dans GitHub

Une fois que vous avez :
- ✅ Votre `DOCKER_USERNAME` (ex: `hamdi0077`)
- ✅ Votre `DOCKER_PASSWORD` (le token, ex: `dckr_pat_...`)

### 4.1. Aller dans les Secrets GitHub
1. Allez sur votre dépôt : https://github.com/Hamdi0077/chuzone
2. Cliquez sur **Settings** (onglet en haut)
3. Dans le menu de gauche, cliquez sur **Secrets and variables** → **Actions**

### 4.2. Ajouter DOCKER_USERNAME
1. Cliquez sur **New repository secret**
2. **Name** : `DOCKER_USERNAME`
3. **Secret** : Entrez votre username Docker Hub (ex: `hamdi0077`)
4. Cliquez sur **Add secret**

### 4.3. Ajouter DOCKER_PASSWORD
1. Cliquez à nouveau sur **New repository secret**
2. **Name** : `DOCKER_PASSWORD`
3. **Secret** : Collez votre **token Docker Hub** (pas votre mot de passe !)
   - Le token commence généralement par `dckr_pat_...`
4. Cliquez sur **Add secret**

## ✅ Vérification

Pour vérifier que tout est bien configuré :
1. Allez dans **Settings** → **Secrets and variables** → **Actions**
2. Vous devriez voir :
   - ✅ `DOCKER_USERNAME` (visible seulement avec des points : `••••••••`)
   - ✅ `DOCKER_PASSWORD` (visible seulement avec des points : `••••••••`)

## 🧪 Tester la configuration

Une fois les secrets ajoutés, testez en créant une Pull Request :

```bash
git checkout -b feature/test-docker
echo "# Test Docker Hub connection" >> TEST.md
git add TEST.md
git commit -m "Test: Verify Docker Hub secrets"
git push origin feature/test-docker
```

Puis créez une Pull Request sur GitHub. Le workflow CI devrait :
- ✅ Se connecter à Docker Hub
- ✅ Builder l'image
- ✅ Pousser l'image sur Docker Hub avec le tag `1.0.0-RC1`

## 🔗 Liens utiles

- **Docker Hub Sign Up** : https://hub.docker.com/signup
- **Docker Hub Login** : https://hub.docker.com/login
- **Docker Hub Account Settings** : https://hub.docker.com/settings/account
- **Docker Hub Security (Tokens)** : https://hub.docker.com/settings/security
- **Votre dépôt GitHub** : https://github.com/Hamdi0077/chuzone/settings/secrets/actions

## ❓ Problèmes courants

### "Je ne trouve pas Account Settings"
- Assurez-vous d'être connecté à Docker Hub
- Cliquez sur votre profil (icône utilisateur) en haut à droite
- Le menu déroulant devrait contenir "Account Settings"

### "Je ne vois pas Access Tokens dans Security"
- Vérifiez que vous êtes bien dans **Account Settings** → **Security**
- La section "Access Tokens" devrait être visible en haut de la page
- Si vous ne la voyez pas, essayez de rafraîchir la page

### "J'ai perdu mon token"
- Créez-en un nouveau dans Security → Access Tokens
- **Révoquez l'ancien** si nécessaire (bouton "Revoke" à côté du token)
- Mettez à jour le secret `DOCKER_PASSWORD` dans GitHub avec le nouveau token

### "Le workflow échoue avec 'unauthorized'"
- Vérifiez que `DOCKER_PASSWORD` contient bien le **token**, pas votre mot de passe
- Vérifiez que le token a les permissions **Read, Write, Delete**
- Vérifiez que `DOCKER_USERNAME` est correct (pas d'espaces, caractères exacts)

---

**Astuce** : Gardez une copie de votre token dans un gestionnaire de mots de passe sécurisé pour référence future.
