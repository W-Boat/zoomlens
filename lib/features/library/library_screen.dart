import 'package:flutter/material.dart';

/// 素材管理界面（规划文档 2.5 节）。
///
/// 骨架：空态占位；后续迭代接入 LibraryService 展示历史记录、
/// 草稿恢复、批量导出、相册导入、删除/重命名。
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('素材库')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_library_outlined, size: 64),
            const SizedBox(height: 12),
            const Text('暂无素材'),
            const SizedBox(height: 4),
            Text(
              '拍摄或从相册导入素材后将显示在这里',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('从相册导入'),
            ),
          ],
        ),
      ),
    );
  }
}
