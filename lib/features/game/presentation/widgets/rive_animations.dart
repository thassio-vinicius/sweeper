import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:sweeper/features/game/presentation/widgets/explosion_overlay.dart';

/// Attempts to play a Rive explosion animation; falls back to [ExplosionEffect].
class RiveExplosionWrapper extends StatefulWidget {
  const RiveExplosionWrapper({
    super.key,
    required this.left,
    required this.top,
    required this.size,
  });

  final double left;
  final double top;
  final double size;

  static const assetPath = 'assets/animations/explosion.riv';

  @override
  State<RiveExplosionWrapper> createState() => _RiveExplosionWrapperState();
}

class _RiveExplosionWrapperState extends State<RiveExplosionWrapper> {
  final bool _useFallback = true;

  @override
  Widget build(BuildContext context) {
    if (_useFallback) {
      return ExplosionEffect(
        left: widget.left,
        top: widget.top,
        size: widget.size,
      );
    }

    return Positioned(
      left: widget.left,
      top: widget.top,
      width: widget.size,
      height: widget.size,
      child: RiveAnimation.asset(
        RiveExplosionWrapper.assetPath,
        onInit: (artboard) {
          final controller = StateMachineController.fromArtboard(
            artboard,
            'State Machine 1',
          );
          if (controller != null) {
            artboard.addController(controller);
            controller.isActive = true;
          }
        },
        placeHolder: ExplosionEffect(
          left: 0,
          top: 0,
          size: widget.size,
        ),
      ),
    );
  }
}

/// Drop a `.riv` file at [RiveExplosionWrapper.assetPath] to enable Rive explosions.
Future<bool> riveExplosionAssetExists() async {
  try {
    await RiveFile.asset(RiveExplosionWrapper.assetPath);
    return true;
  } catch (_) {
    return false;
  }
}
