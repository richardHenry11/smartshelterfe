import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

enum NotificationType { success, error, warning, info }

class AppNotification {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  /// Menampilkan notifikasi banner modern melayang di bagian atas layar (Dynamic Island style)
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    NotificationType type = NotificationType.success,
    Duration duration = const Duration(milliseconds: 2800),
  }) {
    // Hapus notifikasi sebelumnya jika masih ada yang aktif
    _dismissTimer?.cancel();
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _ModernNotificationBanner(
        message: message,
        title: title,
        type: type,
        onDismiss: () {
          _dismissTimer?.cancel();
          if (_currentEntry == entry) {
            entry.remove();
            _currentEntry = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    _dismissTimer = Timer(duration, () {
      if (_currentEntry == entry) {
        entry.remove();
        _currentEntry = null;
      }
    });
  }

  static void success(BuildContext context, String message, {String? title}) =>
      show(context, message: message, title: title ?? 'Berhasil', type: NotificationType.success);

  static void error(BuildContext context, String message, {String? title}) =>
      show(context, message: message, title: title ?? 'Pemberitahuan', type: NotificationType.error);

  static void warning(BuildContext context, String message, {String? title}) =>
      show(context, message: message, title: title ?? 'Peringatan', type: NotificationType.warning);

  static void info(BuildContext context, String message, {String? title}) =>
      show(context, message: message, title: title ?? 'Informasi', type: NotificationType.info);

  /// Menampilkan Pop-Up Dialog Modal Modern di tengah layar dengan animasi membal (bounce)
  static Future<void> showModal(
    BuildContext context, {
    required String title,
    required String message,
    NotificationType type = NotificationType.success,
    String buttonText = 'Tutup',
    VoidCallback? onConfirm,
  }) async {
    Color accentColor;
    List<Color> gradientColors;
    IconData icon;

    switch (type) {
      case NotificationType.success:
        accentColor = const Color(0xFF00E676);
        gradientColors = [const Color(0xFF00E676), const Color(0xFF00B0FF)];
        icon = Icons.check_rounded;
        break;
      case NotificationType.error:
        accentColor = const Color(0xFFFF5252);
        gradientColors = [const Color(0xFFFF5252), const Color(0xFFFF1744)];
        icon = Icons.close_rounded;
        break;
      case NotificationType.warning:
        accentColor = const Color(0xFFFFB300);
        gradientColors = [const Color(0xFFFFB300), const Color(0xFFFF9100)];
        icon = Icons.warning_amber_rounded;
        break;
      case NotificationType.info:
        accentColor = const Color(0xFF00E5FF);
        gradientColors = [const Color(0xFF00E5FF), const Color(0xFF2979FF)];
        icon = Icons.info_outline_rounded;
        break;
    }

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'AppNotificationModal',
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (dialogCtx, anim1, anim2, child) {
        final curvedScale = Curves.easeOutBack.transform(anim1.value);
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 8 * anim1.value,
            sigmaY: 8 * anim1.value,
          ),
          child: Transform.scale(
            scale: curvedScale.clamp(0.0, 1.2),
            child: Opacity(
              opacity: anim1.value.clamp(0.0, 1.0),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1E36),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.25),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Glowing Animated Icon Badge
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: gradientColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.45),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(icon, color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 18),

                          // Title
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Message
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Confirm Button
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(dialogCtx);
                                onConfirm?.call();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 4,
                              ),
                              child: Text(
                                buttonText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ModernNotificationBanner extends StatefulWidget {
  final String message;
  final String? title;
  final NotificationType type;
  final VoidCallback onDismiss;

  const _ModernNotificationBanner({
    required this.message,
    this.title,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_ModernNotificationBanner> createState() => _ModernNotificationBannerState();
}

class _ModernNotificationBannerState extends State<_ModernNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _slideAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    _animController.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor;
    List<Color> gradientColors;
    IconData icon;
    String defaultTitle;

    switch (widget.type) {
      case NotificationType.success:
        accentColor = const Color(0xFF00E676);
        gradientColors = [const Color(0xFF00E676), const Color(0xFF00B0FF)];
        icon = Icons.check_circle_rounded;
        defaultTitle = 'Berhasil';
        break;
      case NotificationType.error:
        accentColor = const Color(0xFFFF5252);
        gradientColors = [const Color(0xFFFF5252), const Color(0xFFFF1744)];
        icon = Icons.error_outline_rounded;
        defaultTitle = 'Pemberitahuan';
        break;
      case NotificationType.warning:
        accentColor = const Color(0xFFFFB300);
        gradientColors = [const Color(0xFFFFB300), const Color(0xFFFF9100)];
        icon = Icons.warning_amber_rounded;
        defaultTitle = 'Peringatan';
        break;
      case NotificationType.info:
        accentColor = const Color(0xFF00E5FF);
        gradientColors = [const Color(0xFF00E5FF), const Color(0xFF2979FF)];
        icon = Icons.info_outline_rounded;
        defaultTitle = 'Informasi';
        break;
    }

    final displayTitle = widget.title ?? defaultTitle;
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 10,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final translateY = -50.0 * (1.0 - _slideAnimation.value);
          return Transform.translate(
            offset: Offset(0, translateY),
            child: Opacity(
              opacity: _fadeAnimation.value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
              _handleDismiss();
            }
          },
          onTap: _handleDismiss,
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B192C).withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.45),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.25),
                        blurRadius: 18,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Icon with Gradient Halo
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),

                      // Text description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              displayTitle,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.message,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Colors.white,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Swipe hint / Close icon
                      Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
