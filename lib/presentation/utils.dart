import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../config/routes.dart';
import 'theme.dart';

extension ListExtensions<Widget> on Iterable<Widget> {
  List<Widget> withBetween(Widget separation) {
    return [
      ...take(1),
      ...skip(1).expand((e) => [separation, e]).toList(),
    ];
  }
}

class DefaultPageTopPadding extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: defaultPageTopPadding);
  }
}

class DefaultHorizontalPadding extends StatelessWidget {
  final Widget child;
  DefaultHorizontalPadding({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: defaultPageHorizontalPadding),
      child: child,
    );
  }
}

class EntryController {
  OverlayEntry? entry = null;

  void remove() {
    entry?.remove();
    entry = null;
  }

  void insert(BuildContext context, OverlayEntry newEntry) {
    entry = newEntry;
    Overlay.of(context)!.insert(newEntry);
  }
}

class DialogWrapper extends StatelessWidget {
  final Widget child;
  const DialogWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(20.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(child: child),
      ),
    );
  }
}

class CustomDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final bool large;
  const CustomDialog({
    required this.title,
    required this.child,
    this.large = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: large ? EdgeInsets.all(30) : EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: large
                ? AppTexts.of(context).title2
                : AppTexts.of(context).title3,
          ),
          large ? SizedBox(height: 15) : SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class IconErrorWidget extends StatelessWidget {
  final String title;
  final String description;
  final Widget icon;

  /// It's advised to use [HelpErrorButton]
  final Widget? button;

  const IconErrorWidget({
    required this.title,
    required this.description,
    required this.icon,
    this.button,
  });

  static const iconSize = 55.0;

  @override
  Widget build(BuildContext context) {
    final localButton = button;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Container(
        width: min(MediaQuery.of(context).size.width * 0.75, 400),
        child: Column(
          children: [
            Container(height: iconSize, width: iconSize, child: icon),
            SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTexts.of(context).title3.copyWith(color: Colors.white),
            ),
            SizedBox(height: 3),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTexts.of(context).body1.copyWith(color: Colors.white),
            ),
            if (localButton != null) ...[
              SizedBox(height: 10),
              localButton,
            ]
          ],
        ),
      ),
    );
  }
}

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
// DropDown
// /////////////////////////////////////////

class PlatformSelect<T> extends StatelessWidget {
  final T? value;
  final String hintText;
  final List<T> items;
  final Widget Function(BuildContext context, T value) itemBuilder;
  final void Function(T? v) onChanged;
  final double cupertinoItemExtent;
  final double cupertinoDialogHeight;
  const PlatformSelect({
    required this.value,
    required this.hintText,
    required this.items,
    required this.itemBuilder,
    required this.onChanged,
    this.cupertinoItemExtent = 30,
    this.cupertinoDialogHeight = 270,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      final value = this.value;
      return CustomDropdownButton(
        hintText: hintText,
        selected: (value == null) ? null : itemBuilder(context, value),
        onTap: () {
          onChanged(items.first); // so that the user doesn't have to move
          // "back and forth" if they want to select the first one

          showCupertinoSelect<void>(
            context: context,
            builder: (_) => Container(
              height: cupertinoDialogHeight,
              child: CupertinoPicker(
                itemExtent: cupertinoItemExtent,
                useMagnifier: false,
                children:
                    items.map((item) => itemBuilder(context, item)).toList(),
                onSelectedItemChanged: (index) =>
                    onChanged(index < 0 ? null : items[index]),
              ),
            ),
          );
        },
      );
    }

    return DropdownButtonFormField<T>(
      hint: Text(
        hintText,
        style: Theme.of(context).inputDecorationTheme.hintStyle,
      ),
      dropdownColor: Colors.white,
      value: value,
      icon: _DropdownIcon(),
      items: items
          .map((item) => DropdownMenuItem<T>(
                child: itemBuilder(context, item),
                value: item,
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _DropdownIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(
      FontAwesomeIcons.chevronDown,
      size: 12,
      color: Theme.of(context).inputDecorationTheme.iconColor,
    );
  }
}

class CustomDropdownButton extends StatelessWidget {
  final Widget? selected;
  final String hintText;
  final void Function()? onTap;
  const CustomDropdownButton({
    required this.hintText,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = this.selected;
    return GestureDetector(
      child: Container(
        height: 45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            (selected == null)
                ? Text(
                    hintText,
                    style: Theme.of(context).inputDecorationTheme.hintStyle,
                  )
                : DefaultTextStyle(
                    child: selected,
                    style: TextStyle(color: Colors.grey[900]),
                  ),
            _DropdownIcon(),
          ],
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: Theme.of(context).inputDecorationTheme.contentPadding,
      ),
      onTap: onTap,
    );
  }
}

Future<T?> showCupertinoSelect<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
}) =>
    showCupertinoModalPopup<T>(
      context: context,
      builder: (context) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: Brightness.light,
        ),
        child: CupertinoActionSheet(
          actions: [builder(context)],
          cancelButton: CupertinoButton(
            child: Text('Confirmar'),
            onPressed: () => AppRouter.of(context).popDialog(),
          ),
        ),
      ),
    );

// /////////////////////////////////////////
// MESSAGE
// /////////////////////////////////////////

class ErrorMessage extends _DisplayMessage {
  ErrorMessage._(BuildContext context) : super(context);

  final _waitAutomaticallyClose = Duration(milliseconds: 10000);

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

  final _waitAutomaticallyClose = Duration(milliseconds: 4000);

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

  Duration get _waitAutomaticallyClose;

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
