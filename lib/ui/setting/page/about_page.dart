import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  static const routeName = '/about';

  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String appName = "Nom de l'application";
  String version = "1.0.0";
  String buildNumber = "1";

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appName = info.appName;
      version = info.version;
      buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).about), elevation: 0,
          scrolledUnderElevation: 3,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface, centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [

                Text(
                  appName,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Version $version (build $buildNumber)",
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text("Politique de confidentialité"),
            onTap: () {
              // Naviguer ou afficher un lien
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Politique de confidentialité"),
                  content: const Text("La politique de confidentialité sera ajoutée ici."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text(S.of(context).close)),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text("Conditions d’utilisation"),
            onTap: () {
              // Naviguer ou afficher un lien
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Conditions d’utilisation"),
                  content: const Text("Les conditions d'utilisation seront ajoutées ici."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text(S.of(context).close)),
                  ],
                ),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("Crédits"),
            subtitle: Text("Développé par l’équipe Santé & Tech – 2025"),
          ),
        ],
      ),
    );
  }
}