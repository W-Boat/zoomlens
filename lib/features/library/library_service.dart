import 'package:hive/hive.dart';

import '../../core/models/project_draft.dart' show ProjectDraft;

/// 素材/项目草稿存取服务（规划文档 2.5 节）。
///
/// 草稿以 ProjectDraft.toJson() 的 Map 形式存入 Hive box；
/// 支持保存、按时间倒序读取、删除。
class LibraryService {
  const LibraryService();

  static const _boxName = 'projects';

  Future<Box<dynamic>> _openBox() => Hive.openBox(_boxName);

  /// 保存项目草稿，返回生成的草稿 key。
  Future<int> saveDraft(ProjectDraft draft) async {
    final box = await _openBox();
    return box.add(draft.toJson());
  }

  /// 读取全部草稿（最近创建的在前）。
  Future<List<ProjectDraft>> listDrafts() async {
    final box = await _openBox();
    final raw = box.values.cast<Map<dynamic, dynamic>>().toList().reversed;
    return [
      for (final m in raw) ProjectDraft.fromJson(m.cast<String, dynamic>()),
    ];
  }

  /// 删除草稿。
  Future<void> deleteDraft(int key) async {
    final box = await _openBox();
    await box.delete(key);
  }
}
