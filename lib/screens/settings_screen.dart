import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'language_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _onLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('લોગઆઉટ / Logout'),
        content: const Text('શું તમે ખરેખર બહાર નીકળવા માંગો છો?\nAre you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              // Navigate back to welcome screen (re-auth simulate)
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const ChooseLanguageScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.menu, color: AppTheme.primary, size: 28),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'VyaparMitra',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.skyGradient,
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title Section
              Text(
                'સેટિંગ્સ',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'તમારી પ્રોફાઇલ અને એપ્લિકેશન સેટિંગ્સ અહીં મેનેજ કરો',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Profile Card Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryContainer.withOpacity(0.3), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          "https://lh3.googleusercontent.com/aida-public/AB6AXuDcI9dqoarCFeyBRJbGt818zkr8v66MAOCjP94OzW7CNvNj4SU4njCpeQKzLpV_altJQLSb3A_8Z-LuWagEGgUgOQe1fF0ihDeIkwI7RZerKiP7Yc_cNv0YQXNHQirekZ87Fw15ExLmdLYu6X4gMYevZ9bvI966Cfc90sRqt-5eukCjA_szWF9WwaKe7VJI34GdnfsR4S-J7kzTI4lpXJ286k8KrO1q47CB1PKdee8jd9QLtMzKyYE",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'રાજેશભાઈ પટેલ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'શ્રીજી પ્રોવિઝન સ્ટોર',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              // Edit Profile mock click
                            },
                            child: Row(
                              children: const [
                                Text(
                                  'પ્રોફાઇલ સંપાદિત કરો',
                                  style: TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.edit, size: 14, color: AppTheme.primary),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Settings Options list
              Column(
                children: [
                  _buildSettingsItem(
                    icon: Icons.language,
                    title: 'ભાષા બદલો',
                    subtitle: 'વર્તમાન: ગુજરાતી',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    icon: Icons.notifications,
                    title: 'નોટિફિકેશન પસંદગીઓ',
                    subtitle: 'પેમેન્ટ અને એલર્ટ્સ',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    icon: Icons.help,
                    title: 'મદદ અને સપોર્ટ',
                    subtitle: 'અમને સંપર્ક કરો અથવા FAQ જુઓ',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    icon: Icons.info,
                    title: 'વ્યાપારમિત્ર વિશે',
                    subtitle: 'વર્ઝન 1.0.4 - જાણો વધુ',
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),

                  // Logout Item
                  GestureDetector(
                    onTap: _onLogout,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.errorContainer.withOpacity(0.8)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.errorContainer.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.logout, color: AppTheme.error),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'લોગઆઉટ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.error,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'ખાતામાંથી બહાર નીકળો',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Legal Links
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'નિયમો અને શરતો',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'ગોપનીયતા નીતિ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  '© 2024 VyaparMitra. All Rights Reserved.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
