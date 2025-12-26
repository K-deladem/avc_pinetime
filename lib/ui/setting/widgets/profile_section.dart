import 'dart:io';

import 'package:flutter/material.dart';

/// Profile section widget displaying user avatar and name
class ProfileSection extends StatelessWidget {
  final String userName;
  final File? profileImage;
  final int imageTimestamp;
  final VoidCallback onEditName;
  final VoidCallback onPickImage;

  const ProfileSection({
    super.key,
    required this.userName,
    this.profileImage,
    required this.imageTimestamp,
    required this.onEditName,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          _buildProfileAvatar(context, theme),
          const SizedBox(height: 12),
          _buildProfileInfo(theme),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, ThemeData theme) {
    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: CircleAvatar(
            key: ValueKey(
                'avatar_${profileImage?.path ?? 'no_image'}_$imageTimestamp'),
            radius: 50,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            backgroundImage:
                profileImage != null ? FileImage(profileImage!) : null,
            onBackgroundImageError: profileImage != null
                ? (exception, stackTrace) {
                    // Image invalid, handled by child icon
                  }
                : null,
            child: profileImage == null
                ? Icon(
                    Icons.person,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  )
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onPickImage,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(ThemeData theme) {
    return Column(
      children: [
        Text(
          userName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton.icon(
          onPressed: onEditName,
          icon: Icon(
            Icons.edit,
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
          label: Text(
            'Modifier le nom',
            style: TextStyle(
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}
