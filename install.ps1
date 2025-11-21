# Script d'installation du Serveur MCP Droit Français
# Pour Windows (PowerShell)

# Activer les couleurs
$Host.UI.RawUI.ForegroundColor = "White"

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success {
    param([string]$Text)
    Write-Host "[OK] $Text" -ForegroundColor Green
}

function Write-Error {
    param([string]$Text)
    Write-Host "[X] $Text" -ForegroundColor Red
}

function Write-Info {
    param([string]$Text)
    Write-Host "[*] $Text" -ForegroundColor Yellow
}

# Titre
Write-Header "Installation du Serveur MCP Droit Français"

# Vérifier Python
Write-Info "Vérification de Python..."
try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Python détecté : $pythonVersion"
    } else {
        throw "Python non trouvé"
    }
} catch {
    Write-Error "Python n'est pas installé ou n'est pas dans le PATH."
    Write-Host ""
    Write-Host "Veuillez installer Python 3.8 ou supérieur depuis :" -ForegroundColor Yellow
    Write-Host "https://www.python.org/downloads/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "N'oubliez pas de cocher 'Add Python to PATH' lors de l'installation !" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}

# Créer l'environnement virtuel
Write-Info "Création de l'environnement virtuel..."
if (Test-Path ".venv") {
    Write-Info "L'environnement virtuel existe déjà. Suppression..."
    Remove-Item -Recurse -Force .venv
}

python -m venv .venv
if ($LASTEXITCODE -ne 0) {
    Write-Error "Erreur lors de la création de l'environnement virtuel"
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}
Write-Success "Environnement virtuel créé"

# Activer l'environnement virtuel
Write-Info "Activation de l'environnement virtuel..."
& ".\.venv\Scripts\Activate.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Erreur lors de l'activation de l'environnement virtuel"
    Write-Host ""
    Write-Host "Si vous avez une erreur d'exécution de script, exécutez :" -ForegroundColor Yellow
    Write-Host "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}
Write-Success "Environnement virtuel activé"

# Mettre à jour pip
Write-Info "Mise à jour de pip..."
python -m pip install --upgrade pip --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Success "pip mis à jour"
} else {
    Write-Error "Erreur lors de la mise à jour de pip"
}

# Installer les dépendances
Write-Info "Installation des dépendances..."
if (-not (Test-Path "requirements.txt")) {
    Write-Error "Fichier requirements.txt introuvable"
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}

pip install -r requirements.txt
if ($LASTEXITCODE -ne 0) {
    Write-Error "Erreur lors de l'installation des dépendances"
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}
Write-Success "Dépendances installées"

# Vérifier l'installation
Write-Info "Test du serveur MCP..."
python -c "from fastmcp import FastMCP; print('[OK] FastMCP opérationnel')"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Erreur lors du test du serveur MCP"
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}

# Configuration Claude Desktop
$currentPath = (Get-Location).Path -replace '\\', '/'
$pythonPath = "$currentPath/.venv/Scripts/python.exe"
$mcpPath = "$currentPath/droit_francais_MCP.py"
$configPath = Join-Path $env:APPDATA "Claude" | Join-Path -ChildPath "claude_desktop_config.json"

Write-Header "Installation terminée !"

Write-Host "Configuration Claude Desktop :" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""

# Vérifier si le fichier de config existe
if (Test-Path $configPath) {
    Write-Info "Fichier de configuration Claude détecté"
    Write-Host ""
    Write-Host "Le fichier de configuration existe déjà ici :" -ForegroundColor Yellow
    Write-Host $configPath -ForegroundColor White
    Write-Host ""
    Write-Host "Voulez-vous le mettre à jour automatiquement ? (O/N)" -ForegroundColor Yellow
    $response = Read-Host

    if ($response -eq "O" -or $response -eq "o") {
        # Backup de l'ancien fichier
        $backupPath = "$configPath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item $configPath $backupPath
        Write-Success "Backup créé : $backupPath"

        # Lire la config actuelle
        $config = Get-Content $configPath -Raw | ConvertFrom-Json

        # Ajouter ou mettre à jour le serveur MCP
        if (-not $config.mcpServers) {
            $config | Add-Member -MemberType NoteProperty -Name "mcpServers" -Value @{}
        }

        $config.mcpServers | Add-Member -MemberType NoteProperty -Name "droit-francais" -Value @{
            command = $pythonPath
            args = @($mcpPath)
        } -Force

        # Sauvegarder
        $config | ConvertTo-Json -Depth 10 | Set-Content $configPath
        Write-Success "Configuration mise à jour automatiquement"
    } else {
        Write-Host ""
        Write-Host "Configuration manuelle requise." -ForegroundColor Yellow
        Write-Host "Ouvrez le fichier :" -ForegroundColor Yellow
        Write-Host $configPath -ForegroundColor White
        Write-Host ""
        Write-Host "Et ajoutez cette configuration :" -ForegroundColor Yellow
        Write-Host ""
    }
} else {
    Write-Info "Création du fichier de configuration Claude Desktop..."

    # Créer le dossier si nécessaire
    $configDir = Split-Path $configPath
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }

    # Créer la config
    $config = @{
        mcpServers = @{
            "droit-francais" = @{
                command = $pythonPath
                args = @($mcpPath)
            }
        }
    }

    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath
    Write-Success "Fichier de configuration créé : $configPath"
}

Write-Host ""
Write-Host "Configuration JSON à utiliser (si besoin) :" -ForegroundColor Cyan
Write-Host "{" -ForegroundColor White
Write-Host '  "mcpServers": {' -ForegroundColor White
Write-Host '    "droit-francais": {' -ForegroundColor White
Write-Host "      `"command`": `"$pythonPath`"," -ForegroundColor White
Write-Host "      `"args`": [`"$mcpPath`"]" -ForegroundColor White
Write-Host '    }' -ForegroundColor White
Write-Host '  }' -ForegroundColor White
Write-Host "}" -ForegroundColor White
Write-Host ""

Write-Host "Prochaines étapes :" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Redémarrer Claude Desktop (fermez complètement et relancez)" -ForegroundColor Yellow
Write-Host ""
Write-Host "2. Vérifier que les fichiers .env existent avec vos clés API :" -ForegroundColor Yellow
Write-Host "   - LEGIFRANCE_CLIENT_ID" -ForegroundColor White
Write-Host "   - LEGIFRANCE_CLIENT_SECRET" -ForegroundColor White
Write-Host "   - JUDILIBRE_API_KEY" -ForegroundColor White
Write-Host ""
Write-Host "3. Tester avec une question juridique comme :" -ForegroundColor Yellow
Write-Host "   'Trouve-moi des articles sur le mariage dans le Code civil'" -ForegroundColor Cyan
Write-Host ""

Write-Header "Installation complète ! Bon usage ⚖️"

Read-Host "Appuyez sur Entrée pour quitter"
