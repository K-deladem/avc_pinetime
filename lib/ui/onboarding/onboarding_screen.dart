import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_event.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_states.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  ArmSide _affectedSide = ArmSide.left;
  int _currentStep = 0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep = 1;
        });
      }
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _completeOnboarding() {
    final settingsBloc = context.read<SettingsBloc>();
    final currentState = settingsBloc.state;

    if (currentState is SettingsLoaded) {
      print('Onboarding: État actuel isFirstLaunch=${currentState.settings.isFirstLaunch}');
      final updatedSettings = currentState.settings.copyWith(
        isFirstLaunch: false,
        userName: _nameController.text.trim(),
        affectedSide: _affectedSide,
      );
      print('Onboarding: Nouveau état isFirstLaunch=${updatedSettings.isFirstLaunch}');

      settingsBloc.add(UpdateSettings(updatedSettings));

      // Naviguer vers l'écran principal
      Navigator.of(context).pushReplacementNamed(AppRoutes.app);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentStep + 1) / 2,
                backgroundColor: theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),

              // Header
              Text(
                'Bienvenue!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Configurons votre profil',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Content
              Expanded(
                child: _currentStep == 0
                    ? _buildNameStep(theme)
                    : _buildAffectedSideStep(theme),
              ),

              // Navigation buttons
              Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton.icon(

                        onPressed: _previousStep,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Retour'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _nextStep,
                      icon: Icon(_currentStep == 0
                          ? Icons.arrow_forward
                          : Icons.check),
                      label: Text(_currentStep == 0 ? 'Suivant' : 'Commencer'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size.fromHeight(56),
                        side: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameStep(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
              child: ClipOval(
                child: Icon(
                  Icons.person,
                  size: 100,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Comment vous appelez-vous?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Votre prénom',
              hintText: 'Ex: Marie',
              prefixIcon: const Icon(Icons.badge_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Veuillez entrer votre prénom';
              }
              if (value.trim().length < 2) {
                return 'Le prénom doit contenir au moins 2 caractères';
              }
              return null;
            },
            onFieldSubmitted: (_) => _nextStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildAffectedSideStep(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
        Icon(
          Icons.accessible,
          size: 80,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 32),
        Text(
          'Quel est votre coté atteint?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Cette information nous aidera à personnaliser votre suivi de rééducation',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),

        // Arm selection cards
        Row(
          children: [
            Expanded(
              child: _buildArmCard(
                theme: theme,
                side: ArmSide.left,
                icon: Icons.waving_hand,
                label: 'Gauche',
                isSelected: _affectedSide == ArmSide.left,
                onTap: () {
                  setState(() {
                    _affectedSide = ArmSide.left;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildArmCard(
                theme: theme,
                side: ArmSide.right,
                icon: Icons.waving_hand,
                label: 'Droit',
                isSelected: _affectedSide == ArmSide.right,
                onTap: () {
                  setState(() {
                    _affectedSide = ArmSide.right;
                  });
                },
              ),
            ),
          ],
        ),
        ],
      ),
    );
  }

  Widget _buildArmCard({
    required ThemeData theme,
    required ArmSide side,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(

      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 48,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              if (isSelected) ...[
                const SizedBox(height: 8),
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

}
