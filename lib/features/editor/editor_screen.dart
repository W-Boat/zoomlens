import 'package:flutter/material.dart';

import '../../core/models/keyframe.dart' show Keyframe;
import '../../core/models/zoom_curve.dart' show ZoomCurve;
import '../presets/zoom_presets.dart' show ZoomPreset, zoomPresets;
import 'focal_point_overlay.dart' show FocalPointOverlay;
import 'zoom_curve_painter.dart' show ZoomCurvePainter;

/// 曲线编辑器（规划文档 2.2 节，含「变焦点驱动变焦」）。
///
/// 骨架状态：内置预设曲线、播放头滑块、变焦点拖拽（更新最近关键帧）。
/// 后续迭代：关键帧增删/拖拽、多段曲线、锁定/自由变焦点、撤销重做、素材接入。
class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  static const _scaleMin = 0.5;
  static const _scaleMax = 3.0;

  late ZoomPreset _selectedPreset;
  late List<Keyframe> _keyframes;
  late ZoomCurve _curve;
  double _playhead = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedPreset = zoomPresets.first;
    _keyframes = List<Keyframe>.of(_selectedPreset.keyframes);
    _curve = ZoomCurve(_keyframes);
  }

  void _applyPreset(ZoomPreset preset) {
    setState(() {
      _selectedPreset = preset;
      _keyframes = List<Keyframe>.of(preset.keyframes);
      _curve = ZoomCurve(_keyframes);
      _playhead = 0.0;
    });
  }

  /// 拖拽变焦点：更新距当前播放头最近的关键帧（支持逐关键帧自由调整）。
  void _updateFocalPoint(Offset point) {
    var bestIndex = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < _keyframes.length; i++) {
      final d = (_keyframes[i].time - _playhead).abs();
      if (d < bestDistance) {
        bestDistance = d;
        bestIndex = i;
      }
    }
    final updated = List<Keyframe>.of(_keyframes);
    final kf = updated[bestIndex];
    updated[bestIndex] = Keyframe(
      time: kf.time,
      scale: kf.scale,
      easing: kf.easing,
      focalPoint: point,
      bezierControl1: kf.bezierControl1,
      bezierControl2: kf.bezierControl2,
    );
    setState(() {
      _keyframes = updated;
      _curve = ZoomCurve(_keyframes);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sample = _curve.evaluateAt(_playhead);
    return Scaffold(
      appBar: AppBar(title: const Text('变焦编辑')),
      body: Column(
        children: [
          // 预览区：占位素材 + 变焦点标记（可拖拽）
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.black87,
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      '素材预览（骨架）',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  FocalPointOverlay(
                    focalPoint: sample.focalPoint,
                    onChanged: _updateFocalPoint,
                  ),
                ],
              ),
            ),
          ),
          // 曲线编辑区
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('预设：'),
                      DropdownButton<ZoomPreset>(
                        value: _selectedPreset,
                        items: [
                          for (final p in zoomPresets)
                            DropdownMenuItem(value: p, child: Text(p.name)),
                        ],
                        onChanged: (p) {
                          if (p != null) _applyPreset(p);
                        },
                      ),
                      const Spacer(),
                      Text(
                        '${sample.scale.toStringAsFixed(2)}x',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  Expanded(
                    child: CustomPaint(
                      painter: ZoomCurvePainter(
                        curve: _curve,
                        scaleMin: _scaleMin,
                        scaleMax: _scaleMax,
                        currentTime: _playhead,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                  Slider(
                    value: _playhead,
                    onChanged: (v) => setState(() => _playhead = v),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
