import 'package:flutter/material.dart' show NavigationBar;
import 'package:flutter_test/flutter_test.dart';
import 'package:zoomlens/app.dart';

void main() {
  testWidgets('应用可正常启动并渲染五大模块', (tester) async {
    await tester.pumpWidget(const ZoomLensApp());

    // IndexedStack 仅将当前 tab 视为 onstage，其余页面需 skipOffstage: false
    expect(find.text('变焦编辑', skipOffstage: false), findsOneWidget); // 编辑页 AppBar
    expect(find.text('效果预设', skipOffstage: false), findsOneWidget); // 预设页 AppBar
    expect(find.text('相机预览（骨架）'), findsOneWidget); // 拍摄页（当前 tab）
    expect(find.text('素材预览（骨架）', skipOffstage: false), findsOneWidget); // 编辑页预览区
    expect(find.text('暂无素材', skipOffstage: false), findsOneWidget); // 素材页

    // 底部导航标签（始终 onstage）
    expect(find.text('拍摄'), findsNWidgets(2)); // 拍摄页 AppBar + 导航标签
    expect(find.text('编辑'), findsOneWidget);
    expect(find.text('预设'), findsOneWidget);
    expect(find.text('导出'), findsOneWidget); // 导出页 AppBar 处于 offstage
    expect(find.text('素材'), findsOneWidget);
  });

  testWidgets('切换到底部导航可正常渲染各页', (tester) async {
    await tester.pumpWidget(const ZoomLensApp());

    // 切到「预设」页（第 3 个 tab）
    await tester.tap(find.text('预设'));
    await tester.pumpAndSettle();
    expect(find.text('电影推拉 · 电影'), findsOneWidget);

    // 切到「导出」页（第 4 个 tab）
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('导出'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('开始导出'), findsOneWidget);
  });
}
