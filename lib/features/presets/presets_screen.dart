import 'package:flutter/material.dart';

import 'zoom_presets.dart' show zoomPresets;

/// 效果预设库（规划文档 2.3 节）。
///
/// 骨架：内置预设列表浏览与一键应用提示。
/// 后续迭代：分类筛选、参数微调、自定义预设保存、动态缩略图预览。
class PresetsScreen extends StatelessWidget {
  const PresetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('效果预设')),
      body: ListView.separated(
        itemCount: zoomPresets.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final preset = zoomPresets[index];
          return ListTile(
            leading: const Icon(Icons.movie_filter_outlined),
            title: Text('${preset.name} · ${preset.category}'),
            subtitle: Text(preset.description),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已选择预设「${preset.name}」')),
              );
            },
          );
        },
      ),
    );
  }
}
