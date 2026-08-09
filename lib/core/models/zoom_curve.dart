import 'dart:ui' show Offset, lerpDouble;

import '../math/easing.dart' show evaluateEasing;
import 'keyframe.dart' show Keyframe;

/// 变焦曲线在某一时刻的采样结果。
class ZoomSample {
  const ZoomSample({required this.scale, required this.focalPoint});

  /// 缩放比例。
  final double scale;

  /// 变焦点（相对坐标 0..1）。
  final Offset focalPoint;
}

/// 多关键帧变焦曲线。
///
/// 关键帧按 [Keyframe.time] 升序排列；相邻关键帧之间：
/// - 缩放值：按左端关键帧的缓动插值；
/// - 变焦点：按同一缓动插值（焦点移动与缩放节奏同步，视觉更自然），
///   从而实现规划文档 2.2 节「从变焦点 A 平滑移动到变焦点 B，同时执行缩放」。
class ZoomCurve {
  ZoomCurve(Iterable<Keyframe> keyframes)
      : _keyframes = List<Keyframe>.of(keyframes)
          ..sort((a, b) => a.time.compareTo(b.time)) {
    if (_keyframes.length < 2) {
      throw ArgumentError('ZoomCurve 至少需要 2 个关键帧');
    }
    for (var i = 1; i < _keyframes.length; i++) {
      if (_keyframes[i].time == _keyframes[i - 1].time) {
        throw ArgumentError('关键帧时间不能重复: ${_keyframes[i].time}');
      }
    }
  }

  final List<Keyframe> _keyframes;

  /// 按时间升序的关键帧（只读视图）。
  List<Keyframe> get keyframes => List.unmodifiable(_keyframes);

  /// 曲线总时长（最后一个关键帧的时间）。
  double get duration => _keyframes.last.time;

  /// 在时间 [t]（0..1）处求值曲线；超出范围时钳制到最近的关键帧。
  ZoomSample evaluateAt(double t) {
    final u = t.clamp(0.0, duration);
    if (u <= _keyframes.first.time) {
      final k = _keyframes.first;
      return ZoomSample(scale: k.scale, focalPoint: k.focalPoint);
    }
    if (u >= _keyframes.last.time) {
      final k = _keyframes.last;
      return ZoomSample(scale: k.scale, focalPoint: k.focalPoint);
    }
    for (var i = 0; i < _keyframes.length - 1; i++) {
      final a = _keyframes[i];
      final b = _keyframes[i + 1];
      if (u >= a.time && u <= b.time) {
        final span = b.time - a.time;
        final local = span <= 0 ? 0.0 : (u - a.time) / span;
        final eased = evaluateEasing(
          a.easing,
          local,
          control1: a.bezierControl1 ?? const Offset(0.25, 0.1),
          control2: a.bezierControl2 ?? const Offset(0.25, 1.0),
        );
        final scale = lerpDouble(a.scale, b.scale, eased) ?? a.scale;
        final focal = Offset.lerp(a.focalPoint, b.focalPoint, eased) ?? a.focalPoint;
        return ZoomSample(scale: scale, focalPoint: focal);
      }
    }
    // 理论不可达：u 必然落在某区间内。
    final k = _keyframes.last;
    return ZoomSample(scale: k.scale, focalPoint: k.focalPoint);
  }
}
