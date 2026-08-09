import 'dart:ui' show Offset;

import '../../core/models/keyframe.dart' show EasingType, Keyframe;

/// 预设变焦效果定义（规划文档 2.2 节曲线预设模板 / 2.3 节预设库）。
class ZoomPreset {
  const ZoomPreset({
    required this.name,
    required this.category,
    required this.description,
    required this.keyframes,
  });

  final String name;
  final String category;
  final String description;
  final List<Keyframe> keyframes;
}

/// 内置预设库：一键应用到当前素材，参数可微调。
const zoomPresets = <ZoomPreset>[
  ZoomPreset(
    name: '电影推拉',
    category: '电影',
    description: '缓慢推近，模拟电影镜头语言',
    keyframes: [
      Keyframe(
        time: 0.0,
        scale: 1.0,
        easing: EasingType.easeInOut,
        focalPoint: Offset(0.5, 0.5),
      ),
      Keyframe(
        time: 1.0,
        scale: 1.8,
        easing: EasingType.easeInOut,
        focalPoint: Offset(0.5, 0.5),
      ),
    ],
  ),
  ZoomPreset(
    name: '呼吸变焦',
    category: '艺术',
    description: '轻微周期性缩放，营造呼吸感',
    keyframes: [
      Keyframe(
        time: 0.0,
        scale: 1.0,
        easing: EasingType.easeInOut,
        focalPoint: Offset(0.5, 0.5),
      ),
      Keyframe(
        time: 0.5,
        scale: 1.15,
        easing: EasingType.easeInOut,
        focalPoint: Offset(0.5, 0.5),
      ),
      Keyframe(
        time: 1.0,
        scale: 1.0,
        easing: EasingType.easeInOut,
        focalPoint: Offset(0.5, 0.5),
      ),
    ],
  ),
  ZoomPreset(
    name: '冲击缩放',
    category: '电影',
    description: '快速推近后定格，强调重点',
    keyframes: [
      Keyframe(
        time: 0.0,
        scale: 1.0,
        easing: EasingType.easeOut,
        focalPoint: Offset(0.5, 0.5),
      ),
      Keyframe(
        time: 1.0,
        scale: 2.2,
        easing: EasingType.easeOut,
        focalPoint: Offset(0.5, 0.5),
      ),
    ],
  ),
  ZoomPreset(
    name: '平滑拉远',
    category: 'Vlog',
    description: '从特写逐渐拉远到全景',
    keyframes: [
      Keyframe(
        time: 0.0,
        scale: 1.8,
        easing: EasingType.easeInOut,
        focalPoint: Offset(0.5, 0.5),
      ),
      Keyframe(
        time: 1.0,
        scale: 1.0,
        easing: EasingType.easeInOut,
        focalPoint: Offset(0.5, 0.5),
      ),
    ],
  ),
  ZoomPreset(
    name: '心跳节奏',
    category: '节奏',
    description: '跟随音乐节拍的缩放律动（双心跳）',
    keyframes: [
      Keyframe(
        time: 0.0,
        scale: 1.0,
        easing: EasingType.easeOut,
        focalPoint: Offset(0.5, 0.5),
      ),
      Keyframe(
        time: 0.25,
        scale: 1.25,
        easing: EasingType.easeOut,
        focalPoint: Offset(0.5, 0.5),
      ),
      Keyframe(
        time: 0.5,
        scale: 1.0,
        easing: EasingType.easeOut,
        focalPoint: Offset(0.5, 0.5),
      ),
      Keyframe(
        time: 0.75,
        scale: 1.2,
        easing: EasingType.easeOut,
        focalPoint: Offset(0.5, 0.5),
      ),
      Keyframe(
        time: 1.0,
        scale: 1.0,
        easing: EasingType.easeOut,
        focalPoint: Offset(0.5, 0.5),
      ),
    ],
  ),
];
