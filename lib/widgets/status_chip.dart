import 'package:flutter/material.dart';
import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final bool isPaymentStatus;

  const StatusChip({
    super.key,
    required this.status,
    this.isPaymentStatus = false,
  });

  Color _getBgColor() {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return AppTheme.accentGreen.withOpacity(0.15);
      case 'pending':
      case 'in_progress':
        return AppTheme.accentOrange.withOpacity(0.15);
      case 'cancelled':
        return AppTheme.accentRed.withOpacity(0.15);
      case 'partial':
        return Colors.blue.withOpacity(0.15);
      default:
        return Colors.grey.withOpacity(0.15);
    }
  }

  Color _getTextColor() {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return const Color(0xFF047857);
      case 'pending':
      case 'in_progress':
        return const Color(0xFFD97706);
      case 'cancelled':
        return const Color(0xFFDC2626);
      case 'partial':
        return const Color(0xFF1D4ED8);
      default:
        return Colors.grey[700]!;
    }
  }

  String _getLocalizedLabel(BuildContext context) {
    final loc = AppLocalizations.of(context);
    switch (status.toLowerCase()) {
      case 'completed':
        return loc.translate('completed');
      case 'paid':
        return loc.translate('paid');
      case 'pending':
        return loc.translate('pending');
      case 'in_progress':
        return loc.translate('in_progress');
      case 'cancelled':
        return loc.translate('cancelled');
      case 'partial':
        return loc.translate('partial');
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBgColor();
    final textColor = _getTextColor();
    final label = _getLocalizedLabel(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaymentStatus ? Icons.account_balance_wallet_outlined : Icons.task_alt,
            size: 12,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
