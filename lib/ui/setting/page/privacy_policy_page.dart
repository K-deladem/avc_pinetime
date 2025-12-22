import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  static const routeName = '/privacyPolicy';

  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Politique de confidentialité"),
          elevation: 0,
          scrolledUnderElevation: 3,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface, centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Dernière mise à jour : 1er mai 2025",
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              "1. Introduction",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Nous nous engageons à protéger votre vie privée. Cette politique explique quelles données nous collectons, pourquoi, et comment elles sont utilisées dans le cadre de notre application.",
            ),
            const SizedBox(height: 16),
            Text(
              "2. Données collectées",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Nous collectons des données liées à votre activité dans l’application, y compris votre nom, vos préférences, vos objectifs de rééducation, et les données d'utilisation des montres connectées. Ces informations servent uniquement à améliorer votre expérience et à assurer un suivi personnalisé.",
            ),
            const SizedBox(height: 16),
            Text(
              "3. Utilisation des données",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Les données sont utilisées pour afficher vos progrès, vous notifier lorsque vous atteignez vos objectifs, et personnaliser les fonctionnalités de l’application. Aucune donnée n’est partagée avec des tiers sans votre consentement.",
            ),
            const SizedBox(height: 16),
            Text(
              "4. Sécurité",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Vos données sont stockées localement sur votre appareil. Nous ne transmettons aucune information vers des serveurs distants sans votre autorisation explicite.",
            ),
            const SizedBox(height: 16),
            Text(
              "5. Vos droits",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Vous pouvez à tout moment consulter, modifier ou supprimer vos données depuis l’application. Pour toute demande spécifique, vous pouvez contacter notre support.",
            ),
            const SizedBox(height: 16),
            Text(
              "6. Contact",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Pour toute question relative à cette politique, veuillez contacter : support@monapp.com.",
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                "Merci d'utiliser notre application !",
                style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}