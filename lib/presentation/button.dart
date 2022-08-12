import 'dart:async';

import 'package:flutter/material.dart';

import 'theme.dart';
import 'utils.dart';

/// Most common use case is implemented by [CustomButton]
class CustomButton extends StatefulWidget {
  final Widget child;
  final FutureOr Function()? onPressed;
  final ButtonStyle? style;
  final bool loadingText;
  final bool whiteLoading;
  final bool filled;
  final bool stretch;
  CustomButton({
    required this.child,
    required this.onPressed,
    this.style,
    this.loadingText = true,
    this.filled = true,
    this.whiteLoading = true,
    this.stretch = true,
  });

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  var _processingTap = false;

  @override
  Widget build(BuildContext context) {
    return _buildButton(
      onPressed: _buildOnPressed(),
      style: widget.style,
      child: Row(
        mainAxisSize: widget.stretch ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_processingTap || widget.loadingText) widget.child,
          if (_processingTap)
            Container(
              width: 10,
              height: 10,
              margin: EdgeInsets.all(5) +
                  EdgeInsets.only(left: widget.loadingText ? 10 : 0),
              child: CustomLoading(
                color: widget.whiteLoading
                    ? Colors.white
                    : AppColors.of(context).medium,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required Function()? onPressed,
    required Widget child,
    required ButtonStyle? style,
  }) =>
      widget.filled
          ? OutlinedButton(onPressed: onPressed, child: child, style: style)
          : TextButton(onPressed: onPressed, child: child, style: style);

  Function()? _buildOnPressed() {
    final onPressed = widget.onPressed;
    if (_processingTap || onPressed == null) return null;

    return () async {
      setState(() {
        _processingTap = true;
      });

      await onPressed();

      // to prevent calling setState after dipose
      if (mounted) {
        setState(() {
          _processingTap = false;
        });
      }
    };
  }
}
