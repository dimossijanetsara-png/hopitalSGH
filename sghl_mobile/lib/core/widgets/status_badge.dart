import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final Map<String, Color>? colorMap;

  const StatusBadge({
    super.key,
    required this.status,
    this.colorMap,
  });

  /// Factory constructor for appointment statuses.
  factory StatusBadge.appointment(String status) {
    return StatusBadge(
      status: status,
      colorMap: const {
        'planifie': Color(0xFF1565C0),
        'confirme': Color(0xFF2E7D32),
        'en_cours': Color(0xFFF57C00),
        'termine': Color(0xFF424242),
        'annule': Color(0xFFC62828),
        'absent': Color(0xFF6A1B9A),
      },
    );
  }

  /// Factory constructor for lab/analysis statuses.
  factory StatusBadge.lab(String status) {
    return StatusBadge(
      status: status,
      colorMap: const {
        'en_attente': Color(0xFFF57C00),
        'en_cours': Color(0xFF1565C0),
        'valide': Color(0xFF2E7D32),
        'annule': Color(0xFFC62828),
        'rejete': Color(0xFF6A1B9A),
      },
    );
  }

  Color _resolveColor() {
    if (colorMap != null) {
      final key = status.toLowerCase();
      return colorMap![key] ?? Colors.grey[600]!;
    }
    return Colors.grey[600]!;
  }

  String _formatLabel() {
    if (status.isEmpty) return status;
    final label = status.replaceAll('_', ' ');
    return label[0].toUpperCase() + label.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _formatLabel(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
