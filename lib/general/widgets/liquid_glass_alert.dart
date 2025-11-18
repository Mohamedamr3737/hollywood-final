import 'package:flutter/material.dart';

enum AlertType {
  success,
  error,
  warning,
  info,
}

class LiquidGlassAlert {
  static void show(
      BuildContext context, {
        required String message,
        AlertType type = AlertType.info,
        Duration duration = const Duration(seconds: 4),
        VoidCallback? onTap,
      }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _SimpleAlertWidget(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () => overlayEntry.remove(),
        onTap: onTap,
      ),
    );

    overlay.insert(overlayEntry);

    // Auto dismiss after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  // Convenience methods for different alert types
  static void success(BuildContext context, String message, {Duration? duration, VoidCallback? onTap}) {
    show(context, message: message, type: AlertType.success, duration: duration ?? const Duration(seconds: 3), onTap: onTap);
  }

  static void error(BuildContext context, String message, {Duration? duration, VoidCallback? onTap}) {
    show(context, message: message, type: AlertType.error, duration: duration ?? const Duration(seconds: 4), onTap: onTap);
  }

  static void warning(BuildContext context, String message, {Duration? duration, VoidCallback? onTap}) {
    show(context, message: message, type: AlertType.warning, duration: duration ?? const Duration(seconds: 3), onTap: onTap);
  }

  static void info(BuildContext context, String message, {Duration? duration, VoidCallback? onTap}) {
    show(context, message: message, type: AlertType.info, duration: duration ?? const Duration(seconds: 3), onTap: onTap);
  }
}

class _SimpleAlertWidget extends StatefulWidget {
  final String message;
  final AlertType type;
  final Duration duration;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;

  const _SimpleAlertWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
    this.onTap,
  });

  @override
  State<_SimpleAlertWidget> createState() => _SimpleAlertWidgetState();
}

class _SimpleAlertWidgetState extends State<_SimpleAlertWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  Color _getHeaderColor() {
    switch (widget.type) {
      case AlertType.success:
        return const Color(0xFF4CAF50); // Green
      case AlertType.error:
        return const Color(0xFFFF5A5A); // Red (matching the design)
      case AlertType.warning:
        return const Color(0xFFFF9800); // Orange
      case AlertType.info:
        return const Color(0xFF2196F3); // Blue
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case AlertType.success:
        return Icons.check;
      case AlertType.error:
        return Icons.close;
      case AlertType.warning:
        return Icons.warning;
      case AlertType.info:
        return Icons.info;
    }
  }

  String _getTitle() {
    switch (widget.type) {
      case AlertType.success:
        return 'Success!';
      case AlertType.error:
        return 'Error!';
      case AlertType.warning:
        return 'Warning!';
      case AlertType.info:
        return 'Info!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  constraints: const BoxConstraints(
                    maxWidth: 320,
                    minWidth: 280,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: _getHeaderColor(),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                _getIcon(),
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content section
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              _getTitle(),
                              style: const TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _dismiss,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF000000),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.close, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Close',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}