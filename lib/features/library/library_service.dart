import 'package:hive/hive.dart';

import '../../core/models/project_draft.dart' show ProjectDraft;

/// 素材/项目草稿存取服务（规划文档 2.5 节）。
///
/// 草稿以 ProjectDraft.toJson() 的 Map 形式存入 Hive box；
/// 支持保存、按时间倒序读取、删除。
///
/// Hive 未初始化（如 widget 测试环境未调用 Hive.init）时：
/// 读取返回空列表、保存/删除直接跳过，避免向 UI 层抛 HiveError。
class LibraryService {
  const LibraryService();

  static const _boxName = 'projects';

  bool get _hiveReady => Hive.isInitialized;

  Future<Box<dynamic>> _openBox() => Hive.openBox(_boxName);

  /// 保存项目草稿，返回生成的草稿 key；Hive 未初始化时返回 -1。
  Future<int> saveDraft(ProjectDraft draft) async {
    if (!_hiveReady) return -1;
    final box = await _openBox();
    return box.add(draft.toJson());
  }

  /// 读取全部草稿（最近创建的在前），携带 Hive key 以便删除。
  /// Hive 未初始化时返回空列表。
  Future<List<MapEntry<int, ProjectDraft>>> listDrafts() async {
    if (!_hiveReady) return const [];
    final box = await _openBox();
    final entries = box.toMap().entries.toList().reversed;
    return [
      for (final e in entries)
        MapEntry(
          e.key as int,
          ProjectDraft.fromJson((e.value as Map).cast<String, dynamic>()),
        ),
    ];
  }

  /// 删除草稿；Hive 未初始化时为空操作。
  Future<void> deleteDraft(int key) async {
    if (!_hiveReady) return;
    final box = await _openBox();
    await box.delete(key);
  }
}
