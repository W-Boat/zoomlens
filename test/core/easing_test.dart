import 'package:flutter_test/flutter_test.dart';
import 'package:zoomlens/core/math/easing.dart';
import 'package:zoomlens/core/models/keyframe.dart' show EasingType;

void main() {
  group('evaluateEasing', () {
    test('linear 保持线性', () {
      expect(evaluateEasing(EasingType.linear, 0.0), 0.0);
      expect(evaluateEasing(EasingType.linear, 0.5), closeTo(0.5, 1e-9));
      expect(evaluateEasing(EasingType.linear, 1.0), 1.0);
    });

    test('easeIn / easeOut 端点正确', () {
      expect(evaluateEasing(EasingType.easeIn, 0.0), 0.0);
      expect(evaluateEasing(EasingType.easeIn, 1.0), 1.0);
      expect(evaluateEasing(EasingType.easeOut, 0.0), 0.0);
      expect(evaluateEasing(EasingType.easeOut, 1.0), 1.0);
    });

    test('easeIn 慢于线性、easeOut 快于线性（中间值 0.5）', () {
      const t = 0.5;
      final linear = evaluateEasing(EasingType.linear, t);
      final inV = evaluateEasing(EasingType.easeIn, t);
      final outV = evaluateEasing(EasingType.easeOut, t);
      expect(inV, lessThan(linear));
      expect(outV, greaterThan(linear));
    });

    test('easeInOut 在 0.5 处恰为 0.5', () {
      expect(evaluateEasing(EasingType.easeInOut, 0.5), closeTo(0.5, 1e-9));
    });

    test('cubicBezier 端点正确且单调（默认 ease 曲线）', () {
      expect(evaluateEasing(EasingType.cubicBezier, 0.0), 0.0);
      expect(evaluateEasing(EasingType.cubicBezier, 1.0), 1.0);
      // 默认控制点 (0.25, 0.1)/(0.25, 1.0) 为 CSS ease 风格：
      // 前半程推进较快（y(0.5) > 0.5），并非对称曲线
      expect(
        evaluateEasing(EasingType.cubicBezier, 0.5),
        greaterThan(0.5),
      );
      var prev = 0.0;
      for (var i = 1; i <= 100; i++) {
        final v = evaluateEasing(EasingType.cubicBezier, i / 100.0);
        expect(v, greaterThanOrEqualTo(prev - 1e-9), reason: 't=${i / 100}');
        prev = v;
      }
    });

    test('cubicBezier 对称控制点曲线中点恰为 0.5', () {
      const c1 = Offset(0.5, 0.0);
      const c2 = Offset(0.5, 1.0);
      expect(
        evaluateEasing(
          EasingType.cubicBezier,
          0.5,
          control1: c1,
          control2: c2,
        ),
        closeTo(0.5, 1e-3),
      );
    });

    test('cubicBezier 自定义控制点生效（先慢后快的曲线在 0.5 前小于 0.5）', () {
      const c1 = Offset(0.2, 0.0);
      const c2 = Offset(0.8, 0.0);
      expect(
        evaluateEasing(
          EasingType.cubicBezier,
          0.5,
          control1: c1,
          control2: c2,
        ),
        lessThan(0.5),
      );
    });

    test('t 越界时被钳制到 [0,1]', () {
      expect(evaluateEasing(EasingType.linear, -1.0), 0.0);
      expect(evaluateEasing(EasingType.linear, 2.0), 1.0);
    });
  });
}
