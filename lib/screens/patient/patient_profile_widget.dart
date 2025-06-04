import 'package:flutter/material.dart';
import 'package:rolodoct/models/user_model.dart';
import 'package:rolodoct/utils/aboutUs.dart';
import 'package:rolodoct/widgets/common_widgets.dart';

class PatientProfileWidget extends StatelessWidget {
  final UserModel patient;
  final Function() onSignOut;

  const PatientProfileWidget({
    super.key,
    required this.patient,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        // Profile Header
        const PageHeader(title: 'My Profile', icon: Icons.person_rounded),
        const SizedBox(height: 24),

        // Profile image and name
        Center(
          child: Column(
            children: [
              Hero(
                tag: 'profile-${patient.id}',
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                  child: Text(
                    patient.name.isNotEmpty
                        ? patient.name[0].toUpperCase()
                        : 'P',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                patient.name,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              if (patient.phone != null && patient.phone!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    patient.phone!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Profile Details Card
        //  _buildProfileCard(theme),
        const SizedBox(height: 24),

        // Account Settings Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Account action items
              _buildSettingsItem(
                theme,
                'Notification Settings',
                Icons.notifications_none,
                theme.colorScheme.tertiary,
                () {
                  AppToast.show(context, 'Notification settings coming soon!');
                },
              ),
              Divider(color: theme.colorScheme.outline.withOpacity(0.3)),
              _buildSettingsItem(
                theme,
                'About Us',
                Icons.info_outline,
                theme.colorScheme.secondary,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutUsPage()),
                  );
                },
              ),

              Divider(color: theme.colorScheme.outline.withOpacity(0.3)),
              _buildSettingsItem(
                theme,
                'Sign Out',
                Icons.logout,
                theme.colorScheme.error,
                onSignOut,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // App version info
        Center(
          child: Text(
            'Version 1.1.2',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProfileCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Placeholder health metrics
          Row(
            children: [
              Expanded(
                child: _buildHealthMetric(
                  theme,
                  'Blood Type',
                  'A+',
                  Icons.bloodtype,
                  theme.colorScheme.error,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHealthMetric(
                  theme,
                  'Height',
                  '5\'8"',
                  Icons.height,
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHealthMetric(
                  theme,
                  'Weight',
                  '70 kg',
                  Icons.monitor_weight_outlined,
                  theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Update health info button
          Center(
            child: TextButton.icon(
              onPressed: () {
                // This would be implemented in a real app
              },
              icon: Icon(
                Icons.edit,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              label: Text(
                'Update Health Information',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetric(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    ThemeData theme,
    String title,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
