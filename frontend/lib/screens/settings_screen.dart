import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> _languages = ['English', 'Hindi (हिन्दी)', 'Marathi (मराठी)', 'Gujarati (ગુજરાતી)'];
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _showDocumentDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Contact Support & Feedback', style: TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'For queries, please email: support@wrslips.gov.in\nHelpline: +91 22 2201 5555\n\nOr submit direct feedback:',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter your query or issue details here...',
                hintStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = _feedbackController.text.trim();
              if (text.isEmpty) return;
              _feedbackController.clear();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feedback submitted successfully! We will get back to you shortly.'),
                  backgroundColor: AppTheme.accentTeal,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              // Language Card (Soft UI)
              _buildSoftSectionHeader('Regional Preferences', isDark),
              const SizedBox(height: 8),
              _buildSoftCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.language_rounded, color: AppTheme.primaryBlue),
                          const SizedBox(width: 16),
                          Text(
                            'App Language',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppTheme.textLightPrimary,
                            ),
                          ),
                        ],
                      ),
                      DropdownButton<String>(
                        value: appState.language,
                        underline: const SizedBox(),
                        dropdownColor: isDark ? AppTheme.cardDark : Colors.white,
                        onChanged: (val) {
                          if (val != null) {
                            appState.setLanguage(val);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Language updated to $val'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        items: _languages.map((lang) {
                          return DropdownMenuItem(
                            value: lang,
                            child: Text(lang, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // Legal & Support Section
              _buildSoftSectionHeader('Legal & Support', isDark),
              const SizedBox(height: 8),
              _buildSoftCard(
                child: Column(
                  children: [
                    _buildSettingsListTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () => _showDocumentDialog('Privacy Policy', _privacyPolicyContent),
                      isDark: isDark,
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSettingsListTile(
                      icon: Icons.description_outlined,
                      title: 'Terms & Conditions',
                      onTap: () => _showDocumentDialog('Terms & Conditions', _termsAndConditionsContent),
                      isDark: isDark,
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSettingsListTile(
                      icon: Icons.support_agent_outlined,
                      title: 'Support & Help Desk',
                      onTap: _showSupportDialog,
                      isDark: isDark,
                    ),
                  ],
                ),
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // About Section
              _buildSoftSectionHeader('Application Info', isDark),
              const SizedBox(height: 8),
              _buildSoftCard(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'WR & Slips Mobile App',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version 1.0.0 ',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppTheme.textDarkSecondary : AppTheme.textLightSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '© 2026 Western Railway Administration.\nAll rights reserved.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoftSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: isDark ? AppTheme.textDarkSecondary : AppTheme.textLightSecondary,
        ),
      ),
    );
  }

  Widget _buildSoftCard({required Widget child, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
        ),
      ),
      child: child,
    );
  }

  Widget _buildSettingsListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppTheme.textLightPrimary,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  // Sample static texts
  static const String _privacyPolicyContent = '''
Privacy Policy for WR & Slips
Last Updated: July 2026

1. Information We Collect
The WR & Slips mobile application operates primarily locally on employee devices. We store user configuration settings (such as name, role, email, and selected railway zone) directly on the device using shared preferences to provide offline-ready accessibility.

2. Document Storage and Access
Rule books, circulars, and correction slips are downloaded to the local document cache. This app does not access external contacts, location services, or personal files.

3. Security
We take security seriously. Since these files represent official railway rules, access controls limit admin uploads. Users should secure their device to prevent unauthorized deletion.

4. Contact
For privacy queries, please write to security@wrslips.gov.in.
''';

  static const String _termsAndConditionsContent = '''
Terms and Conditions of Use
Last Updated: July 2026

1. Acceptable Use
This application is designed specifically for employees, officers, and stakeholders of Western Railway and associated Indian Railway zones. Users must use the reference data in accordance with active railway mandates.

2. Document Validity
While the administration ensures rule books and correction slips are correct at the time of upload, users should check official Gazette notices for legal operational matters.

3. Administration Controls
Administrators reserve the right to add, remove, rename, or revise the files within this catalog to comply with structural updates.

4. Limitation of Liability
The administration is not liable for errors arising from using outdated offline cached copies.
''';
}
