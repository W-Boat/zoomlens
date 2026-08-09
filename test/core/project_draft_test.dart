import 'package:flutter_test/flutter_test.dart';
import 'package:zoomlens/core/models/keyframe.dart';
import 'package:zoomlens/core/models/project_draft.dart';

void main() {
  group('ProjectDraft 序列化', () {
    test('toJson/fromJson 往返保持关键帧数据', () {
      final draft = ProjectDraft(
        assetPath: '/tmp/photo.jpg',
        createdAt: DateTime(2026, 8, 9, 10, 30),
        keyframes: const [
          Keyframe(
            time: 0.0,
            scale: 1.0,
            easing: EasingType.linear,
            focalPoint: Offset(0.2, 0.3),
          ),
          Keyframe(
            time: 0.5,
            scale: 1.8,
            easing: EasingType.easeInOut,
            focalPoint: Offset(0.5, 0.5),
          ),
          Keyframe(
            time: 1.0,
            scale: 1.2,
            easing: EasingType.cubicBezier,
            focalPoint: Offset(0.8, 0.9),
            bezierControl1: Offset(0.3, 0.1),
            bezierControl2: Offset(0.7, 1.0),
          ),
        ],
      );

      final restored = ProjectDraft.fromJson(draft.toJson());

      expect(restored.assetPath, draft.assetPath);
      expect(restored.createdAt, draft.createdAt);
      expect(restored.keyframes.length, 3);
      for (var i = 0; i < draft.keyframes.length; i++) {
        final a = draft.keyframes[i];
        final b = restored.keyframes[i];
        expect(b.time, a.time);
        expect(b.scale, a.scale);
        expect(b.easing, a.easing);
        expect(b.focalPoint, a.focalPoint);
        expect(b.bezierControl1, a.bezierControl1);
        expect(b.bezierControl2, a.bezierControl2);
      }
    });

    test('恢复出的曲线求值与原曲线一致', () {
      final draft = ProjectDraft(
        assetPath: '/tmp/photo.jpg',
        createdAt: DateTime(2026),
        keyframes: const [
          Keyframe(
            time: 0.0,
            scale: 1.0,
            easing: EasingType.easeOut,
            focalPoint: Offset(0.5, 0.5),
          ),
          Keyframe(
            time: 1.0,
            scale: 2.0,
            easing: EasingType.easeOut,
            focalPoint: Offset(0.5, 0.5),
          ),
        ],
      );
      final restored = ProjectDraft.fromJson(draft.toJson());
      final original = draft.toCurve();
      final curve = restored.toCurve();
      for (var i = 0; i <= 10; i++) {
        final t = i / 10.0;
        expect(curve.evaluateAt(t).scale,
            closeTo(original.evaluateAt(t).scale, 1e-9));
      }
    });
  });
}
