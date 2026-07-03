import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No active profile found.')),
      );
    }

    final initials = user.name.isNotEmpty 
        ? user.name.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'U';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
                ? [AppTheme.bgDark, const Color(0xFF1E293B)] 
                : [Colors.white, const Color(0xFFEFF6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Avatar representation
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: user.role == 'admin' ? AppTheme.secondaryAmber : AppTheme.primaryBlue,
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: (user.role == 'admin' ? AppTheme.secondaryAmber : AppTheme.primaryBlue).withOpacity(0.1),
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: user.role == 'admin' ? AppTheme.secondaryAmber : AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.role.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: user.role == 'admin' ? AppTheme.secondaryAmber : AppTheme.accentTeal,
                  ),
                ),
                const SizedBox(height: 36),
                // Details Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildProfileField(
                          icon: Icons.email_outlined,
                          label: 'Email Address',
                          value: user.email,
                          isDark: isDark,
                        ),
                        const Divider(height: 24),
                        _buildProfileField(
                          icon: Icons.badge_outlined,
                          label: 'Access Level',
                          value: user.role == 'admin' ? 'Administrator' : 'Railway Employee',
                          isDark: isDark,
                        ),
                        if (user.role == 'user' && appState.selectedZone != null) ...[
                          const Divider(height: 24),
                          _buildProfileField(
                            icon: Icons.train_outlined,
                            label: 'Assigned Railway Zone',
                            value: appState.selectedZone!,
                            isDark: isDark,
                          ),
                        ],
                        const Divider(height: 24),
                        _buildProfileField(
                          icon: Icons.calendar_month_outlined,
                          label: 'Account Created',
                          value: '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Log Out Button
                ElevatedButton.icon(
                  onPressed: () async {
                    await appState.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                    }
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Log Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.textDarkSecondary : AppTheme.textLightSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
