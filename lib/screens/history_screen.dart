import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'whatsapp_message_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'all';

  void _setFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
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
              // Header Row (Matches Dashboard look)
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary.withOpacity(0.1), width: 2),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        "https://lh3.googleusercontent.com/aida-public/AB6AXuCnqFfvN07oQC3E-bK1LT15tRE2zOMzbxzbBItWRUGi8YthoFjgwId1gTGt9gXn-Ve75OT1VACh24RKpn4IPClTCANUljG3FghncZxmTMmmGWaND4x0HCsbltnQToPPqxdcGt3YfBtrc7VewReIcQ2UBNaXXQiqRsYMMK23KsKEx_UyDjQfFrzluMhJ3vzuMD0GzQHuL7z9kH8cOhM-aAVsuD2Wtk-VrEXUHsbX1nIzsPLc-2Gwvro",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: AppTheme.primary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title Section
              Text(
                'ઇતિહાસ',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'તમારા વ્યવસાયના વ્યવહારો અહીં તપાસો અને મેનેજ કરો',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: AppTheme.onSurfaceVariant),
                    hintText: 'નામ અથવા વ્યવહાર શોધો...',
                    hintStyle: TextStyle(color: AppTheme.onSurfaceVariant.withOpacity(0.5)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Ledger and Sidebar layouts
              Column(
                children: [
                  // Total Balance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.skyGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Icon(
                            Icons.account_balance_wallet,
                            size: 140,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'કુલ બાકી (Pending)',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: const [
                                Text(
                                  '₹',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '84,200',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const WhatsAppMessageScreen(
                                        customerName: 'મનોજભાઈ',
                                        quantity: 'બધા બાકી બિલ',
                                        amount: '₹ 84,200',
                                        messageText: 'નમસ્તે મનોજભાઈ,\nતમારું કુલ બાકી ખાતું ₹ 84,200 છે.\nકૃપા કરીને વહેલી તકે ચુકવણી કરશો. આભાર!',
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppTheme.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'ખાતું મોકલો',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick Filters
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ઝડપી ફિલ્ટર્સ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurface,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildFilterButton('all', 'બધા'),
                            const SizedBox(width: 8),
                            _buildFilterButton('completed', 'પૂર્ણ'),
                            const SizedBox(width: 8),
                            _buildFilterButton('pending', 'બાકી'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Calendar View
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'કેલેન્ડર',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            Icon(Icons.calendar_today, color: AppTheme.primary, size: 18),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Calendar Days Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            Text('S', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
                            Text('M', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
                            Text('T', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
                            Text('W', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
                            Text('T', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
                            Text('F', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
                            Text('S', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Days Numbers
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildCalendarDay('12'),
                            _buildCalendarDay('13'),
                            _buildCalendarDay('14', isSelected: true),
                            _buildCalendarDay('15'),
                            _buildCalendarDay('16'),
                            _buildCalendarDay('17'),
                            _buildCalendarDay('18'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Ledger Ledger Categories
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Today Category
                      if (_selectedFilter == 'all' || _selectedFilter == 'pending') ...[
                        _buildCategoryHeader('Today / આજે', AppTheme.primary),
                        const SizedBox(height: 12),
                        _buildLedgerItem(
                          letter: 'M',
                          name: 'Manojbhai',
                          subtitle: 'Payment for stock',
                          status: 'Pending / બાકી',
                          amount: '₹ 4,500.00',
                          isPending: true,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Yesterday Category
                      if (_selectedFilter == 'all' || _selectedFilter == 'completed') ...[
                        _buildCategoryHeader('Yesterday / ગઈકાલે', AppTheme.onSurfaceVariant.withOpacity(0.6)),
                        const SizedBox(height: 12),
                        _buildLedgerItem(
                          letter: 'R',
                          name: 'Rakesh',
                          subtitle: 'General Groceries',
                          status: 'Completed / પૂર્ણ',
                          amount: '₹ 1,280.00',
                          isPending: false,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Last Week Category
                      if (_selectedFilter == 'all') ...[
                        _buildCategoryHeader('Last Week / ગયા અઠવાડિયે', AppTheme.onSurfaceVariant.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        _buildLedgerItem(
                          letter: '🚚',
                          name: 'Delivery',
                          subtitle: 'Consignment #4920',
                          status: 'Delivered',
                          amount: '₹ 12,000.00',
                          isPending: false,
                          isCustomIcon: true,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String filterCode, String label) {
    final isSelected = _selectedFilter == filterCode;
    return GestureDetector(
      onTap: () => _setFilter(filterCode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? null : AppTheme.surfaceContainerHigh,
          gradient: isSelected ? AppTheme.skyGradient : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarDay(String dayNum, {bool isSelected = false}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          dayNum,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title, Color ringColor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ringColor,
            boxShadow: [
              BoxShadow(
                color: ringColor.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 2,
              )
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildLedgerItem({
    required String letter,
    required String name,
    required String subtitle,
    required String status,
    required String amount,
    required bool isPending,
    bool isCustomIcon = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isPending
                  ? AppTheme.primary.withOpacity(0.05)
                  : AppTheme.secondaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isCustomIcon
                  ? const Icon(Icons.local_shipping, color: AppTheme.onSurfaceVariant, size: 24)
                  : Text(
                      letter,
                      style: TextStyle(
                        color: isPending ? AppTheme.primary : AppTheme.secondary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
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

          // Price and status tag
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isPending
                      ? AppTheme.errorContainer.withOpacity(0.5)
                      : AppTheme.secondaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isPending ? AppTheme.error : AppTheme.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
