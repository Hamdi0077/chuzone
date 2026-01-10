# 🚀 Configuration Docker Hub - Guide Rapide

## 📍 Où trouver ces informations sur docker.com ?

### 1️⃣ DOCKER_USERNAME

**Qu'est-ce que c'est ?**
- Votre nom d'utilisateur Docker Hub que vous avez choisi lors de l'inscription

**Où le trouver ?**
1. Allez sur : **https://hub.docker.com**
2. Connectez-vous avec votre compte
3. Votre username est visible **en haut à droite** (à côté de votre avatar)
4. Ou regardez l'URL de votre profil : `https://hub.docker.com/u/VOTRE_USERNAME`

**Exemple :** Si votre URL est `hub.docker.com/u/hamdi0077`, votre `DOCKER_USERNAME` est `hamdi0077`

---

### 2️⃣ DOCKER_PASSWORD (Access Token)

**Qu'est-ce que c'est ?**
- Un **Access Token** (token d'accès) que vous devez créer sur Docker Hub
- ⚠️ **ATTENTION** : Utilisez un **token**, PAS votre mot de passe !

**Où le créer ?**

#### Option 1 : Navigation manuelle
1. Allez sur : **https://hub.docker.com**
2. Cliquez sur votre **profil** (en haut à droite)
3. Cliquez sur **Account Settings**
4. Dans le menu de gauche, cliquez sur **Security**
5. Dans la section **Access Tokens**, cliquez sur **New Access Token**
6. Donnez un nom (ex: `github-actions`)
7. Sélectionnez les permissions : **Read, Write, Delete**
8. Cliquez sur **Generate**
9. **⚠️ COPIEZ LE TOKEN IMMÉDIATEMENT** (il ne sera plus visible après !)

#### Option 2 : Lien direct
🔗 **URL directe** : https://hub.docker.com/settings/security

---

## 📋 Résumé Visuel

```
Docker Hub (hub.docker.com)
│
├── DOCKER_USERNAME
│   └── Trouvé en haut à droite (après connexion)
│   └── Exemple : hamdi0077
│
└── DOCKER_PASSWORD (Token)
    └── Créé dans : Account Settings → Security → New Access Token
    └── URL : https://hub.docker.com/settings/security
    └── Format : dckr_pat_xxxxxxxxxxxxxxxxxxxxxx
```

---

## ✅ Checklist Rapide

- [ ] Compte Docker Hub créé sur https://hub.docker.com
- [ ] Username noté (c'est votre DOCKER_USERNAME)
- [ ] Allé dans Security : https://hub.docker.com/settings/security
- [ ] Créé un New Access Token avec permissions Read, Write, Delete
- [ ] Token copié immédiatement (c'est votre DOCKER_PASSWORD)
- [ ] Ajouté les secrets dans GitHub :
  - [ ] Secret `DOCKER_USERNAME` avec votre username
  - [ ] Secret `DOCKER_PASSWORD` avec votre token (pas le mot de passe !)

---

## 🔗 Liens Utiles

- **Docker Hub Sign Up** : https://hub.docker.com/signup
- **Docker Hub Login** : https://hub.docker.com/login  
- **Security Settings (Tokens)** : https://hub.docker.com/settings/security
- **GitHub Secrets** : https://github.com/Hamdi0077/chuzone/settings/secrets/actions

---

## ⚠️ Important

1. **DOCKER_PASSWORD = Access Token**, pas votre mot de passe !
2. Le token est visible **UNE SEULE FOIS** → copiez-le immédiatement
3. Si vous perdez le token, créez-en un nouveau et mettez à jour le secret GitHub
4. Le token doit avoir les permissions **Read, Write, Delete** pour que GitHub Actions puisse pousser les images

---

**📖 Pour plus de détails** : Consultez `DOCKER_HUB_GUIDE.md`
