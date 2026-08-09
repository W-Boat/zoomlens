import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:zoomlens/core/models/keyframe.dart';
import 'package:zoomlens/core/models/project_draft.dart';
import 'package:zoomlens/features/library/library_service.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('zoomlens_hive_test');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  ProjectDraft draft(String assetPath) => ProjectDraft(
        assetPath: assetPath,
        createdAt: DateTime(2026, 8, 9, 12, 30),
        keyframes: const [
          Keyframe(
            time: 0.0,
            scale: 1.0,
            easing: EasingType.linear,
            focalPoint: Offset(0.5, 0.5),
          ),
          Keyframe(
            time: 1.0,
            scale: 2.0,
            easing: EasingType.linear,
            focalPoint: Offset(0.5, 0.5),
          ),
        ],
      );

  test('保存/读取/删除草稿', () async {
    const service = LibraryService();

    final key = await service.saveDraft(draft('/tmp/a.jpg'));
    expect(key, isNonNegative);

    final list = await service.listDrafts();
    expect(list.length, 1);
    expect(list.first.key, key);
    expect(list.first.value.assetPath, '/tmp/a.jpg');
    expect(list.first.value.keyframes.length, 2);
    expect(list.first.value.toCurve().evaluateAt(0.5).scale, closeTo(1.5, 1e-9));

    await service.deleteDraft(key);
    expect(await service.listDrafts(), isEmpty);
  });

  test('多草稿按保存顺序倒序返回', () async {
    const service = LibraryService();

    await service.saveDraft(draft('/tmp/a.jpg'));
    await service.saveDraft(draft('/tmp/b.jpg'));

    final list = await service.listDrafts();
    expect(list.length, 2);
    // 后保存的在最前
    expect(list.first.value.assetPath, '/tmp/b.jpg');
    expect(list.last.value.assetPath, '/tmp/a.jpg');
  });
}
