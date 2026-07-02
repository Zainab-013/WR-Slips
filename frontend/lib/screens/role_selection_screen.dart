import 'package:flutter/material';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import 'zone_selection_screen.dart';
import 'admin_home_screen.dart';
import 'user_home_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = Provider.of<AppState>(context);

    return Scaffold(
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.account_circle_outlined,
                  size: 80,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Your Role',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppTheme.textLightPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Configure your profile based on your access level',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppTheme.textDarkSecondary : AppTheme.textLightSecondary,
                  ),
                ),
                const SizedBox(height: 48),
                // User Card
                _buildRoleCard(
                  context: context,
                  title: 'Railway User',
                  description: 'Access railway rules, view latest correction slips, and download GR & SR reference files.',
                  icon: Icons.menu_book_rounded,
                  color: AppTheme.accentTeal,
                  onTap: () async {
                    // Update user role if changed (simulation)
                    if (appState.currentUser != null) {
                      final updated = appState.currentUser!.copyWith(role: 'user');
                      // Update state (we can register or login directly, or just proceed)
                      if (appState.selectedZone != null) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const UserHomeScreen()),
                        );
                      } else {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const ZoneSelectionScreen()),
                        );
                      }
                    }
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 20),
                // Admin Card
                _buildRoleCard(
                  context: context,
                  title: 'Administrator',
                  description: 'Upload new PDF books and slips, organize categories, and manage regulatory circular data.',
                  icon: Icons.admin_panel_settings_rounded,
                  color: AppTheme.secondaryAmber,
                  onTap: () {
                    if (appState.currentUser != null) {
                      // Navigate to Admin Home
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
                      );
                    }
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 40),
                TextButton(
                  onPressed: () async {
                    await appState.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/');
                    }
                  },
                  child: const Text('Sign Out & Return'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.textLightPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppTheme.textDarkSecondary : AppTheme.textLightSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
