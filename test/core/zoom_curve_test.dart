import 'package:flutter_test/flutter_test.dart';
import 'package:zoomlens/core/models/keyframe.dart';
import 'package:zoomlens/core/models/zoom_curve.dart';

void main() {
  group('ZoomCurve', () {
    final curve = ZoomCurve([
      const Keyframe(
        time: 0.0,
        scale: 1.0,
        easing: EasingType.linear,
        focalPoint: Offset(0.5, 0.5),
      ),
      const Keyframe(
        time: 1.0,
        scale: 2.0,
        easing: EasingType.linear,
        focalPoint: Offset(0.5, 0.5),
      ),
    ]);

    test('少于 2 个关键帧抛 ArgumentError', () {
      expect(
        () => ZoomCurve([
          const Keyframe(
            time: 0,
            scale: 1,
            easing: EasingType.linear,
            focalPoint: Offset.zero,
          ),
        ]),
        throwsArgumentError,
      );
    });

    test('关键帧时间重复抛 ArgumentError', () {
      expect(
        () => ZoomCurve([
          const Keyframe(
            time: 0,
            scale: 1,
            easing: EasingType.linear,
            focalPoint: Offset.zero,
          ),
          const Keyframe(
            time: 0,
            scale: 2,
            easing: EasingType.linear,
            focalPoint: Offset.zero,
          ),
        ]),
        throwsArgumentError,
      );
    });

    test('关键帧自动按时间升序排序', () {
      final c = ZoomCurve([
        const Keyframe(
          time: 1.0,
          scale: 1,
          easing: EasingType.linear,
          focalPoint: Offset.zero,
        ),
        const Keyframe(
          time: 0.0,
          scale: 2,
          easing: EasingType.linear,
          focalPoint: Offset.zero,
        ),
      ]);
      expect(c.keyframes.first.time, 0.0);
      expect(c.keyframes.last.time, 1.0);
    });

    test('端点处返回对应关键帧值', () {
      final s0 = curve.evaluateAt(0.0);
      expect(s0.scale, 1.0);
      expect(s0.focalPoint, const Offset(0.5, 0.5));
      final s1 = curve.evaluateAt(1.0);
      expect(s1.scale, 2.0);
      expect(s1.focalPoint, const Offset(0.5, 0.5));
    });

    test('线性插值中点为 1.5', () {
      final mid = curve.evaluateAt(0.5);
      expect(mid.scale, closeTo(1.5, 1e-9));
    });

    test('越界时间被钳制到最近端点', () {
      expect(curve.evaluateAt(-1).scale, 1.0);
      expect(curve.evaluateAt(2).scale, 2.0);
    });

    test('变焦点随插值平滑移动（A → B）', () {
      final c = ZoomCurve([
        const Keyframe(
          time: 0.0,
          scale: 1.0,
          easing: EasingType.linear,
          focalPoint: Offset(0.2, 0.2),
        ),
        const Keyframe(
          time: 1.0,
          scale: 1.0,
          easing: EasingType.linear,
          focalPoint: Offset(0.8, 0.8),
        ),
      ]);
      final mid = c.evaluateAt(0.5);
      expect(mid.focalPoint.dx, closeTo(0.5, 1e-9));
      expect(mid.focalPoint.dy, closeTo(0.5, 1e-9));
    });

    test('缩放与变焦点使用同一缓动（easeIn 时缩放中点偏小）', () {
      final c = ZoomCurve([
        const Keyframe(
          time: 0.0,
          scale: 1.0,
          easing: EasingType.easeIn,
          focalPoint: Offset(0.0, 0.0),
        ),
        const Keyframe(
          time: 1.0,
          scale: 2.0,
          easing: EasingType.easeIn,
          focalPoint: Offset(1.0, 1.0),
        ),
      ]);
      final mid = c.evaluateAt(0.5);
      // easeIn: 0.5^3 = 0.125 → scale = 1 + 0.125 = 1.125
      expect(mid.scale, closeTo(1.125, 1e-9));
      expect(mid.focalPoint.dx, closeTo(0.125, 1e-9));
    });

    test('多段曲线（3+ 关键帧）各段独立生效', () {
      final c = ZoomCurve([
        const Keyframe(
          time: 0.0,
          scale: 1.0,
          easing: EasingType.linear,
          focalPoint: Offset(0.5, 0.5),
        ),
        const Keyframe(
          time: 0.5,
          scale: 1.5,
          easing: EasingType.linear,
          focalPoint: Offset(0.5, 0.5),
        ),
        const Keyframe(
          time: 1.0,
          scale: 1.0,
          easing: EasingType.linear,
          focalPoint: Offset(0.5, 0.5),
        ),
      ]);
      expect(c.duration, 1.0);
      // 第一段中点：1 + 0.5*(1.5-1) = 1.25
      expect(c.evaluateAt(0.25).scale, closeTo(1.25, 1e-9));
      // 第二段中点：1.5 + 0.5*(1.0-1.5) = 1.25
      expect(c.evaluateAt(0.75).scale, closeTo(1.25, 1e-9));
      expect(c.evaluateAt(0.5).scale, closeTo(1.5, 1e-9));
    });
  });
}
