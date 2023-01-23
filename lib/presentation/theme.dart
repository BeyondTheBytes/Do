import 'package:flutter/material.dart';

const pageHorizontalPadding = 35.0;

final appColor = AppColors._(
  darkest: Color(0xff202233),
  dark: Color(0xff161E5D),
  medium: Color(0xff4657D5),
  warning: Color(0xffFFF044),
  success: Color(0xff3CA921),
);
final _colorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: appColor.medium,
  onPrimary: Colors.white,
  secondary: appColor.medium,
  onSecondary: Colors.black,
  background: appColor.darkest,
  onBackground: Colors.white,
  surface: Colors.white,
  onSurface: appColor.darkest,
  error: Color(0xffF85454),
  onError: Colors.white,
);
final _primarySwatch = MaterialColor(
  _colorScheme.primary.value,
  _createSwatch(_colorScheme.primary),
);

final _headlineFamily = 'Ultra';
final _bodyFamily = 'Inter';
final appText = AppTexts._(
  kicker: TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 20,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w100,
    color: appColor.darkest,
  ),
  title1: TextStyle(
    fontFamily: _headlineFamily,
    fontSize: 58,
    color: appColor.darkest,
  ),
  title2: TextStyle(
    fontFamily: _headlineFamily,
    fontSize: 32,
    color: appColor.darkest,
  ),
  title3: TextStyle(
    fontFamily: _headlineFamily,
    fontSize: 24,
    color: appColor.darkest,
  ),
  subtitle1: TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: Colors.grey[800],
  ),
  body1: TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 15,
    fontWeight: FontWeight.w300,
    color: Colors.black,
  ),
  button1: TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  ),
  button2: TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  ),
);
final _labelStyle = TextStyle(
  fontFamily: _bodyFamily,
  fontSize: 15,
  fontWeight: FontWeight.w500,
  color: Colors.grey[600],
);
final _textTheme = TextTheme(
  bodyText1: appText.body1,
  subtitle1: appText.body1, // input text theme
);

final _inputTheme = InputDecorationTheme(
  floatingLabelBehavior: FloatingLabelBehavior.auto,
  filled: true,
  iconColor: Colors.grey[800],
  suffixIconColor: Colors.grey[800],
  prefixIconColor: Colors.grey[800],
  fillColor: Colors.grey[200],
  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  labelStyle: _labelStyle,
  hintStyle: _labelStyle,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
);

final _buttonShape = MaterialStateProperty.all(
  RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
);
final _filledButton = ButtonStyle(
  backgroundColor: MaterialStateProperty.all(appColor.medium),
  overlayColor: MaterialStateProperty.all(Colors.grey[800]!.withOpacity(0.1)),
  shape: _buttonShape,
  foregroundColor: MaterialStateProperty.all(Colors.white),
);
final _outlinedButton = ButtonStyle(
  backgroundColor: MaterialStateProperty.all(Colors.white),
  overlayColor: MaterialStateProperty.all(appColor.dark.withOpacity(0.1)),
  shape: _buttonShape,
  foregroundColor: MaterialStateProperty.all(appColor.medium),
);
final _appButton = AppButton._(
  largeFilled: _filledButton.copyWith(
    textStyle: MaterialStateProperty.all(appText.button1),
    padding: MaterialStateProperty.all(
      EdgeInsets.symmetric(horizontal: 25, vertical: 12),
    ),
  ),
  filled: _filledButton.copyWith(
    textStyle: MaterialStateProperty.all(appText.button2),
  ),
  largeOutlined: _outlinedButton.copyWith(
    textStyle: MaterialStateProperty.all(appText.button1),
    padding: MaterialStateProperty.all(
      EdgeInsets.symmetric(horizontal: 25, vertical: 12),
    ),
  ),
  outlined: _outlinedButton.copyWith(
    textStyle: MaterialStateProperty.all(appText.button2),
  ),
  text: ButtonStyle(
    textStyle: MaterialStateProperty.all(appText.button1),
    shape: _buttonShape,
  ),
);

final theme = ThemeData(
  extensions: [appColor, appText, _appButton],
  colorScheme: _colorScheme,
  primarySwatch: _primarySwatch,
  shadowColor: appColor.darkest,
  textTheme: _textTheme,
  inputDecorationTheme: _inputTheme,
  textButtonTheme: TextButtonThemeData(style: _appButton.text),
  outlinedButtonTheme: OutlinedButtonThemeData(style: _appButton.filled),
);

///////////////////////////////////////////////////////////////////////////
/// CLASSES
///////////////////////////////////////////////////////////////////////////

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color darkest;
  final Color dark;
  final Color medium;
  final Color warning;
  final Color success;
  const AppColors._({
    required this.darkest,
    required this.dark,
    required this.medium,
    required this.warning,
    required this.success,
  });

  static AppColors of(BuildContext context) => Theme.of(context).extension<AppColors>()!;

  /// Shouldn't be called
  @override
  AppColors copyWith() => this;

  /// Shouldn't be called
  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) => this;
}

@immutable
class AppTexts extends ThemeExtension<AppTexts> {
  final TextStyle kicker;
  final TextStyle title1;
  final TextStyle title2;
  final TextStyle title3;
  final TextStyle subtitle1;
  final TextStyle body1;
  final TextStyle button1;
  final TextStyle button2;
  const AppTexts._({
    required this.kicker,
    required this.title1,
    required this.title2,
    required this.title3,
    required this.subtitle1,
    required this.body1,
    required this.button1,
    required this.button2,
  });

  static AppTexts of(BuildContext context) => Theme.of(context).extension<AppTexts>()!;

  /// Shouldn't be called
  @override
  AppTexts copyWith() => this;

  /// Shouldn't be called
  @override
  AppTexts lerp(ThemeExtension<AppTexts>? other, double t) => this;
}

@immutable
class AppButton extends ThemeExtension<AppButton> {
  final ButtonStyle text;
  final ButtonStyle filled;
  final ButtonStyle largeFilled;
  final ButtonStyle outlined;
  final ButtonStyle largeOutlined;
  const AppButton._({
    required this.text,
    required this.filled,
    required this.largeFilled,
    required this.outlined,
    required this.largeOutlined,
  });

  static AppButton of(BuildContext context) => Theme.of(context).extension<AppButton>()!;

  /// Shouldn't be called
  @override
  AppButton copyWith() => this;

  /// Shouldn't be called
  @override
  AppButton lerp(ThemeExtension<AppButton>? other, double t) => this;
}

/////////////////////////////////////////////////////////////////////
/// UTILS
/////////////////////////////////////////////////////////////////////

Map<int, Color> _createSwatch(Color color) {
  final strengths = <double>[0.05];
  final swatch = <int, Color>{};
  final r = color.red, g = color.green, b = color.blue;
  for (var i = 1, len = 9; i < len; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return swatch;
}
