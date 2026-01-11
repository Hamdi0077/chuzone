# Script d'installation automatique de tous les outils nécessaires
# Pour Phase 3 (Terraform, AWS CLI) et Phase 4 (kubectl)

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🔧 INSTALLATION DES OUTILS POUR PHASE 3 et 4" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

# Vérifier si on est admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠️ ATTENTION : Certaines installations nécessitent des droits administrateur" -ForegroundColor Yellow
    Write-Host "   Essayez d'abord avec winget (sans admin), sinon ouvrez PowerShell en tant qu'Administrateur`n" -ForegroundColor Yellow
}

# 1. Terraform
Write-Host "1️⃣ Installation de Terraform..." -ForegroundColor Cyan
if (Get-Command terraform -ErrorAction SilentlyContinue) {
    $version = terraform --version | Select-Object -First 1
    Write-Host "   ✅ Terraform déjà installé: $version" -ForegroundColor Green
} else {
    Write-Host "   📦 Installation de Terraform via winget..." -ForegroundColor Yellow
    try {
        winget install --id HashiCorp.Terraform -e --silent --accept-package-agreements --accept-source-agreements
        Write-Host "   ✅ Terraform installé avec succès !" -ForegroundColor Green
        
        # Rafraîchir le PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        Start-Sleep -Seconds 2
        if (Get-Command terraform -ErrorAction SilentlyContinue) {
            $version = terraform --version | Select-Object -First 1
            Write-Host "   ✅ Vérifié: $version" -ForegroundColor Green
        }
    } catch {
        Write-Host "   ❌ Erreur lors de l'installation de Terraform" -ForegroundColor Red
        Write-Host "   💡 Installation manuelle: https://www.terraform.io/downloads" -ForegroundColor Yellow
    }
}

Write-Host ""

# 2. AWS CLI
Write-Host "2️⃣ Installation d'AWS CLI..." -ForegroundColor Cyan
if (Get-Command aws -ErrorAction SilentlyContinue) {
    $version = aws --version
    Write-Host "   ✅ AWS CLI déjà installé: $version" -ForegroundColor Green
} else {
    Write-Host "   📦 Installation d'AWS CLI via winget..." -ForegroundColor Yellow
    try {
        winget install --id Amazon.AWSCLI -e --silent --accept-package-agreements --accept-source-agreements
        Write-Host "   ✅ AWS CLI installé avec succès !" -ForegroundColor Green
        
        # Rafraîchir le PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        Start-Sleep -Seconds 2
        if (Get-Command aws -ErrorAction SilentlyContinue) {
            $version = aws --version
            Write-Host "   ✅ Vérifié: $version" -ForegroundColor Green
        }
    } catch {
        Write-Host "   ❌ Erreur lors de l'installation d'AWS CLI" -ForegroundColor Red
        Write-Host "   💡 Installation manuelle: https://awscli.amazonaws.com/AWSCLIV2.msi" -ForegroundColor Yellow
    }
}

Write-Host ""

# 3. kubectl
Write-Host "3️⃣ Installation de kubectl..." -ForegroundColor Cyan
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    $version = kubectl version --client --short 2>&1 | Select-Object -First 1
    Write-Host "   ✅ kubectl déjà installé: $version" -ForegroundColor Green
} else {
    Write-Host "   📦 Installation de kubectl via winget..." -ForegroundColor Yellow
    try {
        winget install --id Kubernetes.kubectl -e --silent --accept-package-agreements --accept-source-agreements
        Write-Host "   ✅ kubectl installé avec succès !" -ForegroundColor Green
        
        # Rafraîchir le PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        Start-Sleep -Seconds 2
        if (Get-Command kubectl -ErrorAction SilentlyContinue) {
            $version = kubectl version --client --short 2>&1 | Select-Object -First 1
            Write-Host "   ✅ Vérifié: $version" -ForegroundColor Green
        }
    } catch {
        Write-Host "   ❌ Erreur lors de l'installation de kubectl" -ForegroundColor Red
        Write-Host "   💡 Installation manuelle: https://kubernetes.io/docs/tasks/tools/" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  ✅ INSTALLATION TERMINÉE" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

Write-Host "📋 Prochaines étapes :" -ForegroundColor Yellow
Write-Host "1. Configurez AWS CLI: aws configure" -ForegroundColor Cyan
Write-Host "2. Créez une clé SSH AWS" -ForegroundColor Cyan
Write-Host "3. Déployez avec: cd terraform ; terraform init ; terraform apply" -ForegroundColor Cyan
Write-Host ""

