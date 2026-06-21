import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';

class ToastHelper {
  static void showSuccess(BuildContext context, String message) {
    DelightToastBar(
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      snackbarDuration: const Duration(seconds: 3),
      builder: (context) => ToastCard(
        color: Colors.white,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        leading: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFD1FAE5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF10B981),
            size: 22,
          ),
        ),
        title: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF1E293B),
          ),
        ),
      ),
    ).show(context);
  }

  static void showError(BuildContext context, String message) {
    DelightToastBar(
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      snackbarDuration: const Duration(seconds: 3),
      builder: (context) => ToastCard(
        color: Colors.white,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        leading: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFFEE2E2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFEF4444),
            size: 22,
          ),
        ),
        title: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF1E293B),
          ),
        ),
      ),
    ).show(context);
  }

  static void showInfo(BuildContext context, String message) {
    DelightToastBar(
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      snackbarDuration: const Duration(seconds: 3),
      builder: (context) => ToastCard(
        color: Colors.white,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        leading: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFFEF3C7),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFF59E0B),
            size: 22,
          ),
        ),
        title: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF1E293B),
          ),
        ),
      ),
    ).show(context);
  }
}
