import 'dart:ui' show Offset;

import 'package:flutter_test/flutter_test.dart';
import 'package:zoomlens/core/math/zoom_transform.dart';

void main() {
  group('zoomTransformAround / applyZoomTransform', () {
    test('变焦点在缩放前后位置不变', () {
      const f = Offset(0.2, 0.3);
      const scale = 2.0;
      final out = applyZoomTransform(f, f, scale);
      expect(out.dx, closeTo(f.dx, 1e-9));
      expect(out.dy, closeTo(f.dy, 1e-9));
    });

    test('围绕画面中心缩放：中心不动、左上角外扩', () {
      const f = Offset(0.5, 0.5);
      const scale = 2.0;
      final center = applyZoomTransform(f, f, scale);
      expect(center.dx, closeTo(0.5, 1e-9));
      expect(center.dy, closeTo(0.5, 1e-9));
      // (0,0) 围绕 (0.5,0.5) 缩放 2x → (1-2)*0.5 = -0.5
      final corner = applyZoomTransform(const Offset(0, 0), f, scale);
      expect(corner.dx, closeTo(-0.5, 1e-9));
      expect(corner.dy, closeTo(-0.5, 1e-9));
    });

    test('scale=1 时恒等变换', () {
      const p = Offset(0.13, 0.77);
      final out = applyZoomTransform(p, const Offset(0.5, 0.5), 1.0);
      expect(out.dx, closeTo(p.dx, 1e-9));
      expect(out.dy, closeTo(p.dy, 1e-9));
    });

    test('缩放 >1 时变焦点两侧的点向远离变焦点的方向移动', () {
      const f = Offset(0.5, 0.5);
      // 变焦点左侧的点 (0.4, 0.5)：缩放 2x 后为 2*0.4 + (1-2)*0.5 = 0.3
      final left = applyZoomTransform(const Offset(0.4, 0.5), f, 2.0);
      expect(left.dx, closeTo(0.3, 1e-9));
      // 变焦点右侧的点 (0.6, 0.5)：缩放 2x 后为 2*0.6 - 0.5 = 0.7
      final right = applyZoomTransform(const Offset(0.6, 0.5), f, 2.0);
      expect(right.dx, closeTo(0.7, 1e-9));
    });

    test('矩阵元素与推导一致（列主序 4x4）', () {
      const f = Offset(0.25, 0.75);
      const s = 1.5;
      final m = zoomTransformAround(f, s);
      expect(m[0], closeTo(s, 1e-9));
      expect(m[5], closeTo(s, 1e-9));
      expect(m[10], 1.0);
      expect(m[12], closeTo(f.dx * (1.0 - s), 1e-9));
      expect(m[13], closeTo(f.dy * (1.0 - s), 1e-9));
      expect(m[15], 1.0);
      const zeroIndices = [1, 2, 3, 4, 6, 7, 8, 9, 11, 14];
      for (final i in zeroIndices) {
        expect(m[i], 0.0, reason: 'm[$i] 应为 0');
      }
    });

    test('applyZoomTransform 与矩阵计算结果一致', () {
      const p = Offset(0.3, 0.6);
      const f = Offset(0.4, 0.2);
      const s = 2.5;
      final direct = applyZoomTransform(p, f, s);
      final viaMatrix = Offset(
        s * p.dx + (1.0 - s) * f.dx,
        s * p.dy + (1.0 - s) * f.dy,
      );
      expect(direct.dx, closeTo(viaMatrix.dx, 1e-9));
      expect(direct.dy, closeTo(viaMatrix.dy, 1e-9));
    });
  });
}
