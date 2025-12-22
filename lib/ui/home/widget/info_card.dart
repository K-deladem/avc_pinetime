import 'package:flutter/material.dart';

class InfoCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String description;
  final String buttonText;
  final IconData icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onButtonPressed;
  final VoidCallback? onClosePressed;
  final Widget alternativeWidget;

  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.buttonText,
    this.icon = Icons.info,
    this.backgroundColor,
    this.borderColor,
    this.onButtonPressed,
    this.onClosePressed,
    required this.alternativeWidget,
  });

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isVisible ? _buildContent(context) : widget.alternativeWidget,
    );
  }

  /// **Contenu principal de la carte**
  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      height: 380,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:  Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              // --- IMAGE DE GAUCHE ---
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/pinetime-fr.png',
                  width: 100,
                  height: 380,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),

              // --- CONTENU TEXTE ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- HEADER ---
                    Row(
                      children: [
                        _iconContainer(),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                    fontSize: 10),
                              ),
                              Text(
                                widget.subtitle,
                                style: textTheme.bodySmall?.copyWith(
                                fontSize: 8,
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // --- DESCRIPTION ---
                    Text(
                      widget.description,
                      textAlign: TextAlign.justify,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // --- BOUTON ---

                    Align(
                      alignment: Alignment.bottomLeft,
                      child: TextButton(
                        onPressed: widget.onButtonPressed,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 30),
                        ),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Action : Voir détails, historique, etc.
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: Text(
                            widget.buttonText,
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                              fontSize: 10,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),

          // --- BOUTON FERMETURE ---
          Positioned(
            top: 1,
            right: 1,
            child: InkWell(
              onTap: () {
                setState(() {
                  isVisible = false;
                });
                widget.onClosePressed?.call();
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// **Widget pour l'icône dans un cadre**
  Widget _iconContainer() {
    final theme = Theme.of(context);
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          // Bordure fine gris clair
          width: 0.8, // Bordure plus fine
        ),
        borderRadius: BorderRadius.circular(8), // Légère courbure pour l'icône
      ),
      child: const Icon(
        Icons.info,
        size: 20,
      ),
    );
  }
}
