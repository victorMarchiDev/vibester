import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static const _fontFamily = 'Geist';

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    fontFamily: _fontFamily,
    textTheme: ThemeData.dark().textTheme.apply(fontFamily: _fontFamily),
    scaffoldBackgroundColor: AppColors.dark.noturno,
    extensions: const [AppColors.dark],
  );

  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    fontFamily: _fontFamily,
    textTheme: ThemeData.light().textTheme.apply(fontFamily: _fontFamily),
    scaffoldBackgroundColor: AppColors.light.noturno,
    extensions: const [AppColors.light],
  );
}
