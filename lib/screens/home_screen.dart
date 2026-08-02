import 'package:flutter/material.dart';
import 'history_screen.dart';
import 'edit_task_screen.dart';
import 'settings_screen.dart';
import 'voice_record_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Custom Theme Colors
  static const Color primaryBlue = Color(0xFF35AEEF);
  static const Color darkBlue = Color(0xFF0073B7);
  static const Color softCyan = Color(0xFF8DD8F8);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFDCEAF2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient Background (#F8FCFF -> #DDF3FF)
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FCFF),
              Color(0xFFDDF3FF),
            ],
          ),
        ),
        child: _selectedIndex == 2
            ? const HistoryScreen()
            : _selectedIndex == 3
                ? const SettingsScreen()
                : SafeArea(
                child: Column(
                  children: [
                    // Custom Header App Bar
                    _buildAppBar(),

                    // Scrollable Main Content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            _buildGreetingHeader(),
                            const SizedBox(height: 20),
                            _buildPriorityTaskCard(),
                            const SizedBox(height: 16),
                            _buildSummaryStatsRow(),
                            const SizedBox(height: 20),
                            _buildVoiceRecordCard(),
                            const SizedBox(height: 24),
                            _buildRecentTransactionsHeader(),
                            const SizedBox(height: 12),
                            _buildTransactionList(),
                            const SizedBox(height: 80), // Padding for Floating Action Button
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF0286CD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // --- UI COMPONENTS ---

  // 1. App Bar
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: textPrimary, size: 28),
            onPressed: () {},
          ),
          const Text(
            'VyaparMitra',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFE2E8F0),
            child: Icon(Icons.person, color: textSecondary),
          ),
        ],
      ),
    );
  }

  // 2. Greeting Header
  Widget _buildGreetingHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          '👋 નમસ્તે, રાજેશભાઈ',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'તમારા વ્યવસાયનો આજનો સારાંશ અહીં છે.',
          style: TextStyle(
            fontSize: 14,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  // 3. Priority Task Card
  Widget _buildPriorityTaskCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF3FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PRIORITY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0073B7),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'આજના બાકી કામો',
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '08',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Icon(Icons.north_east, color: Colors.redAccent, size: 16),
              SizedBox(width: 4),
              Text(
                'ગઈકાલ કરતા ૨ વધુ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Summary Stats Grid
  Widget _buildSummaryStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F5FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Color(0xFF0288D1),
                    size: 22,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'કુલ ઉધરાણી',
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
                const SizedBox(height: 4),
                const Text(
                  '₹ 45,200',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    color: Color(0xFF475569),
                    size: 22,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'રોકડ સિલક',
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
                const SizedBox(height: 4),
                const Text(
                  '₹ 12,840',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 5. Voice Record Card
  Widget _buildVoiceRecordCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VoiceRecordScreen()),
        );
      },
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF29B6F6),
            Color(0xFF0277BD),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0277BD).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
            ),
            child: const Icon(
              Icons.mic_none_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'અવાજ રેકોર્ડ કરો',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'બોલીને વ્યવહાર નોંધો, તે આપોઆપ લખાઈ જશે',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      ),
    );
  }

  // 6. Recent Transactions Section Header
  Widget _buildRecentTransactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'તાજેતરના વ્યવહારો',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        InkWell(
          onTap: () {},
          child: Row(
            children: const [
              Text(
                'બધા જુઓ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0073B7),
                ),
              ),
              SizedBox(width: 2),
              Icon(Icons.chevron_right, size: 18, color: Color(0xFF0073B7)),
            ],
          ),
        ),
      ],
    );
  }

  // 7. Transaction List
  Widget _buildTransactionList() {
    return Column(
      children: [
        _buildTransactionTile(
          avatarText: 'M',
          avatarBgColor: const Color(0xFFE0F2FE),
          title: 'મનોજભાઈ – પેન્ડિંગ',
          subtitle: 'આજે, 10:30 AM • કિરાણા સામાન',
          amount: '- ₹ 1,200',
          amountColor: const Color(0xFFDC2626),
          tagText: 'બાકી',
          tagBgColor: const Color(0xFFFEE2E2),
          tagTextColor: const Color(0xFFDC2626),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditTaskScreen(
                  customerName: 'મનોજભાઈ',
                  quantity: 1,
                  amount: 1200,
                  onSave: (name, qty, amt) {
                    debugPrint('Saved: $name, $qty, $amt');
                  },
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildTransactionTile(
          avatarText: 'S',
          avatarBgColor: const Color(0xFFE0F2FE),
          title: 'સુરેશભાઈ – પેમેન્ટ',
          subtitle: 'ગઈકાલે, 05:15 PM • રોકડ જમા',
          amount: '+ ₹ 5,000',
          amountColor: const Color(0xFF0284C7),
          tagText: 'ચૂકવેલ',
          tagBgColor: const Color(0xFFE0F2FE),
          tagTextColor: const Color(0xFF0284C7),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditTaskScreen(
                  customerName: 'સુરેશભાઈ',
                  quantity: 1,
                  amount: 5000,
                  onSave: (name, qty, amt) {
                    debugPrint('Saved: $name, $qty, $amt');
                  },
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildTransactionTile(
          avatarText: 'A',
          avatarBgColor: const Color(0xFFF1F5F9),
          title: 'અશોકભાઈ – ઓર્ડર',
          subtitle: 'ગઈકાલે, 02:20 PM • નવી ખરીદી',
          amount: '₹ 3,450',
          amountColor: textPrimary,
          tagText: 'પ્રોસેસમાં',
          tagBgColor: const Color(0xFFF1F5F9),
          tagTextColor: textSecondary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditTaskScreen(
                  customerName: 'અશોકભાઈ',
                  quantity: 1,
                  amount: 3450,
                  onSave: (name, qty, amt) {
                    debugPrint('Saved: $name, $qty, $amt');
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTransactionTile({
    required String avatarText,
    required Color avatarBgColor,
    required String title,
    required String subtitle,
    required String amount,
    required Color amountColor,
    required String tagText,
    required Color tagBgColor,
    required Color tagTextColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: avatarBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              avatarText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0369A1),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: tagBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tagText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: tagTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  // 8. Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: surfaceWhite,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_outlined, Icons.home, 'મુખ્ય'),
          _buildNavItem(1, Icons.mic_none, Icons.mic, 'અવાજ'),
          _buildNavItem(2, Icons.history, Icons.history, 'ઇતિહાસ'),
          _buildNavItem(3, Icons.settings_outlined, Icons.settings, 'સેટિંગ્સ'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VoiceRecordScreen()),
          );
        } else {
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFDDF3FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFF0073B7) : textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF0073B7) : textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}