#!/bin/bash
# Script d'automatisation Phase 1 - CI/CD
# Ce script vérifie et prépare l'environnement pour Phase 1

set -e

echo "=== Phase 1 : Préparation CI/CD ==="

# Vérifier Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js n'est pas installé"
    exit 1
fi
echo "✅ Node.js $(node --version) installé"

# Vérifier npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm n'est pas installé"
    exit 1
fi
echo "✅ npm $(npm --version) installé"

# Installer les dépendances
echo "📦 Installation des dépendances..."
npm install

# Lancer les tests
echo "🧪 Exécution des tests..."
npm test -- --run

# Build
echo "🏗️ Build de l'application..."
npm run build

# Vérifier Docker
if ! command -v docker &> /dev/null; then
    echo "⚠️ Docker n'est pas installé - nécessité pour les workflows CI"
else
    echo "✅ Docker $(docker --version) installé"
fi

echo ""
echo "✅ Phase 1 prête !"
echo ""
echo "📋 Prochaines étapes :"
echo "1. Ajoutez les secrets GitHub :"
echo "   - DOCKER_USERNAME = hamdilh"
echo "   - DOCKER_PASSWORD = votre token Docker Hub"
echo "2. Créez une Pull Request pour tester le workflow CI"
echo ""




