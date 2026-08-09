import 'package:hive/hive.dart';

/// 素材/项目草稿存取服务（规划文档 2.5 节）。
///
/// 骨架：定义 Hive box 名称与存取接口。
/// 后续迭代：定义 ProjectDraft 模型（曲线 JSON、素材路径、缩略图、创建时间）
/// 并注册 Hive 适配器；支持批量导出、删除/重命名。
class LibraryService {
  const LibraryService();

  static const _boxName = 'projects';

  Future<Box<dynamic>> _openBox() => Hive.openBox(_boxName);

  /// 保存项目草稿，返回生成的草稿 key。
  Future<int> saveDraft(Map<String, dynamic> draft) async {
    final box = await _openBox();
    return box.add(draft);
  }

  /// 读取全部草稿（最近创建的在前）。
  Future<List<Map<dynamic, dynamic>>> listDrafts() async {
    final box = await _openBox();
    return box.values.toList().reversed.toList();
  }

  /// 删除草稿。
  Future<void> deleteDraft(int key) async {
    final box = await _openBox();
    await box.delete(key);
  }
}
