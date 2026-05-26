import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sweeper_theme/tokens/asset_tokens.dart';
import 'package:sweeper_theme/tokens/size_tokens.dart';

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({
    super.key,
    this.size = AppSizes.iconLg,
    required this.semanticsLabel,
  });

  final double size;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.googleLogo,
      package: AppAssets.packageName,
      width: size,
      height: size,
      semanticsLabel: semanticsLabel,
    );
  }
}
