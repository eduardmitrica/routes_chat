import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Sweeps a soft light across the [SkeletonBlock]s in [child], which stand in
/// for content that is still loading. It keeps still for someone who turned
/// animations off.
class Shimmer extends StatefulWidget {
  final Widget child;

  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  var _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context);
    if (_still) {
      _sweep.stop();
    } else if (!_sweep.isAnimating) {
      _sweep.repeat();
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_still) return widget.child;
    final colors = AppColors.of(context);
    return AnimatedBuilder(
      animation: _sweep,
      child: widget.child,
      builder: (context, child) => ShaderMask(
        // Paints the light only where the blocks are.
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin: const Alignment(-1, -0.3),
          end: const Alignment(1, 0.3),
          colors: [colors.skeleton, colors.skeletonShine, colors.skeleton],
          stops: const [0.35, 0.5, 0.65],
          // From fully off one side to fully off the other.
          transform: _Slide(_sweep.value * 2 - 1),
        ).createShader(bounds),
        child: child,
      ),
    );
  }
}

class _Slide extends GradientTransform {
  /// How far to move the gradient, as a fraction of the width.
  final double fraction;

  const _Slide(this.fraction);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * fraction, 0, 0);
}

/// The shape of something still loading, in a [Shimmer].
class SkeletonBlock extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBlock({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.of(context).skeleton,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
