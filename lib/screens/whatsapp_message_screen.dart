import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class WhatsAppMessageScreen extends StatefulWidget {
  final String customerName;
  final String quantity;
  final String amount;
  final String messageText;

  const WhatsAppMessageScreen({
    super.key,
    required this.customerName,
    required this.quantity,
    required this.amount,
    required this.messageText,
  });

  @override
  State<WhatsAppMessageScreen> createState() => _WhatsAppMessageScreenState();
}

class _WhatsAppMessageScreenState extends State<WhatsAppMessageScreen> {
  late String _currentMessageText;

  @override
  void initState() {
    super.initState();
    _currentMessageText = widget.messageText;
  }

  void _copyText() {
    Clipboard.setData(ClipboardData(text: _currentMessageText)).then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: AppTheme.secondaryContainer),
              SizedBox(width: 8),
              Text(
                'Copied to clipboard / લખાણ કોપી થઈ ગયું છે',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: AppTheme.onSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(20),
        ),
      );
    });
  }

  void _regenerateText() {
    setState(() {
      _currentMessageText = 'નમસ્તે ${_nameGreeting()},\n'
          'તમારો ઓર્ડર (${widget.quantity}) કાલે રવાના થશે.\n'
          'કુલ બાકી રકમ: ${widget.amount}.\n'
          'કૃપા કરીને વહેલી તકે ચુકવણી કરશો. આભાર!';
    });
  }

  String _nameGreeting() {
    if (widget.customerName.endsWith('ભાઈ')) {
      return widget.customerName;
    }
    return '${widget.customerName}ભાઈ';
  }

  void _sendToWhatsApp() {
    // Show sending feedback dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.share, color: AppTheme.primary),
            SizedBox(width: 10),
            Text('સંદેશ મોકલી રહ્યા છીએ'),
          ],
        ),
        content: Text(
          'Opening WhatsApp to send message to ${widget.customerName}...\n\nMessage:\n$_currentMessageText',
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.8),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'VyaparMitra',
            style: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ClipOval(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.network(
                    "https://lh3.googleusercontent.com/aida-public/AB6AXuBZxaUvAZSOLA2X_SHG7AR-bxUqJ7pRF0A1BTFriUzw1sJliSMmhGG0iE0zuLtAozG4yRdtj-IJi6kvZMyD8A2lZFHSdlAjI9mURxr4skLQX8kmbkZ8aIS7WLXDOLyGRX4fOk0Kl9MlwZv6GBwM1WuKtLVoZSc4fGs-9JASWxdaxNJM5lqpvAm9_3QYEdc9yTn1gV2rM7kVrTX9MFePjFhyvilHk6CpWHRGiRoVHtkoVK6MKn1AOtY",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: AppTheme.primary),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header text
              const Center(
                child: Text(
                  'બનેલો સંદેશ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'GENERATED MESSAGE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: AppTheme.onSurfaceVariant.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Chat Bubble Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'VyaparMitra AI',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Just now',
                          style: TextStyle(
                            color: AppTheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      _currentMessageText,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppTheme.onSurface,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Context Action Icons Bar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBubbleAction(
                      icon: Icons.content_copy,
                      label: 'Copy',
                      onTap: _copyText,
                    ),
                    _buildBubbleAction(
                      icon: Icons.share,
                      label: 'Share',
                      onTap: () {
                        // Share logic mock
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sharing message...')),
                        );
                      },
                    ),
                    _buildBubbleAction(
                      icon: Icons.refresh,
                      label: 'Regenerate',
                      onTap: _regenerateText,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Side details cards (stacked for mobile)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                    )
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recipient Details',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary.withOpacity(0.8),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'M',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.customerName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                '+91 98765 43210',
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
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Items:',
                          style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14),
                        ),
                        Text(
                          widget.quantity,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSurface, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Balance:',
                          style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14),
                        ),
                        Text(
                          widget.amount,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.error, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Suggestion box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.skyGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryContainer.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Smart Suggestion',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Use a friendly tone to maintain good relations with Manojbhai. He usually pays within 3 days.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 110), // clear space for bottom button
            ],
          ),
        ),
        bottomSheet: Container(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40, top: 16),
          color: Colors.transparent,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.skyGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _sendToWhatsApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.send, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Send to WhatsApp',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBubbleAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
