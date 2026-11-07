import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String amount; // already formatted, e.g. "$1,250.00"
  final IconData icon;
  final Color color;
  final bool isHighlighted;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    // A highlighted card has a solid background with white text.
    final Color backgroundColor = isHighlighted ? color : Colors.white;
    final Color titleColor =
        isHighlighted ? Colors.white70 : AppColors.textSecondary;
    final Color amountColor = isHighlighted ? Colors.white : color;
    final Color iconBackground = isHighlighted
        ? Colors.white.withValues(alpha: 0.2)
        : color.withValues(alpha: 0.12);
    final Color iconColor = isHighlighted ? Colors.white : color;

    return Card(
      elevation: 2,
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: iconBackground,
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // FittedBox shrinks the text if the amount is very large,
            // so it never overflows the card.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                amount,
                style: TextStyle(
                  color: amountColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}