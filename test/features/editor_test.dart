import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zoomlens/app.dart';
import 'package:zoomlens/features/editor/zoom_curve_painter.dart'
    show ZoomCurvePainter;

/// 编辑器交互测试：关键帧添加/撤销/重做/删除、播放预览。
void main() {
  Future<void> pumpEditor(WidgetTester tester) async {
    await tester.pumpWidget(const ZoomLensApp());
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('编辑'),
      ),
    );
    await tester.pump();
  }

  /// 在曲线画布上以相对坐标（时间, 高度比）点击。
  Future<void> tapCurve(WidgetTester tester, double timeRatio, double yRatio) async {
    final canvas = find.byKey(const Key('zoom-curve-canvas'));
    final topLeft = tester.getTopLeft(canvas);
    final size = tester.getSize(canvas);
    await tester.tapAt(
      topLeft + Offset(size.width * timeRatio, size.height * yRatio),
    );
    await tester.pump();
  }

  /// 读取按钮当前是否可用。
  bool isEnabled(WidgetTester tester, IconData icon) {
    return tester
            .widget<IconButton>(find.widgetWithIcon(IconButton, icon))
            .onPressed !=
        null;
  }

  testWidgets('初始加载预设曲线并显示关键帧数量', (tester) async {
    await pumpEditor(tester);
    expect(find.text('变焦编辑'), findsOneWidget);
    // 电影推拉预设 = 2 个关键帧
    expect(find.text('2 帧'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.undo), findsOneWidget);
    expect(find.byIcon(Icons.redo), findsOneWidget);
    // 初始 undo / 删除均不可用
    expect(isEnabled(tester, Icons.undo), isFalse);
    expect(isEnabled(tester, Icons.delete_outline), isFalse);
  });

  testWidgets('点击曲线添加关键帧，撤销/重做生效', (tester) async {
    await pumpEditor(tester);

    await tapCurve(tester, 0.5, 0.4);
    expect(find.text('3 帧'), findsOneWidget);
    expect(isEnabled(tester, Icons.undo), isTrue);

    // 撤销 → 2 帧
    await tester.tap(find.byIcon(Icons.undo));
    await tester.pump();
    expect(find.text('2 帧'), findsOneWidget);
    expect(isEnabled(tester, Icons.redo), isTrue);

    // 重做 → 3 帧
    await tester.tap(find.byIcon(Icons.redo));
    await tester.pump();
    expect(find.text('3 帧'), findsOneWidget);
  });

  testWidgets('添加后选中并删除关键帧', (tester) async {
    await pumpEditor(tester);
    await tapCurve(tester, 0.5, 0.4);
    expect(find.text('3 帧'), findsOneWidget);

    // 新关键帧自动选中，删除按钮可用
    expect(isEnabled(tester, Icons.delete_outline), isTrue);
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();
    expect(find.text('2 帧'), findsOneWidget);
  });

  testWidgets('点击已有关键帧可选中', (tester) async {
    await pumpEditor(tester);
    final canvas = find.byKey(const Key('zoom-curve-canvas'));
    final topLeft = tester.getTopLeft(canvas);
    final size = tester.getSize(canvas);
    // 第一个关键帧 t=0, scale=1.0，用画板换算得到 y 坐标后精确点击
    final y = ZoomCurvePainter.yForScale(
      size,
      1.0,
      scaleMin: 0.5,
      scaleMax: 3.0,
    );
    await tester.tapAt(topLeft + Offset(0, y));
    await tester.pump();

    // 未新增关键帧
    expect(find.text('2 帧'), findsOneWidget);
    // 已选中 → 删除可用
    expect(isEnabled(tester, Icons.delete_outline), isTrue);
  });

  testWidgets('播放/暂停预览', (tester) async {
    await pumpEditor(tester);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    expect(find.byIcon(Icons.pause), findsOneWidget);

    // 播放中推进时间
    await tester.pump(const Duration(seconds: 1));
    expect(find.byIcon(Icons.pause), findsOneWidget);

    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('预设切换后关键帧数量随之变化', (tester) async {
    await pumpEditor(tester);
    expect(find.text('2 帧'), findsOneWidget);

    // 打开预设下拉并切到「心跳节奏」（5 个关键帧）
    await tester.tap(find.text('电影推拉'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('心跳节奏').last);
    await tester.pumpAndSettle();
    expect(find.text('5 帧'), findsOneWidget);
  });
}
