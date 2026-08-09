import 'package:flutter/material.dart';

/// 变焦点标记覆盖层（规划文档 2.2 节「变焦点选择/标记」）。
///
/// 以十字准星 + 圆形标记显示当前变焦点，支持拖拽调整位置。
/// [focalPoint] 为相对坐标（0..1），与素材分辨率解耦。
class FocalPointOverlay extends StatelessWidget {
  const FocalPointOverlay({super.key, required this.focalPoint, this.onChanged});

  final Offset focalPoint;

  /// 拖拽回调（相对坐标 0..1）。
  final ValueChanged<Offset>? onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final center = Offset(
          focalPoint.dx * size.width,
          focalPoint.dy * size.height,
        );
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: onChanged == null
              ? null
              : (details) {
                  final local = details.localPosition;
                  onChanged!(
                    Offset(
                      (local.dx / size.width).clamp(0.0, 1.0),
                      (local.dy / size.height).clamp(0.0, 1.0),
                    ),
                  );
                },
          child: CustomPaint(
            painter: _FocalPointPainter(center: center),
            size: size,
          ),
        );
      },
    );
  }
}

class _FocalPointPainter extends CustomPainter {
  const _FocalPointPainter({required this.center});

  final Offset center;

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 18.0;
    final paint = Paint()
      ..color = const Color(0xFFFFEB3B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 圆形标记
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, 2.0, Paint()..color = const Color(0xFFFFEB3B));

    // 十字准星
    canvas.drawLine(
      Offset(center.dx - radius - 8, center.dy),
      Offset(center.dx + radius + 8, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius - 8),
      Offset(center.dx, center.dy + radius + 8),
      paint,
    );
  }

  @override
  bool shouldRepaint(_FocalPointPainter oldDelegate) =>
      oldDelegate.center != center;
}
