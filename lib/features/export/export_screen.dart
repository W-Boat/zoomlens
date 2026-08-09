import 'package:flutter/material.dart';

/// 导出模块界面（规划文档 2.4 节）。
///
/// 骨架：分辨率/帧率/编码选择 + 导出进度占位。
/// 后续迭代：真实 FFmpeg 执行、后台导出、分享入口。
class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  static const _resolutions = ['720p', '1080p', '4K'];
  static const _frameRates = [24, 30, 60];
  static const _codecs = ['h264', 'h265'];

  String _resolution = '1080p';
  int _frameRate = 30;
  String _codec = 'h264';
  bool _exporting = false;
  double _progress = 0.0;

  void _startExport() {
    // 骨架：仅模拟进度；真实实现调用 ExportService + ffmpeg_kit
    setState(() {
      _exporting = true;
      _progress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('导出')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('分辨率'),
            trailing: DropdownButton<String>(
              value: _resolution,
              items: [
                for (final r in _resolutions)
                  DropdownMenuItem(value: r, child: Text(r)),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _resolution = v);
              },
            ),
          ),
          ListTile(
            title: const Text('帧率'),
            trailing: DropdownButton<int>(
              value: _frameRate,
              items: [
                for (final f in _frameRates)
                  DropdownMenuItem(value: f, child: Text('$f fps')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _frameRate = v);
              },
            ),
          ),
          ListTile(
            title: const Text('编码格式'),
            trailing: DropdownButton<String>(
              value: _codec,
              items: [
                for (final c in _codecs)
                  DropdownMenuItem(value: c, child: Text(c.toUpperCase())),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _codec = v);
              },
            ),
          ),
          const SizedBox(height: 16),
          if (_exporting) ...[
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 8),
            const Text('导出中…（骨架实现）'),
            const SizedBox(height: 16),
          ],
          FilledButton.icon(
            onPressed: _exporting ? null : _startExport,
            icon: const Icon(Icons.ios_share),
            label: const Text('开始导出'),
          ),
        ],
      ),
    );
  }
}
