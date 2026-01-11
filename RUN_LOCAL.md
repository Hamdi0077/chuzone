# 🚀 Lancer l'Application en Localhost

## Option 1 : Mode Développement (Recommandé)

### Démarrer le serveur de développement

```cmd
npm run dev
```

### Accéder à l'application

Ouvrez votre navigateur et allez sur :

**http://localhost:3000**

(Vite est configuré pour utiliser le port 3000)

### Arrêter le serveur

Appuyez sur `Ctrl+C` dans le terminal

---

## Option 2 : Mode Production (Build + Preview)

### Builder l'application

```cmd
npm run build
```

### Prévisualiser la version buildée

```cmd
npm run preview
```

L'application sera accessible sur **http://localhost:4173**

---

## Option 3 : Avec Docker

### Builder l'image Docker

```cmd
docker build -t chuzone-app:local .
```

### Lancer le conteneur

```cmd
docker run -d -p 8080:80 --name chuzone-local chuzone-app:local
```

### Accéder à l'application

Ouvrez votre navigateur et allez sur :

**http://localhost:8080**

### Arrêter le conteneur

```cmd
docker stop chuzone-local
docker rm chuzone-local
```

---

## ✅ Vérification

Si tout fonctionne, vous devriez voir :

- **Titre** : "ChuZone - DevOps POC"
- **Version** : "Version 1.0.0"
- **Compteur** : Avec boutons + et -
- **Message** : "Application déployée via CI/CD avec Kubernetes et Argo CD"

---

## 🔧 Dépannage

### Le port 3000 est déjà utilisé

Modifiez `vite.config.js` et changez le port :

```javascript
server: {
  host: true,
  port: 3001,  // Changez le port
}
```

### Erreur "npm: command not found"

Installez Node.js depuis : https://nodejs.org/

### Erreur lors du build

```cmd
npm install
npm run build
```

---

**🎉 L'application est maintenant accessible en localhost !**
