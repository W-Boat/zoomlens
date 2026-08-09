import 'dart:ui' show Offset;

import 'keyframe.dart' show EasingType, Keyframe;
import 'zoom_curve.dart' show ZoomCurve;

/// 项目草稿：素材路径 + 变焦曲线 + 创建时间（规划文档 2.5 节）。
///
/// 关键帧以 JSON 序列化，可直接存入 Hive（无需 build_runner 适配器）。
class ProjectDraft {
  const ProjectDraft({
    required this.assetPath,
    required this.keyframes,
    required this.createdAt,
  });

  /// 素材（照片）路径。
  final String assetPath;

  /// 变焦曲线关键帧。
  final List<Keyframe> keyframes;

  /// 创建时间。
  final DateTime createdAt;

  /// 恢复为可求值的变焦曲线。
  ZoomCurve toCurve() => ZoomCurve(keyframes);

  Map<String, dynamic> toJson() => {
        'assetPath': assetPath,
        'createdAt': createdAt.toIso8601String(),
        'keyframes': [
          for (final k in keyframes) _keyframeToJson(k),
        ],
      };

  factory ProjectDraft.fromJson(Map<String, dynamic> json) {
    final kfJson = (json['keyframes'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    return ProjectDraft(
      assetPath: json['assetPath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      keyframes: [for (final j in kfJson) _keyframeFromJson(j)],
    );
  }

  static Map<String, dynamic> _keyframeToJson(Keyframe k) => {
        'time': k.time,
        'scale': k.scale,
        'easing': k.easing.name,
        'fx': k.focalPoint.dx,
        'fy': k.focalPoint.dy,
        'c1x': k.bezierControl1?.dx,
        'c1y': k.bezierControl1?.dy,
        'c2x': k.bezierControl2?.dx,
        'c2y': k.bezierControl2?.dy,
      };

  static Keyframe _keyframeFromJson(Map<String, dynamic> j) => Keyframe(
        time: (j['time'] as num).toDouble(),
        scale: (j['scale'] as num).toDouble(),
        easing: EasingType.values
            .firstWhere((e) => e.name == j['easing']),
        focalPoint: Offset(
          (j['fx'] as num).toDouble(),
          (j['fy'] as num).toDouble(),
        ),
        bezierControl1: j['c1x'] == null
            ? null
            : Offset(
                (j['c1x'] as num).toDouble(),
                (j['c1y'] as num).toDouble(),
              ),
        bezierControl2: j['c2x'] == null
            ? null
            : Offset(
                (j['c2x'] as num).toDouble(),
                (j['c2y'] as num).toDouble(),
              ),
      );
}
