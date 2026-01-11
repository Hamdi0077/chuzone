# 🚀 Créer une Pull Request pour Tester le CI/CD

## ✅ Étape 1 : Branche créée et poussée

La branche `feature/test-docker-secrets` a été créée et poussée sur GitHub ✅

## 🔗 Étape 2 : Créer la Pull Request

### Option 1 : Via le lien direct (Plus rapide)

GitHub vous a donné un lien direct :
👉 **https://github.com/Hamdi0077/chuzone/pull/new/feature/test-docker-secrets**

Cliquez sur ce lien pour créer la PR automatiquement.

### Option 2 : Via l'interface GitHub

1. Allez sur : **https://github.com/Hamdi0077/chuzone**
2. Vous verrez un message jaune en haut : 
   ```
   feature/test-docker-secrets had recent pushes less than a minute ago
   Compare & pull request
   ```
3. Cliquez sur **"Compare & pull request"**

### Étape 3 : Remplir la Pull Request

1. **Titre** : `Test: Verify Docker Hub secrets configuration`
   - Ou utilisez le titre suggéré par GitHub

2. **Description** (optionnel) :
   ```markdown
   Cette PR teste le workflow CI/CD avec Docker Hub.
   
   Le workflow devrait :
   - ✅ Se connecter à Docker Hub
   - ✅ Builder l'application
   - ✅ Exécuter les tests
   - ✅ Builder l'image Docker
   - ✅ Pousser l'image `hamdilh/chuzone-app:1.0.0-RC1` sur Docker Hub
   ```

3. Cliquez sur **"Create pull request"** (bouton vert)

## 📊 Étape 4 : Suivre le Workflow CI

Une fois la PR créée :

1. Le workflow **CI Pipeline** se déclenchera automatiquement
2. Allez dans l'onglet **"Actions"** : https://github.com/Hamdi0077/chuzone/actions
3. Vous verrez le workflow en cours d'exécution :
   - Job 1 : `build-and-test` (tests et build)
   - Job 2 : `build-and-push-docker` (build et push Docker)

## ✅ Ce que le workflow devrait faire

### Si tout fonctionne bien :

1. ✅ **Tests** : Les 5 tests unitaires passent
2. ✅ **Build** : L'application se build avec succès
3. ✅ **Docker Login** : Se connecte à Docker Hub avec vos secrets
4. ✅ **Docker Build** : Build l'image Docker
5. ✅ **Docker Push** : Pousse l'image sur Docker Hub avec le tag `hamdilh/chuzone-app:1.0.0-RC1`

### Vérifier l'image sur Docker Hub

Une fois le workflow terminé avec succès :

1. Allez sur : **https://hub.docker.com/r/hamdilh/chuzone-app**
2. Vous devriez voir l'image `chuzone-app` avec le tag `1.0.0-RC1` ✅

## ⚠️ Si le workflow échoue

### Erreur "unauthorized" ou "authentication failed"
- Vérifiez que les secrets `DOCKER_USERNAME` et `DOCKER_PASSWORD` sont bien ajoutés dans GitHub
- Vérifiez que `DOCKER_PASSWORD` contient bien le **token**, pas votre mot de passe
- Vérifiez que le token a les permissions **Read, Write, Delete**

### Erreur "repository not found"
- Vérifiez que `DOCKER_USERNAME` est correct (`hamdilh`)
- L'image sera créée automatiquement lors du premier push

### Erreur dans les tests
- Vérifiez les logs du job `build-and-test`
- Les tests doivent passer pour que le workflow continue

## 🎯 Après le workflow CI réussi

Une fois que le workflow CI passe avec succès :

1. **Mergez la Pull Request** vers `main`
2. Cela déclenchera automatiquement le workflow **Release Approve** (Phase 2)
3. Le workflow Release va :
   - ✅ Récupérer l'image `1.0.0-RC1`
   - ✅ Retagger en `1.0.0`
   - ✅ Pousser `1.0.0` sur Docker Hub
   - ✅ Créer le tag Git `v1.0.0`

## 🔗 Liens Utiles

- **Créer la PR** : https://github.com/Hamdi0077/chuzone/pull/new/feature/test-docker-secrets
- **GitHub Actions** : https://github.com/Hamdi0077/chuzone/actions
- **Docker Hub Repo** : https://hub.docker.com/r/hamdilh/chuzone-app
- **Secrets GitHub** : https://github.com/Hamdi0077/chuzone/settings/secrets/actions

---

**🎉 Bonne chance !** Une fois la PR créée, le workflow CI se déclenchera automatiquement.
