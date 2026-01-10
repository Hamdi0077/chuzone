# Script de vérification complète de toutes les phases
# Ce script vérifie l'état de préparation de toutes les phases

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  📊 VÉRIFICATION COMPLÈTE DU PROJET DEVOPS" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

# Phase 1 & 2
Write-Host "🔵 Phase 1 & 2 (CI/CD):" -ForegroundColor Blue
if (Get-Command node -ErrorAction SilentlyContinue) {
    Write-Host "   ✅ Node.js installé" -ForegroundColor Green
} else {
    Write-Host "   ❌ Node.js non installé" -ForegroundColor Red
}

if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Host "   ✅ Docker installé" -ForegroundColor Green
} else {
    Write-Host "   ⚠️ Docker non installé (requis pour CI/CD)" -ForegroundColor Yellow
}

if (Test-Path ".github/workflows/ci.yml") {
    Write-Host "   ✅ Workflow CI configuré" -ForegroundColor Green
} else {
    Write-Host "   ❌ Workflow CI manquant" -ForegroundColor Red
}

if (Test-Path ".github/workflows/release-approve.yml") {
    Write-Host "   ✅ Workflow Release configuré" -ForegroundColor Green
} else {
    Write-Host "   ❌ Workflow Release manquant" -ForegroundColor Red
}

Write-Host ""

# Phase 3
Write-Host "🟢 Phase 3 (Terraform/AWS):" -ForegroundColor Green
if (Get-Command terraform -ErrorAction SilentlyContinue) {
    Write-Host "   ✅ Terraform installé" -ForegroundColor Green
} else {
    Write-Host "   ❌ Terraform non installé" -ForegroundColor Red
}

if (Get-Command aws -ErrorAction SilentlyContinue) {
    Write-Host "   ✅ AWS CLI installé" -ForegroundColor Green
    try {
        $null = aws sts get-caller-identity 2>&1
        Write-Host "   ✅ AWS CLI configuré" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️ AWS CLI non configuré" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ❌ AWS CLI non installé" -ForegroundColor Red
}

if (Test-Path "terraform/main.tf") {
    Write-Host "   ✅ Configuration Terraform présente" -ForegroundColor Green
} else {
    Write-Host "   ❌ Configuration Terraform manquante" -ForegroundColor Red
}

Write-Host ""

# Phase 4
Write-Host "🟡 Phase 4 (Argo CD/GitOps):" -ForegroundColor Yellow
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    Write-Host "   ✅ kubectl installé" -ForegroundColor Green
} else {
    Write-Host "   ⚠️ kubectl non installé (nécessaire après Phase 3)" -ForegroundColor Yellow
}

if (Test-Path "gitops/deployment.yaml") {
    Write-Host "   ✅ Manifests Kubernetes créés" -ForegroundColor Green
} else {
    Write-Host "   ❌ Manifests Kubernetes manquants" -ForegroundColor Red
}

if (Test-Path "gitops/argocd-application.yaml") {
    Write-Host "   ✅ Configuration Argo CD créée" -ForegroundColor Green
} else {
    Write-Host "   ❌ Configuration Argo CD manquante" -ForegroundColor Red
}

Write-Host ""

# Résumé
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  📋 RÉSUMÉ" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

Write-Host "Phase 1 & 2 : Configuration complète, en attente de test" -ForegroundColor Green
Write-Host "Phase 3 : Configuration prête, nécessite installation outils" -ForegroundColor Yellow
Write-Host "Phase 4 : Configuration complète, prête après Phase 3`n" -ForegroundColor Green

Write-Host "📖 Consultez les guides:" -ForegroundColor Cyan
Write-Host "   - QUICKSTART.md : Guide de démarrage rapide" -ForegroundColor Gray
Write-Host "   - INSTALL_PREREQUISITES.md : Installation des outils" -ForegroundColor Gray
Write-Host "   - PROJECT_SUMMARY.md : Résumé complet du projet`n" -ForegroundColor Gray
