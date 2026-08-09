import 'package:flutter/material.dart';

/// 拍摄模块界面（规划文档 2.1 节）。
///
/// 骨架阶段仅提供界面占位；相机初始化、预览矩阵缩放、拍照/录像
/// 将在接入 `camera` 插件后于 [CameraService] 中实现。
///
/// 注意：此处不在初始化阶段自动启动相机，避免无设备环境下
/// Widget 测试因插件缺失而失败。
class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bodySmall = Theme.of(context).textTheme.bodySmall;
    return Scaffold(
      appBar: AppBar(title: const Text('拍摄')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_outlined, size: 64),
            const SizedBox(height: 12),
            const Text('相机预览（骨架）'),
            const SizedBox(height: 4),
            Text('双指捏合/滑块控制预览缩放，仅影响取景构图', style: bodySmall),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt),
              label: const Text('拍照'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.fiber_manual_record),
              label: const Text('录像'),
            ),
          ],
        ),
      ),
    );
  }
}
