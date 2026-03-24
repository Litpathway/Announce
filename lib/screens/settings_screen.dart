import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navyBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: syne800(19)),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'Coming soon',
                  style: dmSans400(14, color: textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
