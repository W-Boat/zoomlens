import 'dart:math' show pow;
import 'dart:ui' show Offset;

import '../models/keyframe.dart' show EasingType;

/// 缓动函数求值。
///
/// [t] 为归一化时间（0..1），返回值同样归一化（0..1）。
/// [EasingType.cubicBezier] 时使用 [control1]/[control2] 作为三次贝塞尔
/// 控制点（相对坐标，各分量均在 0..1）。
double evaluateEasing(
  EasingType type,
  double t, {
  Offset control1 = const Offset(0.25, 0.1),
  Offset control2 = const Offset(0.25, 1.0),
}) {
  final u = t.clamp(0.0, 1.0);
  switch (type) {
    case EasingType.linear:
      return u;
    case EasingType.easeIn:
      return u * u * u;
    case EasingType.easeOut:
      return 1.0 - pow(1.0 - u, 3).toDouble();
    case EasingType.easeInOut:
      return u < 0.5
          ? 4.0 * u * u * u
          : 1.0 - pow(-2.0 * u + 2.0, 3).toDouble() / 2.0;
    case EasingType.cubicBezier:
      return cubicBezierY(u, control1, control2);
  }
}

/// 三次贝塞尔求值：解 x(s)=t 得到参数 s，再取 y(s)。
///
/// CSS 风格贝塞尔要求 x 分量在 [0,1] 单调递增，本实现用牛顿迭代反解参数。
double cubicBezierY(double t, Offset control1, Offset control2) {
  const p0 = 0.0;
  const p3 = 1.0;
  if (t <= 0) return 0;
  if (t >= 1) return 1;
  var s = t;
  for (var i = 0; i < 8; i++) {
    final x = _cubic(s, p0, control1.dx, control2.dx, p3);
    final diff = x - t;
    if (diff.abs() < 1e-6) break;
    final dx = _cubicDerivative(s, p0, control1.dx, control2.dx, p3);
    if (dx.abs() < 1e-8) break;
    s -= diff / dx;
  }
  return _cubic(s, p0, control1.dy, control2.dy, p3);
}

/// 三次贝塞尔 x(s) 分量：p0/p1/p2/p3 为各轴控制点。
double _cubic(double s, double p0, double p1, double p2, double p3) {
  final om = 1.0 - s;
  return om * om * om * p0 +
      3.0 * om * om * s * p1 +
      3.0 * om * s * s * p2 +
      s * s * s * p3;
}

/// 三次贝塞尔 x(s) 的一阶导（供牛顿迭代使用）。
double _cubicDerivative(double s, double p0, double p1, double p2, double p3) {
  final om = 1.0 - s;
  return 3.0 * om * om * (p1 - p0) +
      6.0 * om * s * (p2 - p1) +
      3.0 * s * s * (p3 - p2);
}
