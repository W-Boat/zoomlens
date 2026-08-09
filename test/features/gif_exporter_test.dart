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
    File(path).writeAsBytesSync(img.encodePng(image));
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

  test('导出合法 GIF 文件（头、可解码、尺寸）', () async {
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

    // image 4.x 的 GIF 解码为单帧（decodeImage 自动识别），验证首帧尺寸
    final decoded = img.decodeImage(bytes);
    expect(decoded, isNotNull);
    expect(decoded!.width, 20);
    expect(decoded.height, 10);
  });

  test('首帧（scale=1 居中变焦点）像素与原图一致', () async {
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

    final decoded = img.decodeImage(File(outPath).readAsBytesSync())!;
    final pixel = decoded.getPixel(5, 5);
    expect(pixel.r, 200);
    expect(pixel.g, 100);
    expect(pixel.b, 50);
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
