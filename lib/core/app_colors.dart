import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // no instances

  // ---------------------------------------------------------------- brand
  // Your app gradient: 0xFF2a86c9 -> 0xFF406dbe
  static const Color primary = Color(0xFF2A86C9); // gradient start, links
  static const Color primaryDark = Color(0xFF406DBE); // gradient end
  static const Color pageBackground = Color(0xFFE3F2FD); // Colors.blue.shade50

  // ----------------------------------------------------- surfaces & lines
  static const Color card = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderStrong = Color(0xFFCBD5E1);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color skeletonBase = Color(0xFFE0E0E0);
  static const Color skeletonHighlight = Color(0xFFF5F5F5);
  static const Color sheetBackground = Color(0xFFF8FAFC);
  static const Color softGrey = Color(0xFFF1F5F9); // segmented tab background

  // ----------------------------------------------------------------- text
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMedium = Color(0xFF475569);
  static const Color textGrey = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color textOnColor = Colors.white;

  // ------------------------------------------------- status cards (home)
  static const Color todo = Color(0xFF7E57C2);
  static const Color pending = Color(0xFFF57C00);
  static const Color unassigned = Color(0xFF2E9E6B);
  static const Color overdue = Color(0xFFE53935);
  static const Color statusDefault = Color(0xFF607D8B);

  // ------------------------------------------------ semantic / feedback
  static const Color success = Color(0xFF16A34A);
  static const Color successTint = Color(0xFFF0FDF4);
  static const Color successBorder = Color(0xFFBBF7D0);
  static const Color warning = Color(0xFFEA580C);
  static const Color warningTint = Color(0xFFFFF7ED);
  static const Color danger = Color(0xFFE53935);
  static const Color dangerTint = Color(0xFFFEF2F2);
  static const Color live = Color(0xFF22C55E); // "running now" dot

  // -------------------------------------------------- attendance sheet
  static const Color present = Color(0xFF43A047);
  static const Color leave = Color(0xFFF57C00);
  static const Color halfDay = Color(0xFF1E88E5);

  // -------------------------------------------------- running task card
  static const Color accent = Color(0xFF4F46E5); // indigo
  static const Color accentTint = Color(0xFFEEF2FF);

  // -------------------------------------------------- task "running" state
  static const Color running = Color(0xFF0891B2); // cyan
  static const Color runningTint = Color(0xFFECFEFF);
  // ------------------------------------------------------ add / assign
  static const Color addButton = primary; // outlined Add button

  // ------------------------------------------------------------ gradients
  /// App bar (use the same begin/end you already use there)
  static const LinearGradient appBarGradient = LinearGradient(
    colors: [primary, primaryDark],
  );

  /// Sheet headers, Assign button, any "primary" surface
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = primaryGradient;

  // -------------------------------------------------------------- shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0D000000), // black 5%
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // -------------------------------------------------------------- helpers
  /// Colour for a status card label ("To do", "Pending", ...).
  static Color statusColor(String label) {
    switch (label.toLowerCase()) {
      case 'to do':
        return todo;
      case 'pending':
        return pending;
      case 'unassigned':
        return unassigned;
      case 'overdue':
        return overdue;
      default:
        return statusDefault;
    }
  }

  /// Soft background tint of any colour (used behind icons / chips).
  static Color tint(Color c, [double opacity = 0.12]) => c.withOpacity(opacity);
}
