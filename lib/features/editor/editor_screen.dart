import 'package:flutter/material.dart';

import '../../core/models/keyframe.dart' show EasingType, Keyframe;
import '../../core/models/zoom_curve.dart' show ZoomCurve;
import '../presets/zoom_presets.dart' show ZoomPreset, zoomPresets;
import 'focal_point_overlay.dart' show FocalPointOverlay;
import 'zoom_curve_painter.dart' show ZoomCurvePainter;

/// 曲线编辑器（规划文档 2.2 节，含「变焦点驱动变焦」）。
///
/// 已实现：预设一键应用、点击曲线添加关键帧、选中/删除/拖拽关键帧、
/// 撤销/重做、播放预览（围绕变焦点实时缩放）、变焦点拖拽。
/// 后续迭代：缓动类型编辑、锁定/自由变焦点、素材接入、导出。
class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen>
    with SingleTickerProviderStateMixin {
  static const _scaleMin = 0.5;
  static const _scaleMax = 3.0;
  static const _minKeyframes = 2;

  late ZoomPreset _selectedPreset;
  late List<Keyframe> _keyframes;
  late ZoomCurve _curve;
  late final AnimationController _playback;
  late ZoomCurvePainter _painter;

  double _playhead = 0.0;
  int? _selectedIndex;
  int? _dragIndex;

  final List<List<Keyframe>> _undoStack = [];
  final List<List<Keyframe>> _redoStack = [];

  @override
  void initState() {
    super.initState();
    _selectedPreset = zoomPresets.first;
    _keyframes = List<Keyframe>.of(_selectedPreset.keyframes);
    _curve = ZoomCurve(_keyframes);
    _playback = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        setState(() => _playhead = _playback.value);
      });
    _painter = _buildPainter();
  }

  @override
  void dispose() {
    _playback.dispose();
    super.dispose();
  }

  ZoomCurvePainter _buildPainter() => ZoomCurvePainter(
        curve: _curve,
        scaleMin: _scaleMin,
        scaleMax: _scaleMax,
        currentTime: _playhead,
        selectedIndex: _selectedIndex,
      );

  bool get _isPlaying => _playback.isAnimating;

  // ---- 状态快照（撤销/重做） ----

  void _pushUndo() {
    _undoStack.add(List<Keyframe>.of(_keyframes));
    _redoStack.clear();
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(List<Keyframe>.of(_keyframes));
    setState(() {
      _keyframes = _undoStack.removeLast();
      _selectedIndex = null;
      _dragIndex = null;
      _rebuildCurve();
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(List<Keyframe>.of(_keyframes));
    setState(() {
      _keyframes = _redoStack.removeLast();
      _selectedIndex = null;
      _dragIndex = null;
      _rebuildCurve();
    });
  }

  void _rebuildCurve() {
    _curve = ZoomCurve(_keyframes);
    _painter = _buildPainter();
  }

  // ---- 关键帧操作 ----

  void _applyPreset(ZoomPreset preset) {
    if (identical(preset, _selectedPreset)) return;
    _pushUndo();
    setState(() {
      _selectedPreset = preset;
      _keyframes = List<Keyframe>.of(preset.keyframes);
      _selectedIndex = null;
      _playhead = 0.0;
      if (_isPlaying) _playback.stop();
      _rebuildCurve();
    });
  }

  /// 在 [time]/[scale] 处添加关键帧（变焦点取当前曲线插值）。
  void _addKeyframeAt(double time, double scale) {
    final tooClose =
        _keyframes.any((kf) => (kf.time - time).abs() < 0.02);
    if (tooClose) return;
    _pushUndo();
    setState(() {
      final sample = _curve.evaluateAt(time);
      _keyframes.add(Keyframe(
        time: time,
        scale: scale,
        easing: EasingType.easeInOut,
        focalPoint: sample.focalPoint,
      ));
      _keyframes.sort((a, b) => a.time.compareTo(b.time));
      _rebuildCurve();
      _selectedIndex = _keyframes.indexWhere((kf) => kf.time == time);
    });
  }

  void _deleteSelected() {
    final index = _selectedIndex;
    if (index == null || _keyframes.length <= _minKeyframes) return;
    _pushUndo();
    setState(() {
      _keyframes.removeAt(index);
      _selectedIndex = null;
      _dragIndex = null;
      _rebuildCurve();
    });
  }

  /// 移动关键帧：时间钳制在相邻关键帧之间，缩放钳制在范围内。
  void _moveKeyframe(int index, double time, double scale) {
    final lower = index > 0 ? _keyframes[index - 1].time + 0.01 : 0.0;
    final upper =
        index < _keyframes.length - 1 ? _keyframes[index + 1].time - 0.01 : 1.0;
    final t = time.clamp(lower, upper).toDouble();
    final s = scale.clamp(_scaleMin, _scaleMax).toDouble();
    final kf = _keyframes[index];
    final updated = List<Keyframe>.of(_keyframes);
    updated[index] = Keyframe(
      time: t,
      scale: s,
      easing: kf.easing,
      focalPoint: kf.focalPoint,
      bezierControl1: kf.bezierControl1,
      bezierControl2: kf.bezierControl2,
    );
    setState(() {
      _keyframes = updated;
      _rebuildCurve();
    });
  }

  /// 更新变焦点：优先选中关键帧，否则取距播放头最近的关键帧。
  void _updateFocalPoint(Offset point) {
    final index = _selectedIndex ?? _nearestKeyframeTo(_playhead);
    final kf = _keyframes[index];
    final updated = List<Keyframe>.of(_keyframes);
    updated[index] = Keyframe(
      time: kf.time,
      scale: kf.scale,
      easing: kf.easing,
      focalPoint: point,
      bezierControl1: kf.bezierControl1,
      bezierControl2: kf.bezierControl2,
    );
    setState(() {
      _keyframes = updated;
      _rebuildCurve();
    });
  }

  int _nearestKeyframeTo(double time) {
    var best = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < _keyframes.length; i++) {
      final d = (_keyframes[i].time - time).abs();
      if (d < bestDistance) {
        bestDistance = d;
        best = i;
      }
    }
    return best;
  }

  // ---- 曲线画布手势 ----

  void _onCurveTap(Offset local, Size size) {
    final hit = _painter.hitTestKeyframe(size, local);
    if (hit != null) {
      setState(() => _selectedIndex = hit);
      return;
    }
    final time = (local.dx / size.width).clamp(0.0, 1.0).toDouble();
    final scale = ZoomCurvePainter.scaleForY(
      size,
      local.dy,
      scaleMin: _scaleMin,
      scaleMax: _scaleMax,
    );
    _addKeyframeAt(time, scale);
  }

  void _onCurvePanStart(Offset local, Size size) {
    final hit = _painter.hitTestKeyframe(size, local);
    if (hit == null) return;
    _pushUndo();
    setState(() {
      _selectedIndex = hit;
      _dragIndex = hit;
    });
  }

  void _onCurvePanUpdate(Offset local, Size size) {
    final index = _dragIndex;
    if (index == null) return;
    final time = (local.dx / size.width).clamp(0.0, 1.0).toDouble();
    final scale = ZoomCurvePainter.scaleForY(
      size,
      local.dy,
      scaleMin: _scaleMin,
      scaleMax: _scaleMax,
    );
    _moveKeyframe(index, time, scale);
  }

  // ---- 播放 ----

  void _togglePlayback() {
    if (_isPlaying) {
      _playback.stop();
    } else {
      _playback.repeat();
    }
  }

  void _onPlayheadChanged(double value) {
    if (_isPlaying) _playback.stop();
    setState(() => _playhead = value);
  }

  // ---- UI ----

  String get _selectedInfo {
    final index = _selectedIndex;
    if (index == null || index >= _keyframes.length) {
      return '点击曲线空白处添加关键帧；拖动关键帧调整；预览区拖动十字调整变焦点';
    }
    final kf = _keyframes[index];
    return '关键帧 #$index  时间 ${kf.time.toStringAsFixed(2)}  '
        '缩放 ${kf.scale.toStringAsFixed(2)}x  '
        '变焦点 (${kf.focalPoint.dx.toStringAsFixed(2)}, '
        '${kf.focalPoint.dy.toStringAsFixed(2)})';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('变焦编辑')),
      body: Column(
        children: [
          _buildPreview(),
          _buildCurveEditor(context),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Expanded(
      flex: 5,
      child: Container(
        color: Colors.black87,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final sample = _curve.evaluateAt(_playhead);
            // 以变焦点为锚点的缩放矩阵：translate(f) → scale(s) → translate(-f)
            final matrix = Matrix4.identity()
              ..translateByDouble(
                  sample.focalPoint.dx * size.width,
                  sample.focalPoint.dy * size.height,
                  0.0,
                  1.0)
              ..scaleByDouble(sample.scale, sample.scale, 1.0, 1.0)
              ..translateByDouble(
                  -sample.focalPoint.dx * size.width,
                  -sample.focalPoint.dy * size.height,
                  0.0,
                  1.0);
            return Stack(
              children: [
                Center(
                  child: Transform(
                    transform: matrix,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.photo_outlined,
                          size: 96,
                          color: Colors.white38,
                        ),
                        const Text(
                          '素材预览（骨架）',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          '${sample.scale.toStringAsFixed(2)}x',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                FocalPointOverlay(
                  focalPoint: sample.focalPoint,
                  onDragStart: _pushUndo,
                  onChanged: _updateFocalPoint,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurveEditor(BuildContext context) {
    return Expanded(
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
                IconButton(
                  icon: const Icon(Icons.undo),
                  tooltip: '撤销',
                  onPressed: _undoStack.isEmpty ? null : _undo,
                ),
                IconButton(
                  icon: const Icon(Icons.redo),
                  tooltip: '重做',
                  onPressed: _redoStack.isEmpty ? null : _redo,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: '删除关键帧',
                  onPressed: _selectedIndex == null ||
                          _keyframes.length <= _minKeyframes
                      ? null
                      : _deleteSelected,
                ),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  tooltip: '播放预览',
                  onPressed: _togglePlayback,
                ),
                Text('${_keyframes.length} 帧'),
              ],
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  return GestureDetector(
                    key: const Key('zoom-curve-canvas'),
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (d) => _onCurveTap(d.localPosition, size),
                    onPanStart: (d) =>
                        _onCurvePanStart(d.localPosition, size),
                    onPanUpdate: (d) =>
                        _onCurvePanUpdate(d.localPosition, size),
                    onPanEnd: (_) => _dragIndex = null,
                    child: CustomPaint(painter: _painter, size: size),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _playhead,
                    onChanged: _onPlayheadChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_curve.evaluateAt(_playhead).scale.toStringAsFixed(2)}x',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            Text(
              _selectedInfo,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
