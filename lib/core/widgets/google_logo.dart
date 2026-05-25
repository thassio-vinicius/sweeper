import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sweeper/core/theme/tokens/asset_tokens.dart';
import 'package:sweeper/core/theme/tokens/size_tokens.dart';

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = AppSizes.iconLg});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.googleLogo,
      width: size,
      height: size,
      semanticsLabel: 'Google',
    );
  }
}
