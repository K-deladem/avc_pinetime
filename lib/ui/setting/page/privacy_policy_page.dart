import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/constants/app_constants.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';

class PrivacyPolicyPage extends StatelessWidget {
  static const routeName = '/privacyPolicy';

  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).privacyPolicyTitle),
          elevation: 0,
          scrolledUnderElevation: 3,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface, centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              S.of(context).lastUpdated("1er mai 2025"),
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).introductionTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).introductionContent,
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).dataCollectedTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).dataCollectedContent,
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).dataUsageTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).dataUsageContent,
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).securityTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).securityContent,
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).yourRightsTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).yourRightsContent,
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).contactTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).contactPolicyContent(AppConfig.supportEmail),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                S.of(context).thankYouForUsing,
                style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}