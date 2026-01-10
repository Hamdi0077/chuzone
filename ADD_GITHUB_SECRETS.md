# 🔐 Ajouter les Secrets GitHub - Guide Rapide

## ✅ Vos Credentials Docker Hub

- **DOCKER_USERNAME** : `hamdilh`
- **DOCKER_PASSWORD** : Votre token Docker Hub (celui que vous avez copié)

## 📋 Étapes pour ajouter les secrets dans GitHub

### Méthode 1 : Via l'interface GitHub (Recommandé)

#### 1. Accéder aux Secrets
1. Ouvrez votre navigateur
2. Allez sur : **https://github.com/Hamdi0077/chuzone/settings/secrets/actions**
   - Ou : https://github.com/Hamdi0077/chuzone → **Settings** (en haut) → **Secrets and variables** → **Actions**

#### 2. Ajouter DOCKER_USERNAME
1. Cliquez sur **New repository secret** (bouton vert en haut à droite)
2. **Name** : Entrez `DOCKER_USERNAME`
3. **Secret** : Entrez `hamdilh`
4. Cliquez sur **Add secret**

#### 3. Ajouter DOCKER_PASSWORD
1. Cliquez à nouveau sur **New repository secret**
2. **Name** : Entrez `DOCKER_PASSWORD`
3. **Secret** : Entrez votre token Docker Hub (celui qui commence par `dckr_pat_...`)
4. Cliquez sur **Add secret**

#### 4. Vérification
Vous devriez voir dans la liste :
- ✅ `DOCKER_USERNAME` (visible comme `••••••••hamdilh`)
- ✅ `DOCKER_PASSWORD` (visible comme `••••••••`)

### Méthode 2 : Via GitHub CLI (Optionnel)

Si vous avez GitHub CLI installé :

```bash
gh secret set DOCKER_USERNAME --body "hamdilh" --repo Hamdi0077/chuzone
gh secret set DOCKER_PASSWORD --body "VOTRE_TOKEN_DOCKER_HUB" --repo Hamdi0077/chuzone
```

## 🧪 Tester la Configuration

Une fois les secrets ajoutés, testez en créant une Pull Request :

```bash
git checkout -b feature/test-docker-secrets
echo "# Test Docker Hub connection via GitHub Actions" >> TEST.md
git add TEST.md
git commit -m "Test: Verify Docker Hub secrets configuration"
git push origin feature/test-docker-secrets
```

Puis :
1. Allez sur GitHub : https://github.com/Hamdi0077/chuzone
2. Créez une Pull Request pour la branche `feature/test-docker-secrets`
3. Allez dans l'onglet **Actions** pour voir le workflow CI s'exécuter
4. Le workflow devrait :
   - ✅ Se connecter à Docker Hub avec succès
   - ✅ Builder l'image Docker
   - ✅ Pousser l'image sur Docker Hub avec le tag `hamdilh/chuzone-app:1.0.0-RC1`

## ✅ Vérifier que l'image est sur Docker Hub

Après le workflow CI :
1. Allez sur : https://hub.docker.com/r/hamdilh/chuzone-app
2. Vous devriez voir l'image `chuzone-app:1.0.0-RC1` ✅

## ⚠️ Sécurité

**Important :** 
- Ne mettez JAMAIS de tokens dans les fichiers Git
- Utilisez toujours les Secrets GitHub pour stocker les tokens
- Les secrets GitHub sont cryptés et sécurisés

## 🔗 Liens Utiles

- **GitHub Secrets** : https://github.com/Hamdi0077/chuzone/settings/secrets/actions
- **Docker Hub Repo** : https://hub.docker.com/r/hamdilh/chuzone-app
- **GitHub Actions** : https://github.com/Hamdi0077/chuzone/actions

---

**📝 Note** : Les secrets GitHub sont cryptés et ne peuvent être vus en clair après leur création. Seuls les workflows GitHub Actions peuvent les utiliser.
