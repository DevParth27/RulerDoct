import 'package:flutter/material.dart';

class TermsAndConditionsModal extends StatelessWidget {
  const TermsAndConditionsModal({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ContentBox(context),
    );
  }

  Widget ContentBox(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width * 0.85,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with decorative element
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Terms & Conditions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceVariant
                        .withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Row(
              children: [
                Icon(
                  Icons.policy_rounded,
                  size: 20,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'Last updated: May 10, 2025',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Terms content
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              height: screenSize.height * 0.4,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTermsSection(
                      context,
                      title: '1. Acceptance of Terms',
                      content:
                          'By accessing or using the Rural Care application ("App"), you agree to be bound by these Terms and Conditions. If you disagree with any part of these terms, you may not access the App.',
                      icon: Icons.handshake_outlined,
                    ),
                    _buildTermsSection(
                      context,
                      title: '2. Privacy Policy',
                      content:
                          'Our Privacy Policy explains how we collect, use, and protect the personal information that you provide to us. By using our App, you agree to the collection and use of information in accordance with this policy.',
                      icon: Icons.privacy_tip_outlined,
                    ),
                    _buildTermsSection(
                      context,
                      title: '3. Healthcare Information',
                      content:
                          'The App provides access to healthcare information and services. This information is provided for general educational purposes only and is not intended to be a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.',
                      icon: Icons.medical_information_outlined,
                    ),
                    _buildTermsSection(
                      context,
                      title: '4. User Accounts',
                      content:
                          'When you create an account with us, you must provide accurate, complete, and current information. You are responsible for safeguarding the password and for all activities that occur under your account. You agree to notify us immediately of any unauthorized use of your account.',
                      icon: Icons.account_circle_outlined,
                    ),
                    _buildTermsSection(
                      context,
                      title: '5. Limitations',
                      content:
                          'In no event shall Rural Care be liable for any damages arising out of the use or inability to use the services, including but not limited to direct, indirect, incidental, punitive, and consequential damages.',
                      icon: Icons.gavel_outlined,
                    ),
                    _buildTermsSection(
                      context,
                      title: '6. Changes to Terms',
                      content:
                          'We reserve the right to modify these terms at any time. We will notify users of any changes by updating the date at the top of these Terms and Conditions.',
                      icon: Icons.update_outlined,
                    ),
                    _buildTermsSection(
                      context,
                      title: '7. Governing Law',
                      content:
                          'These Terms shall be governed by the laws of the jurisdiction in which the App operates, without regard to its conflict of law provisions.',
                      icon: Icons.balance_outlined,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Accept button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'I Agree',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
