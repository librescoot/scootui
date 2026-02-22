import 'package:flutter/material.dart';

class NonCommercialOverlay extends StatelessWidget {
  const NonCommercialOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9);
    final textColor = isDark ? Colors.white : Colors.black;
    final accentColor = Colors.redAccent;

    return Positioned(
      bottom: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: accentColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: accentColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'LibreScoot / ScootUI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'Non-commercial software',
                    style: TextStyle(
                      fontSize: 11,
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Commercial distribution prohibited',
                    style: TextStyle(
                      fontSize: 10,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
