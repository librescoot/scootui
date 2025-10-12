import 'package:flutter/material.dart';

import '../../state/internet.dart';
import 'indicator_light.dart';

class InternetIndicator extends StatelessWidget {
  final String iconName;
  final InternetData internet;
  final Color color;
  final double size;

  const InternetIndicator({
    super.key,
    required this.iconName,
    required this.internet,
    required this.color,
    this.size = 24.0,
  });

  String _formatAccessTech(String accessTech) {
    if (accessTech.isEmpty) return '';

    // Handle common formats like "LTE", "4G", "5G", "3G", "2G", "GSM", etc.
    final tech = accessTech.toUpperCase();

    // Prefer shorter forms for display
    if (tech.contains('5G')) return '5G';
    if (tech.contains('LTE') || tech.contains('4G')) return '4G';
    if (tech.contains('3G') || tech.contains('UMTS') || tech.contains('HSPA')) return '3G';
    if (tech.contains('2G') || tech.contains('EDGE') || tech.contains('GPRS')) return '2G';
    if (tech.contains('GSM')) return 'G';

    // For other values, try to extract a short version
    // Take first 3 characters if it's longer
    return tech.length > 3 ? tech.substring(0, 3) : tech;
  }

  @override
  Widget build(BuildContext context) {
    final accessTech = _formatAccessTech(internet.accessTech);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          IndicatorLight(
            icon: IndicatorLight.svgAsset(iconName),
            isActive: true,
            activeColor: color,
            size: size,
          ),
          if (accessTech.isNotEmpty)
            Positioned(
              top: 1,
              left: 0,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: size * 0.55, // ~80/144
                  maxHeight: size * 0.42, // ~60/144
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topLeft,
                  child: Text(
                    accessTech,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: size * 0.6,
                      height: 1.0,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
