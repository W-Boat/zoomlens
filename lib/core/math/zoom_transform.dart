import 'dart:typed_data' show Float64List;
import 'dart:ui' show Offset;

/// 以任意点 [focalPoint] 为中心缩放 [scale] 倍的 4x4 矩阵（列主序，可直接用于 Canvas/着色器）。
///
/// 对应规划文档 2.2 节数学实现：`translate(-fx, -fy) → scale(s) → translate(fx, fy)`，
/// 即 M = T(f) · S(s) · T(-f)。
///
/// 推导：对任意点 p，M·p = (p - f)·s + f = s·p + (1-s)·f，
/// 因此列主序矩阵元素为：
///   m[0]  = s          （x 缩放）
///   m[5]  = s          （y 缩放）
///   m[10] = 1          （z 缩放）
///   m[12] = (1-s)·fx   （x 平移）
///   m[13] = (1-s)·fy   （y 平移）
///   m[15] = 1
///
/// 关键性质：变焦点在变换前后位置不变（M·f = f），缩放围绕锚点进行。
Float64List zoomTransformAround(Offset focalPoint, double scale) {
  final m = Float64List(16);
  m[0] = scale;
  m[5] = scale;
  m[10] = 1.0;
  m[12] = focalPoint.dx * (1.0 - scale);
  m[13] = focalPoint.dy * (1.0 - scale);
  m[15] = 1.0;
  return m;
}

/// 将点 [p] 应用「以 [focalPoint] 为中心缩放 [scale]」变换后的坐标。
///
/// 与 [zoomTransformAround] 等价，供单元测试与逐帧渲染直接使用。
Offset applyZoomTransform(Offset p, Offset focalPoint, double scale) {
  return Offset(
    scale * p.dx + (1.0 - scale) * focalPoint.dx,
    scale * p.dy + (1.0 - scale) * focalPoint.dy,
  );
}
