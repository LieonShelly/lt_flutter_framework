import 'package:flutter/widgets.dart';

enum AppFont {
  poppinsRegular,
  poppinsBold,
  poppinsMediumItalic,
  feltTipSeniorRegular,
  sfProRegular,
  sfProMedium,
  sfProBold,
  vividlyRegular,
  ibmPlexMonoRegular,
  dsDigital,
  littleThing,
}

extension AppFontExtension on AppFont {
  String get value {
    switch (this) {
      case AppFont.poppinsRegular:
        return "Poppins-Regular";
      case AppFont.poppinsBold:
        return "Poppins-Bold";
      case AppFont.poppinsMediumItalic:
        return "Poppins-MediumItalic";
      case AppFont.vividlyRegular:
        return "VividlyRegular";
      case AppFont.ibmPlexMonoRegular:
        return "IBMPlexMono-Regular";
      case AppFont.dsDigital:
        return "DS-DIGI";
      case AppFont.littleThing:
        return "TheLittleThings02";
      case AppFont.feltTipSeniorRegular:
        return "FeltTipSeniorRegular";
      case AppFont.sfProRegular:
        return "SFPRODISPLAYREGULAR";
      case AppFont.sfProMedium:
        return "SFPRODISPLAYMEDIUM";
      case AppFont.sfProBold:
        return "SFPRODISPLAYBOLD";
    }
  }
}

class AppTextStyle extends TextStyle {
  AppTextStyle({
    required AppFont font,
    super.fontSize,
    super.fontWeight,
    super.color,
    super.height,
    super.letterSpacing,
    super.decoration,
  }) : super(fontFamily: font.value, package: 'lt_uicomponent');

  AppTextStyle.poppins({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) : this(
         font: AppFont.poppins,
         fontSize: fontSize,
         color: color,
         fontWeight: fontWeight,
         height: height,
       );

  AppTextStyle.feltTipSeniorRegular({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) : this(
         font: AppFont.feltTipSeniorRegular,
         fontSize: fontSize,
         color: color,
         fontWeight: fontWeight,
         height: height,
       );

  AppTextStyle.poppinsMediumItalic({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) : this(
         font: AppFont.poppinsMediumItalic,
         fontSize: fontSize,
         color: color,
         fontWeight: fontWeight,
         height: height,
       );

  AppTextStyle.vividlyRegular({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) : this(
         font: AppFont.vividlyRegular,
         fontSize: fontSize,
         color: color,
         fontWeight: fontWeight,
         height: height,
       );

  AppTextStyle.ltFont({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) : this(
         font: AppFont.lt,
         fontSize: fontSize,
         color: color,
         fontWeight: fontWeight,
         height: height,
       );
}
