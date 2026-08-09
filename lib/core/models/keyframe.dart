import 'dart:ui' show Offset;

/// 缓动类型。
enum EasingType {
  linear,
  easeIn,
  easeOut,
  easeInOut,
  cubicBezier,
}

/// 变焦关键帧。
///
/// 对应规划文档 2.2 节数据结构：`{ time, scale, easing, focalPoint }`。
/// [focalPoint] 使用相对坐标（0..1），与素材分辨率解耦。
class Keyframe {
  const Keyframe({
    required this.time,
    required this.scale,
    required this.easing,
    required this.focalPoint,
    this.bezierControl1,
    this.bezierControl2,
  });

  /// 时间位置（0..1，相对整段曲线时长）。
  final double time;

  /// 缩放比例（规划默认范围 0.5x - 3.0x，可自定义）。
  final double scale;

  /// 本关键帧到下一关键帧之间使用的缓动类型。
  final EasingType easing;

  /// 变焦点，动画的锚定中心（相对坐标 0..1）。
  final Offset focalPoint;

  /// 仅 [EasingType.cubicBezier] 时使用（相对坐标控制点）。
  final Offset? bezierControl1;
  final Offset? bezierControl2;
}
