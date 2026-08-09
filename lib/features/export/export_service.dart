/// 导出选项（规划文档 2.4 节）。
class ExportOptions {
  const ExportOptions({
    this.resolution = '1080p',
    this.frameRate = 30,
    this.codec = 'h264',
  });

  /// 720p | 1080p | 4K
  final String resolution;

  /// 24 | 30 | 60
  final int frameRate;

  /// h264 | h265
  final String codec;
}

/// 导出服务（规划文档 2.4 节）。
///
/// 真实渲染实现待接入 FFmpeg 方案后填充：
/// 1. 逐帧按 ZoomCurve.evaluateAt 采样，以变焦点为锚点合成缩放帧；
/// 2. 编码输出（H.264 / H.265），支持后台执行与进度回调；
/// 3. 渐进式导出，控制内存占用（1080p ≤ 500MB，4K ≤ 1GB）。
///
/// 注：骨架阶段不依赖任何 FFmpeg 插件（ffmpeg-kit 已从 Maven Central 移除），
/// 仅保留命令构造接口，见 pubspec.yaml 说明。
class ExportService {
  const ExportService();

  /// 构造 FFmpeg 命令（骨架实现，参数串供调试与后续填充）。
  ///
  /// 真实渲染会在 `-filter_complex` 中注入逐帧的
  /// `zoompan`/`scale` + 平移表达式，此处仅给出编码参数。
  List<String> buildFfmpegCommand({
    required String inputPath,
    required String outputPath,
    ExportOptions options = const ExportOptions(),
  }) {
    final scaleFilter = switch (options.resolution) {
      '720p' => 'scale=-2:720',
      '4K' => 'scale=-2:2160',
      _ => 'scale=-2:1080',
    };
    final codec = options.codec == 'h265' ? 'libx265' : 'libx264';
    return [
      '-y',
      '-i',
      inputPath,
      '-vf',
      '$scaleFilter:flags=lanczos',
      '-r',
      '${options.frameRate}',
      '-c:v',
      codec,
      '-preset',
      'medium',
      '-crf',
      '20',
      '-pix_fmt',
      'yuv420p',
      outputPath,
    ];
  }
}
