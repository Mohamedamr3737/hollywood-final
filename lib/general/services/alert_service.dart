import 'package:flutter/material.dart';
import '../widgets/liquid_glass_alert.dart';

class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  // Success alerts
  static void success(BuildContext context, String message, {Duration? duration, VoidCallback? onTap}) {
    LiquidGlassAlert.success(context, message, duration: duration, onTap: onTap);
  }

  // Error alerts
  static void error(BuildContext context, String message, {Duration? duration, VoidCallback? onTap}) {
    LiquidGlassAlert.error(context, message, duration: duration, onTap: onTap);
  }

  // Warning alerts
  static void warning(BuildContext context, String message, {Duration? duration, VoidCallback? onTap}) {
    LiquidGlassAlert.warning(context, message, duration: duration, onTap: onTap);
  }

  // Info alerts
  static void info(BuildContext context, String message, {Duration? duration, VoidCallback? onTap}) {
    LiquidGlassAlert.info(context, message, duration: duration, onTap: onTap);
  }

  // Generic show method
  static void show(
    BuildContext context, {
    required String message,
    AlertType type = AlertType.info,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    LiquidGlassAlert.show(
      context,
      message: message,
      type: type,
      duration: duration ?? const Duration(seconds: 3),
      onTap: onTap,
    );
  }

  // Convenience methods for common scenarios
  static void loginSuccess(BuildContext context) {
    success(context, "Login Successful");
  }

  static void loginError(BuildContext context, [String? customMessage]) {
    error(context, customMessage ?? "Wrong username or password");
  }

  static void networkError(BuildContext context, [String? customMessage]) {
    error(context, customMessage ?? "Network error. Please check your connection.");
  }

  static void serverError(BuildContext context, [String? customMessage]) {
    error(context, customMessage ?? "Server error. Please try again later.");
  }

  static void validationError(BuildContext context, String message) {
    warning(context, message);
  }

  static void operationSuccess(BuildContext context, String operation) {
    success(context, "$operation successfully!");
  }

  static void operationError(BuildContext context, String operation, [String? customMessage]) {
    error(context, customMessage ?? "Failed to $operation. Please try again.");
  }

  static void appointmentSuccess(BuildContext context) {
    success(context, "Appointment saved successfully");
  }

  static void appointmentError(BuildContext context, [String? customMessage]) {
    error(context, customMessage ?? "Failed to save appointment. Please try again.");
  }

  static void ticketSuccess(BuildContext context) {
    success(context, "Ticket created successfully");
  }

  static void ticketError(BuildContext context, [String? customMessage]) {
    error(context, customMessage ?? "Failed to create ticket. Please try again.");
  }

  static void passwordUpdated(BuildContext context) {
    success(context, "Password updated successfully!");
  }

  static void passwordError(BuildContext context, [String? customMessage]) {
    error(context, customMessage ?? "Failed to update password. Please try again.");
  }

  static void notificationsCleared(BuildContext context) {
    success(context, "Notifications cleared");
  }

  static void notificationsError(BuildContext context, [String? customMessage]) {
    error(context, customMessage ?? "Failed to clear notifications. Please try again.");
  }

  static void fillFields(BuildContext context) {
    warning(context, "Please fill in all fields");
  }

  static void selectDateTime(BuildContext context) {
    warning(context, "Please select date and time!");
  }

  static void codeRequired(BuildContext context) {
    warning(context, "Please enter the code");
  }

  static void passwordsMatch(BuildContext context) {
    warning(context, "Passwords do not match");
  }

  static void passwordFieldsRequired(BuildContext context) {
    warning(context, "Please fill out both password fields");
  }
}
