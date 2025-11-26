import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final Color lightGreenText = const Color(0xFFA2F46E);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$currentStep/$totalSteps',
              style: TextStyle(
                color: lightGreenText.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: currentStep / totalSteps,
          backgroundColor: lightGreenText.withOpacity(0.3), // Background of the progress bar
          valueColor: AlwaysStoppedAnimation<Color>(lightGreenText), // Color of the progress
          minHeight: 10, // Height of the progress bar
          borderRadius: BorderRadius.circular(5), // Rounded corners for the progress bar
        ),
      ],
    );
  }
} 