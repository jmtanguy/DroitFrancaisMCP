@echo off
setlocal enabledelayedexpansion

:: Script d'installation du Serveur MCP Droit Français
:: Pour Windows

echo.
echo ========================================================
echo   Installation du Serveur MCP Droit Francais
echo ========================================================
echo.

:: Vérifier Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [X] Python n'est pas installe ou n'est pas dans le PATH.
    echo.
    echo Veuillez installer Python 3.8 ou superieur depuis :
    echo https://www.python.org/downloads/
    echo.
    echo N'oubliez pas de cocher "Add Python to PATH" lors de l'installation !
    pause
    exit /b 1
)

for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo [OK] Python detecte : %PYTHON_VERSION%
echo.

:: Créer l'environnement virtuel
echo [*] Creation de l'environnement virtuel...
if exist .venv (
    echo     L'environnement virtuel existe deja. Suppression...
    rmdir /s /q .venv
)
python -m venv .venv
if errorlevel 1 (
    echo [X] Erreur lors de la creation de l'environnement virtuel
    pause
    exit /b 1
)
echo [OK] Environnement virtuel cree
echo.

:: Activer l'environnement virtuel
echo [*] Activation de l'environnement virtuel...
call .venv\Scripts\activate.bat
if errorlevel 1 (
    echo [X] Erreur lors de l'activation de l'environnement virtuel
    pause
    exit /b 1
)
echo [OK] Environnement virtuel active
echo.

:: Mettre à jour pip
echo [*] Mise a jour de pip...
python -m pip install --upgrade pip --quiet
echo [OK] pip mis a jour
echo.

:: Installer les dépendances
echo [*] Installation des dependances...
if not exist requirements.txt (
    echo [X] Fichier requirements.txt introuvable
    pause
    exit /b 1
)
pip install -r requirements.txt
if errorlevel 1 (
    echo [X] Erreur lors de l'installation des dependances
    pause
    exit /b 1
)
echo [OK] Dependances installees
echo.

:: Vérifier l'installation
echo [*] Test du serveur MCP...
python -c "from fastmcp import FastMCP; print('[OK] FastMCP operationnel')"
if errorlevel 1 (
    echo [X] Erreur lors du test du serveur MCP
    pause
    exit /b 1
)
echo.

:: Convertir les chemins avec des slashes forward pour Claude Desktop
set "CURRENT_PATH=%CD%"
set "CURRENT_PATH=%CURRENT_PATH:\=/%"
set "PYTHON_PATH=%CURRENT_PATH%/.venv/Scripts/python.exe"
set "MCP_PATH=%CURRENT_PATH%/droit_francais_MCP.py"

:: Afficher les instructions de configuration
echo.
echo ========================================================
echo   Installation terminee !
echo ========================================================
echo.
echo Configuration Claude Desktop :
echo ==============================
echo.
echo 1. Ouvrir le fichier de configuration :
echo    %%APPDATA%%\Claude\claude_desktop_config.json
echo.
echo 2. Ajouter cette configuration :
echo.
echo {
echo   "mcpServers": {
echo     "droit-francais": {
echo       "command": "%PYTHON_PATH%",
echo       "args": ["%MCP_PATH%"]
echo     }
echo   }
echo }
echo.
echo 3. Redemarrer Claude Desktop
echo.
echo 4. Tester avec une question juridique comme :
echo    "Trouve-moi des articles sur le mariage dans le Code civil"
echo.
echo ========================================================
echo.
echo Note : Si vous avez des erreurs, verifiez que :
echo   - Les fichiers .env existent avec vos cles API
echo   - Python est bien dans le PATH
echo   - Claude Desktop est ferme avant de le redemarrer
echo.
pause
