import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';

import 'theme.dart';

class DismissibleKeyboardWrapper extends StatelessWidget {
  final Widget child;
  const DismissibleKeyboardWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!FocusScope.of(context).hasPrimaryFocus) {
          FocusScope.of(context).unfocus();
        }
      },
      child: child,
    );
  }
}

/// All the child area will be tappable.
/// However, no feedback will be provided.
class EntirelyTappable extends StatelessWidget {
  final Widget child;
  final void Function()? onTap;
  final EdgeInsets? padding;
  const EntirelyTappable({
    required this.child,
    required this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent, // because of gesture detector padding
        child: _wrapPadding(context, child),
      ),
    );
  }

  Widget _wrapPadding(BuildContext context, Widget child) {
    final localPadding = padding;
    if (localPadding == null) return child;
    return Padding(
      padding: localPadding,
      child: child,
    );
  }
}

class CustomLoading extends StatelessWidget {
  final double? value;
  final Color? color;
  final bool forceDefaultSize;

  const CustomLoading({this.value, this.color}) : forceDefaultSize = false;

  /// This should be used when this widget takes the size of the parent
  /// (i.e.: in a list view)
  const CustomLoading.forceDefaultSize({this.value, this.color})
      : forceDefaultSize = true;

  static double defaultSize(BuildContext context) => min(
        115,
        min(
          MediaQuery.of(context).size.width * 0.2,
          MediaQuery.of(context).size.height * 0.2,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final localValue = value;
    return Center(
      child: _buildSizeConstraints(
        context,
        child: CircularProgressIndicator(
          value: localValue == null || localValue <= 0 ? null : localValue,
          strokeWidth: 4,
          valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.grey[800]!),
        ),
      ),
    );
  }

  Widget _buildSizeConstraints(BuildContext context, {required Widget child}) {
    final size = defaultSize(context);
    if (forceDefaultSize) {
      return Container(
        width: size,
        height: size,
        child: child,
      );
    }
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        constraints: BoxConstraints(
          // Default size, this doesn't actually prohibit it to be smaller
          minWidth: size,
          minHeight: size,
        ),
        child: child,
      ),
    );
  }
}

// /////////////////////////////////////////
// MESSAGE
// /////////////////////////////////////////

class ErrorMessage extends _DisplayMessage {
  ErrorMessage._(BuildContext context) : super(context);

  static ErrorMessage of(BuildContext context) {
    return ErrorMessage._(context);
  }

  @protected
  Widget buildMessage(String message, {required Function() onPressedClose}) {
    return _DisplayMessageWidget(
      icon: Icon(Icons.error_outlined, color: Colors.black),
      description: message,
      onPressedClose: onPressedClose,
      backgroundColor: AppColors.of(context).warning,
      foregroundColor: Colors.black,
    );
  }
}

class SuccessMessage extends _DisplayMessage {
  SuccessMessage._(BuildContext context) : super(context);

  static SuccessMessage of(BuildContext context) {
    return SuccessMessage._(context);
  }

  @protected
  Widget buildMessage(String message, {required Function() onPressedClose}) {
    return _DisplayMessageWidget(
      icon: Icon(Icons.check_circle_rounded, color: Colors.white),
      description: message,
      onPressedClose: onPressedClose,
      backgroundColor: AppColors.of(context).medium,
      foregroundColor: Colors.white,
    );
  }
}

abstract class _DisplayMessage {
  final BuildContext context;
  @protected
  _DisplayMessage(this.context);

  static const _waitAutomaticallyClose = Duration(milliseconds: 10000);

  @protected
  Widget buildMessage(String message, {required Function() onPressedClose});

  void show(String message) {
    final key = _getNextKey();
    final overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        top: 0,
        left: 0,
        child: Material(
          child: buildMessage(
            message,
            onPressedClose: () => _removeOverlayIfMounted(key),
          ),
        ),
      );
    });

    _addToOverlayList(key, overlayEntry);

    Overlay.of(context)?.insert(overlayEntry);

    Future<void>.delayed(
      _waitAutomaticallyClose,
      () => _removeOverlayIfMounted(key),
    );
  }

  // UNDERLYING DATA STRUCTURES

  final SplayTreeMap<int, OverlayEntry> overlays =
      SplayTreeMap.from(<int, OverlayEntry>{});

  void _addToOverlayList(int key, OverlayEntry overlay) {
    overlays[key] = overlay;
  }

  void _removeOverlayIfMounted(int key) {
    final overlay = overlays.remove(key);
    if (overlay != null && overlay.mounted) overlay.remove();
  }

  int _getNextKey() {
    final lastKey = overlays.lastKey();
    if (lastKey == null) return 0;
    return lastKey + 1;
  }
}

class _DisplayMessageWidget extends StatelessWidget {
  final Function() onPressedClose;

  final Widget icon;
  final String description;

  final Color backgroundColor;
  final Color foregroundColor;

  const _DisplayMessageWidget({
    required this.icon,
    required this.description,
    required this.onPressedClose,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  static const animationDuration = Duration(milliseconds: 30);

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 17.0;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: animationDuration,
      builder: (context, double perc, child) {
        if (perc == 0) return SizedBox(height: 0, width: 0);
        return Opacity(opacity: perc, child: child);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: backgroundColor,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Container(
          padding: const EdgeInsets.only(
            left: horizontalPadding,
            top: 10,
            bottom: 10,
          ),
          child: Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon,
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    description,
                    style: TextStyle(color: foregroundColor),
                  ),
                ),
                SizedBox(width: 15),
                EntirelyTappable(
                  onTap: onPressedClose,
                  child: Container(
                    padding:
                        EdgeInsets.all(20).copyWith(right: horizontalPadding),
                    child: Icon(Icons.close, size: 15, color: foregroundColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
