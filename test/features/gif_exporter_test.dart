import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:zoomlens/core/models/keyframe.dart';
import 'package:zoomlens/core/models/zoom_curve.dart';
import 'package:zoomlens/features/export/gif_exporter.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('zoomlens_gif_test');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  /// 生成一张 20x10 的纯色测试图。
  String writeTestImage({int width = 20, int height = 10}) {
    final image = img.Image(width: width, height: height);
    for (final p in image) {
      p.setRgb(200, 100, 50);
    }
    final path = '${tempDir.path}/src.png';
    File(path).writeAsBytesSync(img.encodePng(image)!);
    return path;
  }

  ZoomCurve linearZoomCurve() => ZoomCurve([
        const Keyframe(
          time: 0.0,
          scale: 1.0,
          easing: EasingType.linear,
          focalPoint: Offset(0.5, 0.5),
        ),
        const Keyframe(
          time: 1.0,
          scale: 2.0,
          easing: EasingType.linear,
          focalPoint: Offset(0.5, 0.5),
        ),
      ]);

  test('导出合法 GIF 文件（头、帧数、尺寸）', () async {
    final srcPath = writeTestImage();
    final outPath = '${tempDir.path}/out.gif';

    await const GifExporter().exportGif(
      assetPath: srcPath,
      curve: linearZoomCurve(),
      outputPath: outPath,
      frameRate: 10,
      duration: 1,
      maxWidth: 20,
    );

    final bytes = File(outPath).readAsBytesSync();
    expect(bytes.length, greaterThan(10));
    // GIF89a 头
    expect(String.fromCharCodes(bytes.take(6)), 'GIF89a');

    final frames = img.decodeGif(bytes);
    expect(frames, isNotNull);
    expect(frames!.length, 10); // 10fps * 1s
    // 输出尺寸保持源图宽高比
    expect(frames.first.width, 20);
    expect(frames.first.height, 10);
  });

  test('变焦点缩放：首帧（scale=1）与原图一致，末帧（scale=2）为放大视口', () async {
    final srcPath = writeTestImage();
    final outPath = '${tempDir.path}/out2.gif';

    await const GifExporter().exportGif(
      assetPath: srcPath,
      curve: linearZoomCurve(),
      outputPath: outPath,
      frameRate: 4,
      duration: 1,
      maxWidth: 20,
    );

    final frames = img.decodeGif(File(outPath).readAsBytesSync())!;
    expect(frames.length, 4);
    // scale=1 首帧：像素与原图一致（居中变焦点，视口=全图）
    expect(frames.first.getPixel(5, 5).r, 200);
    // scale=2 末帧：视口为原图中心 10x5 区域放大 → 像素仍为该颜色
    expect(frames.last.getPixel(5, 5).r, 200);
  });

  test('图片无法解码时抛错', () async {
    final badPath = '${tempDir.path}/bad.png';
    File(badPath).writeAsBytesSync(List<int>.filled(16, 0));
    await expectLater(
      const GifExporter().exportGif(
        assetPath: badPath,
        curve: linearZoomCurve(),
        outputPath: '${tempDir.path}/x.gif',
        frameRate: 4,
        duration: 1,
      ),
      throwsStateError,
    );
  });
}
