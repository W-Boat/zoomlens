import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/models/project_draft.dart' show ProjectDraft;
import 'library_service.dart' show LibraryService;

/// 素材管理界面（规划文档 2.5 节）。
///
/// 展示本地草稿列表（素材缩略图、关键帧数、创建时间），支持删除与刷新。
/// 草稿恢复（回到编辑器继续编辑）待跨页状态接入后提供。
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  static const _service = LibraryService();

  List<MapEntry<int, ProjectDraft>> _drafts = const [];
  bool _loading = true;
  bool _available = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _available = true;
    });
    try {
      final drafts = await _service.listDrafts();
      if (!mounted) return;
      setState(() {
        _drafts = drafts;
        _loading = false;
      });
    } catch (_) {
      // Hive 未初始化等环境问题：落到空态并给出提示
      if (!mounted) return;
      setState(() {
        _loading = false;
        _available = false;
        _drafts = const [];
      });
    }
  }

  Future<void> _delete(int key) async {
    try {
      await _service.deleteDraft(key);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('草稿已删除')),
      );
      await _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('删除失败')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('素材库'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: Text('加载中…'));
    }
    if (_drafts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_library_outlined, size: 64),
            const SizedBox(height: 12),
            const Text('暂无素材'),
            const SizedBox(height: 4),
            Text(
              _available
                  ? '在编辑页选择图片并保存后，草稿会显示在这里'
                  : '素材库暂不可用，请重试',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      itemCount: _drafts.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = _drafts[index];
        final draft = entry.value;
        return ListTile(
          leading: SizedBox(
            width: 56,
            height: 56,
            child: Image.file(
              File(draft.assetPath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                color: Colors.black12,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
          title: Text(_formatTime(draft.createdAt)),
          subtitle: Text(
            '关键帧 ${draft.keyframes.length} 个 · ${draft.assetPath}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '删除草稿',
            onPressed: () => _delete(entry.key),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime t) {
    final local = t.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}
