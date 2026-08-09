import 'dart:io';

import 'package:image/image.dart' as img;

import '../../core/models/zoom_curve.dart' show ZoomCurve, ZoomSample;

/// GIF 变焦导出器（规划文档 2.4 节导出模块的 MVP 方案）。
///
/// 不依赖 FFmpeg（ffmpeg-kit 已从 Maven Central 移除）：逐帧按
/// [ZoomCurve] 采样，以变焦点为中心从源图裁剪视口并缩放，编码为 GIF。
///
/// 视口数学：缩放 [ZoomSample.scale] 倍时，源图可见区域为
/// 以 focalPoint（相对坐标）为中心、尺寸 (w/scale, h/scale) 的矩形。
class GifExporter {
  const GifExporter();

  /// 将 [assetPath] 源图按 [curve] 渲染为 GIF 写入 [outputPath]。
  ///
  /// [frameRate] 帧率；[duration] 动画时长（秒）；
  /// [maxWidth] 输出宽度（保持源图宽高比）。
  Future<void> exportGif({
    required String assetPath,
    required ZoomCurve curve,
    required String outputPath,
    int frameRate = 24,
    double duration = 4,
    int maxWidth = 720,
  }) async {
    final source = img.decodeImage(await File(assetPath).readAsBytes());
    if (source == null) {
      throw StateError('无法解码图片: $assetPath');
    }
    final outHeight = (maxWidth * source.height / source.width).round();
    final totalFrames = (frameRate * duration).round().clamp(1, 1 << 16);
    final frameDurationMs = (1000 / frameRate).round();

    final frames = <img.Image>[];
    for (var i = 0; i < totalFrames; i++) {
      final t = totalFrames <= 1 ? 0.0 : i / (totalFrames - 1);
      frames.add(_renderFrame(source, curve.evaluateAt(t), maxWidth, outHeight));
    }

    final gif = img.encodeGif(frames, duration: frameDurationMs);
    if (gif == null) {
      throw StateError('GIF 编码失败');
    }
    await File(outputPath).writeAsBytes(gif);
  }

  /// 渲染单帧：裁剪以变焦点为中心的视口并缩放到输出尺寸。
  img.Image _renderFrame(
    img.Image src,
    ZoomSample sample,
    int outWidth,
    int outHeight,
  ) {
    final sw = src.width;
    final sh = src.height;
    final cx = sample.focalPoint.dx * sw;
    final cy = sample.focalPoint.dy * sh;
    final viewWidth = sw / sample.scale;
    final viewHeight = sh / sample.scale;

    // 视口左上角，钳制到图像范围内
    final x = (cx - viewWidth / 2).clamp(0.0, (sw - 1).toDouble()).round();
    final y = (cy - viewHeight / 2).clamp(0.0, (sh - 1).toDouble()).round();
    final w = viewWidth.clamp(1.0, (sw - x).toDouble()).round();
    final h = viewHeight.clamp(1.0, (sh - y).toDouble()).round();

    final cropped = img.copyCrop(src, x: x, y: y, width: w, height: h);
    return img.copyResize(
      cropped,
      width: outWidth,
      height: outHeight,
      interpolation: img.Interpolation.cubic,
    );
  }
}
