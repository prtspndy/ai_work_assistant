import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_card.dart';
import 'edit_task_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'voice_record_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
      Provider.of<SettingsProvider>(context, listen: false).testConnection();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final pages = [
      HomeDashboardTab(onViewAll: () => switchTab(1)),
      const HistoryScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard_rounded),
            label: loc.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history_outlined),
            activeIcon: const Icon(Icons.history_rounded),
            label: loc.translate('history'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings_rounded),
            label: loc.translate('settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VoiceRecordScreen()),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        elevation: 4,
        icon: const Icon(Icons.mic_rounded, color: Colors.white),
        label: Text(
          loc.translate('voice_record'),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

class HomeDashboardTab extends StatelessWidget {
  final VoidCallback onViewAll;

  const HomeDashboardTab({super.key, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: CustomScrollView(
        slivers: [
          // Header Banner with AI Status Indicator
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 60, bottom: 30),
              decoration: const BoxDecoration(
                gradient: AppTheme.headerGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.translate('app_name'),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'Vyapar Vani',
                                style: TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // AI Status Chip (AI Ready / AI Offline)
                          GestureDetector(
                            onTap: () => settingsProvider.testConnection(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: settingsProvider.isConnected
                                    ? AppTheme.accentGreen.withOpacity(0.25)
                                    : Colors.red.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: settingsProvider.isConnected ? AppTheme.accentGreen : Colors.redAccent,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: settingsProvider.isConnected ? AppTheme.accentGreen : Colors.redAccent,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    settingsProvider.isConnected ? 'AI Ready' : 'AI Offline',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                            onPressed: () {
                              taskProvider.loadTasks();
                              settingsProvider.testConnection();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Dashboard Stat Cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.today, color: Colors.white70, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    loc.translate('todays_pending'),
                                    style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${taskProvider.todayPendingCount}',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    loc.translate('total_pending_amount'),
                                    style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              FittedBox(
                                child: Text(
                                  currencyFormat.format(taskProvider.totalPendingAmount),
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Recent Tasks Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.translate('recent_tasks'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  TextButton(
                    onPressed: onViewAll,
                    child: Text(loc.translate('view_all')),
                  ),
                ],
              ),
            ),
          ),

          // Recent Task List Items
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: taskProvider.isLoading
                ? const SliverToBoxAdapter(
                    child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
                  )
                : taskProvider.recentTasks.isEmpty
                    ? SliverToBoxAdapter(
                        child: EmptyState(
                          message: loc.translate('no_recent_tasks'),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final task = taskProvider.recentTasks[index];
                            return TaskCard(
                              task: task,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditTaskScreen(task: task, isEditingExisting: true),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: taskProvider.recentTasks.length,
                        ),
                      ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}
