# Changelog

## [1.2.1] - 2025-01-21

### Corrections et améliorations

#### Scripts d'installation

- **install.bat** : Correction des chemins pour utiliser des slashes forward (/) au lieu de backslashes (\) dans la configuration Claude Desktop, garantissant une meilleure compatibilité cross-platform
- **install.ps1** : Amélioration de la gestion des chemins Windows avec conversion automatique des backslashes en slashes forward pour la configuration JSON de Claude Desktop

#### Gestion des logs

- **Niveau de logging** : Passage du niveau de logging de `DEBUG` à `WARNING` pour réduire la verbosité en production
- **Messages d'erreur** : Simplification des messages d'erreur retournés par les outils pour une meilleure lisibilité

#### Code

- **Suppression de l'import __version__** : Retrait de l'import non utilisé du module `__version__` dans le fichier principal, simplifiant l'initialisation du serveur MCP

## [1.2.0] - 2025-01-17

### Améliorations majeures

#### Système de ressources MCP

- **Ajout de 12 ressources de documentation intégrées** accessibles directement dans Claude
  - `legifrance://documentation/*` : 5 ressources (fonds, champs, types-recherche, options-tri, filtres-dates)
  - `judilibre://documentation/*` : 7 ressources (juridictions, chambres, localisations, types-decision, themes, solutions, options-tri)
- **Optimisation de la consommation de tokens** : La documentation technique est désormais accessible via des ressources au lieu d'être incluse dans chaque prompt
- **Accélération des réponses** : Réduction de la latence en évitant les appels systématiques à la documentation

#### 🏗️ Architecture et Code

- Nettoyage automatique des réponses API (suppression des valeurs `None` et vides)
- Amélioration de la gestion des erreurs avec messages plus explicites
- Harmonisation des commentaires et de la documentation

**⚠️ Changements de noms** : Les outils Légifrance et JudiLibre ont été renommés pour plus de cohérence et de clarté.

## [1.1.0] - Version - 2025-11-08

Outils MCP disponibles :

1. `rechercher_droit_francais()` - Recherche avancée Légifrance
2. `obtenir_article()` - Récupération d'articles juridiques
3. `rechercher_jurisprudence_judilibre()` - Recherche de jurisprudence
4. `obtenir_decision_judilibre()` - Récupération de décisions complètes
5. `obtenir_taxonomie_judilibre()` - Accès aux taxonomies

Cette version offre un accès complet et structuré aux API publiques du droit français (Légifrance et JudiLibre) via le protocole MCP. Le serveur est prêt pour une utilisation en production avec Claude Desktop et Cursor.

## [1.0.0] - Version initiale - 2025-10-19

Outils MCP disponibles :

1. `rechercher_droit_francais()` - Recherche avancée Légifrance
2. `obtenir_article()` - Récupération d'articles juridiques
3. `rechercher_jurisprudence_judilibre()` - Recherche de jurisprudence
4. `obtenir_decision_judilibre()` - Récupération de décisions complètes
5. `obtenir_taxonomie_judilibre()` - Accès aux taxonomies

Cette version initiale offre un accès complet et structuré aux API publiques du droit français (Légifrance et JudiLibre) via le protocole MCP. Le serveur est prêt pour une utilisation en production avec Claude Desktop.
