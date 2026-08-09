import 'package:flutter/material.dart';

import '../../core/models/keyframe.dart' show Keyframe;
import '../../core/models/zoom_curve.dart' show ZoomCurve;

/// 曲线编辑器画板：绘制「时间 - 缩放」曲线与变焦点辅助轨道
/// （规划文档 2.2 节时间轴可视化 + 变焦点辅助轨道）。
class ZoomCurvePainter extends CustomPainter {
  const ZoomCurvePainter({
    required this.curve,
    required this.scaleMin,
    required this.scaleMax,
    this.currentTime = 0.0,
  });

  final ZoomCurve curve;
  final double scaleMin;
  final double scaleMax;
  final double currentTime;

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

    // 曲线区域：顶部 5% 留白，底部 15% 为变焦点辅助轨道
    final curveAreaTop = size.height * 0.05;
    final trackTop = size.height * 0.85;
    final curveAreaHeight = trackTop - curveAreaTop;

    double yForScale(double scale) {
      final ratio =
          ((scale - scaleMin) / (scaleMax - scaleMin)).clamp(0.0, 1.0);
      return curveAreaTop + (1.0 - ratio) * curveAreaHeight;
    }

    // 采样曲线路径（每 1% 采样一次）
    final path = Path();
    for (var i = 0; i <= 100; i++) {
      final t = i / 100.0;
      final sample = curve.evaluateAt(t);
      final x = t * size.width;
      final y = yForScale(sample.scale);
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

    // 关键帧圆点
    for (final kf in curve.keyframes) {
      canvas.drawCircle(
        Offset(kf.time * size.width, yForScale(kf.scale)),
        4.0,
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
    for (final kf in curve.keyframes) {
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
      oldDelegate.currentTime != currentTime;
}
