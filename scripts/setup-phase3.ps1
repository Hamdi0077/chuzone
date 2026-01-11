# Script d'automatisation Phase 3 - Infrastructure AWS
# Ce script vérifie et prépare l'environnement pour Phase 3

Write-Host "=== Phase 3 : Préparation Infrastructure AWS ===" -ForegroundColor Cyan

# Vérifier Terraform
if (Get-Command terraform -ErrorAction SilentlyContinue) {
    $terraformVersion = terraform --version | Select-Object -First 1
    Write-Host "✅ Terraform installé: $terraformVersion" -ForegroundColor Green
} else {
    Write-Host "❌ Terraform n'est pas installé" -ForegroundColor Red
    Write-Host "💡 Installation recommandée:" -ForegroundColor Yellow
    Write-Host "   winget install --id HashiCorp.Terraform -e" -ForegroundColor Gray
    Write-Host "   ou" -ForegroundColor Gray
    Write-Host "   choco install terraform -y (nécessite admin)" -ForegroundColor Gray
}

# Vérifier AWS CLI
if (Get-Command aws -ErrorAction SilentlyContinue) {
    $awsVersion = aws --version
    Write-Host "✅ AWS CLI installé: $awsVersion" -ForegroundColor Green
    
    # Vérifier la configuration
    try {
        $identity = aws sts get-caller-identity 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ AWS CLI configuré correctement" -ForegroundColor Green
            Write-Host $identity -ForegroundColor Gray
        } else {
            Write-Host "⚠️ AWS CLI n'est pas configuré" -ForegroundColor Yellow
            Write-Host "💡 Configurez avec: aws configure" -ForegroundColor Gray
        }
    } catch {
        Write-Host "⚠️ AWS CLI n'est pas configuré" -ForegroundColor Yellow
        Write-Host "💡 Configurez avec: aws configure" -ForegroundColor Gray
    }
} else {
    Write-Host "❌ AWS CLI n'est pas installé" -ForegroundColor Red
    Write-Host "💡 Installation recommandée:" -ForegroundColor Yellow
    Write-Host "   winget install --id Amazon.AWSCLI -e" -ForegroundColor Gray
    Write-Host "   ou téléchargez depuis: https://awscli.amazonaws.com/AWSCLIV2.msi" -ForegroundColor Gray
}

# Vérifier la clé SSH
$sshKeyPath = "$env:USERPROFILE\.ssh\k8s-keypair"
if (Test-Path $sshKeyPath) {
    Write-Host "✅ Clé SSH trouvée: $sshKeyPath" -ForegroundColor Green
} else {
    Write-Host "⚠️ Clé SSH non trouvée" -ForegroundColor Yellow
    Write-Host "💡 Créez une clé SSH avec:" -ForegroundColor Gray
    Write-Host "   ssh-keygen -t rsa -b 4096 -f `$env:USERPROFILE\.ssh\k8s-keypair -N `"`"" -ForegroundColor Gray
}

# Vérifier la configuration Terraform
Push-Location terraform
if (Test-Path terraform.tfvars) {
    Write-Host "✅ terraform.tfvars trouvé" -ForegroundColor Green
} else {
    Write-Host "⚠️ terraform.tfvars non trouvé" -ForegroundColor Yellow
    Write-Host "💡 Créez depuis terraform.tfvars.example" -ForegroundColor Gray
}

if (Test-Path .terraform) {
    Write-Host "✅ Terraform initialisé" -ForegroundColor Green
} else {
    Write-Host "⚠️ Terraform non initialisé" -ForegroundColor Yellow
    Write-Host "💡 Initialisez avec: terraform init" -ForegroundColor Gray
}
Pop-Location

Write-Host ""
Write-Host "✅ Vérification Phase 3 terminée !" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Prochaines étapes:" -ForegroundColor Yellow
Write-Host "1. Installez Terraform et AWS CLI (voir INSTALL_PREREQUISITES.md)" -ForegroundColor Cyan
Write-Host "2. Configurez AWS: aws configure" -ForegroundColor Cyan
Write-Host "3. Créez la clé SSH AWS" -ForegroundColor Cyan
Write-Host "4. Déployez: cd terraform ; terraform init ; terraform apply" -ForegroundColor Cyan
Write-Host ""

