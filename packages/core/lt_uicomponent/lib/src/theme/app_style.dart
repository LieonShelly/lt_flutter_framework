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

final class AppTextStyle extends TextStyle {
  AppTextStyle({
    required AppFont font,
    super.fontSize,
    super.fontWeight,
    super.color,
    super.height,
    super.letterSpacing,
    super.decoration,
  }) : super(fontFamily: font.value, package: 'lt_uicomponent');

  AppTextStyle.poppinsRegular({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) : this(
         font: AppFont.poppinsRegular,
         fontSize: fontSize,
         color: color,
         fontWeight: fontWeight,
         height: height,
       );

  AppTextStyle.poppinsBold({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) : this(
         font: AppFont.poppinsBold,
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

  AppTextStyle.sfProRegular({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) : this(
         font: AppFont.sfProRegular,
         fontSize: fontSize,
         color: color,
         fontWeight: fontWeight,
         height: height,
       );

  AppTextStyle.sfProMedium({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) : this(
         font: AppFont.sfProMedium,
         fontSize: fontSize,
         color: color,
         fontWeight: fontWeight,
         height: height,
       );

  AppTextStyle.sfProBold({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) : this(
         font: AppFont.sfProBold,
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

  AppTextStyle.ibmPlexMonoRegular({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) : this(
         font: AppFont.ibmPlexMonoRegular,
         fontSize: fontSize,
         color: color,
         fontWeight: fontWeight,
         height: height,
       );

  AppTextStyle.dsDigital({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) : this(
         font: AppFont.dsDigital,
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
         font: AppFont.littleThing,
         fontSize: fontSize,
         color: color,
         fontWeight: fontWeight,
         height: height,
       );

  /// Heading – TheLittleThings 24px
  AppTextStyle.heading({Color? color, FontWeight? fontWeight, double? height})
    : this(
        font: AppFont.littleThing,
        fontSize: 24,
        color: color,
        fontWeight: fontWeight,
        height: height,
      );

  /// Title – TheLittleThings 18px
  AppTextStyle.title({Color? color, FontWeight? fontWeight, double? height})
    : this(
        font: AppFont.littleThing,
        fontSize: 18,
        color: color,
        fontWeight: fontWeight,
        height: height,
      );

  /// Section – TheLittleThings 14px
  AppTextStyle.section({Color? color, FontWeight? fontWeight, double? height})
    : this(
        font: AppFont.littleThing,
        fontSize: 14,
        color: color,
        fontWeight: fontWeight,
        height: height,
      );

  /// Sub-section – TheLittleThings 10px
  AppTextStyle.subSection({
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) : this(
         font: AppFont.littleThing,
         fontSize: 10,
         color: color,
         fontWeight: fontWeight,
         height: height,
       );

  /// Subtitle – Poppins 16px
  AppTextStyle.subtitle({Color? color, FontWeight? fontWeight, double? height})
    : this(
        font: AppFont.poppinsRegular,
        fontSize: 16,
        color: color,
        fontWeight: fontWeight,
        height: height,
      );

  /// Body – Poppins 14px
  AppTextStyle.body({Color? color, FontWeight? fontWeight, double? height})
    : this(
        font: AppFont.poppinsRegular,
        fontSize: 14,
        color: color,
        fontWeight: fontWeight,
        height: height,
      );

  /// Caption – Poppins 12px
  AppTextStyle.caption({Color? color, FontWeight? fontWeight, double? height})
    : this(
        font: AppFont.poppinsRegular,
        fontSize: 12,
        color: color,
        fontWeight: fontWeight,
        height: height,
      );

  /// Annotation – IBM Plex Mono 12px
  AppTextStyle.annotation({
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) : this(
         font: AppFont.ibmPlexMonoRegular,
         fontSize: 12,
         color: color,
         fontWeight: fontWeight,
         height: height,
       );
}
