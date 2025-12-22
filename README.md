# flutter-bloc-app-template 🤖
This is a basic Flutter project template that uses the BLoC pattern architecture for state management. 
It is a good starting point for creating a new Flutter app that uses BLoC for state management.

This template is focused on delivering a project with **static analysis** and **continuous integration** already in place.

[![style: lint][lint-style-badge]][lint-style-link]
[![codecov][codecov-badge]][codecov-link]
[![CI][ci-badge]][ci-link]
[![CodeFactor][codefactor-badge]][codefactor-link]
[![License][license-badge]][license-link]
[![style: effective dart][style-badge]][style-link]
[![GitHub forks][forks-badge]][forks-link]
[![GitHub stars][stars-badge]][stars-link]
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/1c12bf943fea43098f0853a05e2366be)](https://app.codacy.com/gh/ashtanko/flutter_bloc_app_template/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)
[![Codacy Badge](https://app.codacy.com/project/badge/Coverage/1c12bf943fea43098f0853a05e2366be)](https://app.codacy.com/gh/ashtanko/flutter_bloc_app_template/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_coverage)

## How to use 🐾
Just click on [![Use this template](https://img.shields.io/badge/-Use%20this%20template-brightgreen)](https://github.com/ashtanko/flutter_bloc_app_template/generate) button to create a new repo starting from this template.

## Features 🦄
- Theme support
- BLoC pattern [**bloc**](https://pub.dev/packages/bloc)
- Service Locator using [**get_it**](https://pub.dev/packages/get_it)
- Localization using [**intl**](https://pub.dev/packages/intl)
- CI Setup with GitHub Actions
- Codecov Setup with GitHub Actions
- Unit test coverage

## Configuration
The template has 3 flavors:
- dev
- prod
- qa

The template has 3 build variants:
- debug
- profile
- release

For example dev configuration for Android Studio looks like:

<p align="left">
<img src="/preview/config/dev.png" width="32%"/>
</p>

## Android Screenshots
<p align="left">
<img src="/preview/android/widgets.jpg" width="32%"/>
<img src="/preview/android/light_theme.png" width="32%"/>
<img src="/preview/android/dark_theme.png" width="32%"/>
<img src="/preview/android/yellow_theme.png" width="32%"/>
<img src="/preview/android/settings.png" width="32%"/>
<img src="/preview/android/theme_bottom_sheet.png" width="32%"/>
</p>

## iOS Screenshots
<p align="left">
<img src="/preview/ios/widgets.png" width="32%"/>
<img src="/preview/ios/light_theme.png" width="32%"/>
<img src="/preview/ios/dark_theme.png" width="32%"/>
<img src="/preview/ios/yellow_theme.png" width="32%"/>
<img src="/preview/ios/settings.png" width="32%"/>
<img src="/preview/ios/theme_bottom_sheet.png" width="32%"/>
</p>


## Static Analysis 

This template is using [**analyzer**](https://pub.dev/packages/analyzer)

Supported Lint [**Rules**](https://dart-lang.github.io/linter/lints/)

Supported Dart Code [**Metrics**](https://dartcodemetrics.dev/docs/getting-started/introduction)

Dart [**Lint**](https://github.com/passsy/dart-lint)

## CI ⚙Warning
This template is using [**GitHub Actions**](https://github.com/ashtanko/flutter_app_skeleton/actions) as CI. You don't need to setup any external service and you should have a running CI once you start using this template.

## How to build 🛠Warning

The Project uses [**FlutterGen**](https://github.com/FlutterGen/flutter_gen) to generate localizations, dependencies and mocks

Activate flutter_gen using dart pub global activate flutter_gen command if you haven't done that before.

after add export PATH="$PATH":"$HOME/.pub-cache/bin" to bash_profile

``` bash
# clean project, install dependencies & generate sources
make

# generate localizations, dependencies, image assets, colors, fonts
make gen

# generate localizations
make localize

# analyze the project
check
```

## Reminders 🧠
Change name in pubspec.yaml file

Remove anything you don't need

Configure analysis_options.yaml for your needs

## Contributing 🤝

Feel free to open a issue or submit a pull request for any bugs/improvements.

## License 📄

This template is licensed under the MIT License - see the [License](LICENSE) file for details.
Please note that the generated template is offering to start with a MIT license but you can change it to whatever you wish, as long as you attribute under the MIT terms that you're using the template.

[lint-style-badge]: https://img.shields.io/badge/style-lint-4BC0F5.svg
[lint-style-link]: https://pub.dev/packages/lint
[codecov-badge]: https://codecov.io/gh/ashtanko/flutter_bloc_app_template/branch/main/graph/badge.svg?token=T68Rqwj7Ll
[codecov-link]: https://codecov.io/gh/ashtanko/flutter_bloc_app_template
[ci-badge]: https://github.com/ashtanko/flutter_bloc_app_template/actions/workflows/ci.yml/badge.svg
[ci-link]: https://github.com/ashtanko/flutter_bloc_app_template/actions/workflows/ci.yml
[codefactor-badge]: https://www.codefactor.io/repository/github/ashtanko/flutter_bloc_app_template/badge
[codefactor-link]: https://www.codefactor.io/repository/github/ashtanko/flutter_bloc_app_template
[license-badge]: https://img.shields.io/github/license/dart-code-checker/dart-code-metrics
[license-link]: https://github.com/dart-code-checker/dart-code-metrics/blob/master/LICENSE
[style-badge]: https://img.shields.io/badge/style-effective_dart-40c4ff.svg
[style-link]: https://pub.dev/packages/effective_dart
[forks-badge]: https://img.shields.io/github/forks/ashtanko/flutter_bloc_app_template
[forks-link]: https://github.com/ashtanko/flutter_bloc_app_template/network
[stars-badge]: https://img.shields.io/github/stars/ashtanko/flutter_bloc_app_template
[stars-link]: https://github.com/ashtanko/flutter_bloc_app_template/stargazers

# 📌 Gestion des Langues dans Flutter avec `.arb` et `intl_utils`

Ce guide explique comment ajouter et gérer plusieurs langues dans une application **Flutter** en utilisant les fichiers `.arb` et le package **`intl_utils`**.

---

## **🌍 Ajout d'une Nouvelle Langue**

### **📌 1Warning⃣ Installer les dépendances**

Ajoutez la dépendance suivante dans votre fichier **`pubspec.yaml`** si ce n'est pas déjà fait :

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any

dev_dependencies:
  intl_utils: ^2.8.2
```

Puis exécutez :

```sh
flutter pub get
```

---

### **📌 2Warning⃣ Créer un fichier `.arb` pour une nouvelle langue**

Les fichiers `.arb` sont stockés dans le dossier **`lib/l10n/`**. Voici un exemple pour **le français (fr)**, **l’anglais (en)** et **l’espagnol (es)** :

📂 **Structure du projet** :

```
lib/
├── l10n/
│   ├── intl_en.arb  (Anglais - Langue principale)
│   ├── intl_fr.arb  (Français)
│   ├── intl_es.arb  (Espagnol)
```

---

### **📌 3Warning⃣ Ajouter un fichier `.arb` pour une nouvelle langue**

1Warning⃣ **Créer un fichier** pour la nouvelle langue, ex : **`intl_de.arb`** pour l’**allemand**.

2Warning⃣ **Copier le contenu d’un fichier existant** (`intl_en.arb`) et le **traduire**.

📄 **Exemple `intl_de.arb` (Allemand)** :

```json
{
  "@@locale": "de",
  "appTitle": "Flutter App",
  "homeTitle": "Startseite",
  "settings": "Einstellungen",
  "changeLanguage": "Sprache ändern"
}
```

 **Remarque** :
- `@@locale` doit contenir **le code de la langue** (`"de"` pour allemand, `"fr"` pour français, etc.).
- Chaque clé doit **correspondre aux clés des autres `.arb`** pour que la génération fonctionne correctement.

---

### **📌 4Warning⃣ Générer les fichiers de traduction**

Après avoir ajouté une nouvelle langue, exécutez la commande suivante pour **générer automatiquement les fichiers de traduction** :

```sh
flutter pub run intl_utils:generate
```

Vous pouvez maintenant utiliser les traductions **dans votre code Flutter** comme ceci :

```dart
Text(S.of(context).homeTitle) // Affiche "Accueil" en français, "Home" en anglais, etc.
```

---

### **📌 5Warning⃣ Modifier `MaterialApp` pour utiliser la localisation**

Ajoutez la prise en charge de la localisation dans **`lib/main.dart`** ou **`lib/app.dart`** :

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: S.of(context).appTitle,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: const HomeScreen(),
    );
  }
}
```

---

### **📌 6Warning⃣ Changer la langue dynamiquement dans l’application**

Ajoutez un bouton permettant de changer la langue :

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Locale>(
      value: Localizations.localeOf(context),
      items: S.delegate.supportedLocales.map((locale) {
        return DropdownMenuItem(
          value: locale,
          child: Text(locale.languageCode.toUpperCase()), // Affiche "EN", "FR", etc.
        );
      }).toList(),
      onChanged: (Locale? newLocale) {
        if (newLocale != null) {
          S.load(newLocale);
          (context as Element).markNeedsBuild(); // Recharge l'UI avec la nouvelle langue
        }
      },
    );
  }
}
```

---

## **  Résumé des étapes**

| Étape | Action |
|-------|--------|
| 🛠Warning 1Warning⃣ | **Ajouter `intl_utils` dans `pubspec.yaml`** |
| 📂 2Warning⃣ | **Créer un fichier `.arb` (`intl_fr.arb`, `intl_es.arb`...)** |
| 3Warning⃣ | **Ajouter les traductions dans chaque `.arb`** |
| ⚡ 4Warning⃣ | **Exécuter `flutter pub run intl_utils:generate`** |
| 🎨 5Warning⃣ | **Utiliser `S.of(context).key` pour afficher les traductions** |
| 6Warning⃣ | **Ajouter un menu pour changer la langue dynamiquement** |

---

## ** FAQ**

### ❓ **Pourquoi utiliser `intl_utils` au lieu de `flutter_localizations` natif ?**
- **Génération automatique** des fichiers `S.dart`.
- **Meilleure gestion des traductions** et compatibilité avec `.arb`.

### ❓ **Que faire si `S.delegate` ne fonctionne pas ?**
- Vérifiez que **`intl_utils` est bien installé**.
- Supprimez **`.dart_tool/`** et relancez :
  ```sh
  flutter clean
  flutter pub get
  flutter pub run intl_utils:generate
  ```

### ❓ **Comment ajouter plus de langues ?**
Ajoutez un fichier `intl_xx.arb` (ex: `intl_it.arb` pour l’italien), puis **exécutez la commande de génération**.

---

🚀 **Votre application Flutter est maintenant prête pour la gestion multilingue avec `intl_utils` et `.arb` !** 🎉

