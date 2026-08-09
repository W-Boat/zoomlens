import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zoomlens/core/models/keyframe.dart';
import 'package:zoomlens/core/models/zoom_curve.dart';
import 'package:zoomlens/features/editor/zoom_curve_painter.dart';

void main() {
  group('ZoomCurvePainter 坐标换算', () {
    const size = Size(400, 200);

    test('scale 上下界映射到曲线区两端', () {
      expect(
        ZoomCurvePainter.yForScale(size, 3.0, scaleMin: 0.5, scaleMax: 3.0),
        closeTo(ZoomCurvePainter.curveTop(size), 1e-9),
      );
      expect(
        ZoomCurvePainter.yForScale(size, 0.5, scaleMin: 0.5, scaleMax: 3.0),
        closeTo(ZoomCurvePainter.trackTop(size), 1e-9),
      );
      // y → scale 反向一致
      final y = ZoomCurvePainter.yForScale(
        size,
        2.0,
        scaleMin: 0.5,
        scaleMax: 3.0,
      );
      expect(
        ZoomCurvePainter.scaleForY(size, y, scaleMin: 0.5, scaleMax: 3.0),
        closeTo(2.0, 1e-9),
      );
    });

    test('越界 y 被钳制到曲线区', () {
      expect(
        ZoomCurvePainter.scaleForY(
          size,
          -100,
          scaleMin: 0.5,
          scaleMax: 3.0,
        ),
        closeTo(3.0, 1e-9),
      );
    });
  });

  group('ZoomCurvePainter.hitTestKeyframe', () {
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
    final painter =
        ZoomCurvePainter(curve: curve, scaleMin: 0.5, scaleMax: 3.0);

    const size = Size(400, 200);

    test('命中第一个关键帧（t=0, s=1.0）', () {
      final y = ZoomCurvePainter.yForScale(
        size,
        1.0,
        scaleMin: 0.5,
        scaleMax: 3.0,
      );
      expect(painter.hitTestKeyframe(size, const Offset(2, 0) + Offset(0, y)), 0);
    });

    test('命中第二个关键帧（t=1, s=2.0）', () {
      final y = ZoomCurvePainter.yForScale(
        size,
        2.0,
        scaleMin: 0.5,
        scaleMax: 3.0,
      );
      expect(
        painter.hitTestKeyframe(size, const Offset(400, 0) + Offset(0, y)),
        1,
      );
    });

    test('超出命中半径返回 null', () {
      expect(painter.hitTestKeyframe(size, const Offset(200, 100)), isNull);
    });

    test('距离更近的关键帧优先', () {
      // 曲线中部偏上，距 t=0 关键帧更近
      final y0 = ZoomCurvePainter.yForScale(
        size,
        1.0,
        scaleMin: 0.5,
        scaleMax: 3.0,
      );
      expect(painter.hitTestKeyframe(size, const Offset(10, 0) + Offset(0, y0)), 0);
    });
  });
}
