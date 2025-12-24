import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_event.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_states.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});
  static const route = '/profileSettings';

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _nameController = TextEditingController();
  final _imagePicker = ImagePicker();
  String? _selectedImagePath;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        // Copier l'image dans le dossier de l'application
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
        final savedImage = File('${appDir.path}/$fileName');
        await File(image.path).copy(savedImage.path);

        if (!mounted) return;

        setState(() {
          _selectedImagePath = savedImage.path;
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection de l\'image: $e')),
        );
      }
    }
  }

  void _saveProfile(BuildContext context, SettingsState state) {
    if (state is! SettingsLoaded) return;

    final settings = state.settings;
    final newName = _nameController.text.trim();

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom ne peut pas être vide')),
      );
      return;
    }

    final updated = settings.copyWith(
      userName: newName,
      profileImagePath: _selectedImagePath ?? settings.profileImagePath,
    );

    context.read<SettingsBloc>().add(UpdateSettings(updated));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil mis à jour avec succès')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        elevation: 0,
        scrolledUnderElevation: 3,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        centerTitle: true,
        actions: [
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.check),
                onPressed: () => _saveProfile(context, state),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is! SettingsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = state.settings;

          // Initialiser le contrôleur avec le nom actuel
          if (_nameController.text.isEmpty) {
            _nameController.text = settings.userName;
          }

          // Utiliser l'image sélectionnée ou celle des settings
          final imagePath = _selectedImagePath ?? settings.profileImagePath;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Photo de profil
                GestureDetector(
                  onTap: () => _pickImage(context),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        // OPTIMISÉ: Pas de File.existsSync() bloquant
                        // On laisse Image.file avec errorBuilder gérer les fichiers manquants
                        child: imagePath != null && imagePath.isNotEmpty
                            ? ClipOval(
                                child: Image.file(
                                  File(imagePath),
                                  width: 140,
                                  height: 140,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person,
                                      size: 70,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 70,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                Text(
                  'Appuyez pour changer la photo',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.6),
                      ),
                ),

                const SizedBox(height: 40),

                // Champ de nom
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom d\'utilisateur',
                    hintText: 'Entrez votre nom',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Bouton pour supprimer la photo
                if (imagePath != null)
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedImagePath = null;
                      });
                      final updated = settings.copyWith(
                        profileImagePath: null,
                      );
                      context.read<SettingsBloc>().add(UpdateSettings(updated));
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Supprimer la photo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
