import 'package:flutter/material.dart';
import '../models/order.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isSmall;

  const StatusBadge({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  Color _getStatusColor() {
    switch (status) {
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.completed:
      case OrderStatus.ready:
        return Colors.blue;
      case OrderStatus.stitching:
      case OrderStatus.cutting:
        return Colors.orange;
      case OrderStatus.trial:
      case OrderStatus.alterations:
        return Colors.purple;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(),
          width: 1,
        ),
      ),
      child: Text(
        OrderStatus.getDisplayName(status),
        style: TextStyle(
          color: _getStatusColor(),
          fontSize: isSmall ? 11 : 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
