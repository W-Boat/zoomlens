import 'package:flutter/material.dart';

import '../../core/models/zoom_curve.dart' show ZoomCurve;

/// 曲线编辑器画板：绘制「时间 - 缩放」曲线与变焦点辅助轨道
/// （规划文档 2.2 节时间轴可视化 + 变焦点辅助轨道）。
///
/// 布局比例（供交互层复用坐标换算）：
/// 顶部 5% 留白，底部 15% 为变焦点辅助轨道，中间为曲线区。
class ZoomCurvePainter extends CustomPainter {
  const ZoomCurvePainter({
    required this.curve,
    required this.scaleMin,
    required this.scaleMax,
    this.currentTime = 0.0,
    this.selectedIndex,
  });

  final ZoomCurve curve;
  final double scaleMin;
  final double scaleMax;
  final double currentTime;

  /// 选中关键帧的下标（高亮显示）。
  final int? selectedIndex;

  /// 关键帧命中半径（像素）。
  static const double hitRadius = 14.0;

  // ---- 布局换算（静态，供手势层复用） ----
  static const double topFraction = 0.05;
  static const double trackFraction = 0.85;

  static double curveTop(Size size) => size.height * topFraction;
  static double trackTop(Size size) => size.height * trackFraction;
  static double curveHeight(Size size) => trackTop(size) - curveTop(size);

  static double yForScale(
    Size size,
    double scale, {
    required double scaleMin,
    required double scaleMax,
  }) {
    final ratio = ((scale - scaleMin) / (scaleMax - scaleMin))
        .clamp(0.0, 1.0)
        .toDouble();
    return curveTop(size) + (1.0 - ratio) * curveHeight(size);
  }

  static double scaleForY(
    Size size,
    double y, {
    required double scaleMin,
    required double scaleMax,
  }) {
    final ratio = ((y - curveTop(size)) / curveHeight(size))
        .clamp(0.0, 1.0)
        .toDouble();
    return scaleMin + (1.0 - ratio) * (scaleMax - scaleMin);
  }

  /// 返回距 [point] 最近的关键帧下标；超出 [hitRadius] 返回 null。
  int? hitTestKeyframe(Size size, Offset point) {
    var best = -1;
    var bestDistance = double.infinity;
    for (var i = 0; i < curve.keyframes.length; i++) {
      final kf = curve.keyframes[i];
      final center = Offset(
        kf.time * size.width,
        yForScale(size, kf.scale, scaleMin: scaleMin, scaleMax: scaleMax),
      );
      final d = (center - point).distance;
      if (d < bestDistance) {
        bestDistance = d;
        best = i;
      }
    }
    return bestDistance <= hitRadius ? best : null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 1.0;

    // 背景网格（4 等分）
    for (var i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      final y = size.height * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final trackTop = ZoomCurvePainter.trackTop(size);

    // 采样曲线路径（每 1% 采样一次）
    final path = Path();
    for (var i = 0; i <= 100; i++) {
      final t = i / 100.0;
      final sample = curve.evaluateAt(t);
      final x = t * size.width;
      final y = ZoomCurvePainter.yForScale(
        size,
        sample.scale,
        scaleMin: scaleMin,
        scaleMax: scaleMax,
      );
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF2196F3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // 关键帧圆点（选中高亮）
    final keyframes = curve.keyframes;
    for (var i = 0; i < keyframes.length; i++) {
      final kf = keyframes[i];
      final center = Offset(
        kf.time * size.width,
        ZoomCurvePainter.yForScale(
          size,
          kf.scale,
          scaleMin: scaleMin,
          scaleMax: scaleMax,
        ),
      );
      final selected = i == selectedIndex;
      if (selected) {
        canvas.drawCircle(
          center,
          9.0,
          Paint()..color = const Color(0xFFFFC107),
        );
      }
      canvas.drawCircle(
        center,
        selected ? 6.0 : 4.0,
        Paint()..color = const Color(0xFFFF5722),
      );
    }

    // 变焦点辅助轨道：水平线 + 每关键帧按 focalPoint 绘制标记
    canvas.drawLine(
      Offset(0, trackTop),
      Offset(size.width, trackTop),
      Paint()
        ..color = const Color(0x44000000)
        ..strokeWidth = 1.0,
    );
    for (final kf in keyframes) {
      final x = kf.time * size.width;
      final dy = kf.focalPoint.dy; // 变焦点 y（相对坐标）
      canvas.drawLine(
        Offset(x, trackTop - 4),
        Offset(x, trackTop + 4),
        Paint()
          ..color = Color.lerp(const Color(0xFF4CAF50), const Color(0xFF9C27B0), dy)!
          ..strokeWidth = 2.0,
      );
    }

    // 播放头
    canvas.drawLine(
      Offset(currentTime * size.width, 0),
      Offset(currentTime * size.width, size.height),
      Paint()
        ..color = const Color(0x66FF9800)
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(ZoomCurvePainter oldDelegate) =>
      oldDelegate.curve != curve ||
      oldDelegate.scaleMin != scaleMin ||
      oldDelegate.scaleMax != scaleMax ||
      oldDelegate.currentTime != currentTime ||
      oldDelegate.selectedIndex != selectedIndex;
}
