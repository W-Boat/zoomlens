import 'package:flutter/material.dart';

import '../capture/capture_screen.dart' show CaptureScreen;
import '../editor/editor_screen.dart' show EditorScreen;
import '../export/export_screen.dart' show ExportScreen;
import '../library/library_screen.dart' show LibraryScreen;
import '../presets/presets_screen.dart' show PresetsScreen;

/// 主页导航：底部 Tab 组织五大模块（拍摄 / 编辑 / 预设 / 导出 / 素材）。
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _screens = <Widget>[
    CaptureScreen(),
    EditorScreen(),
    PresetsScreen(),
    ExportScreen(),
    LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.videocam_outlined),
            selectedIcon: Icon(Icons.videocam),
            label: '拍摄',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: '编辑',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_filter_outlined),
            selectedIcon: Icon(Icons.movie_filter),
            label: '预设',
          ),
          NavigationDestination(
            icon: Icon(Icons.upload_outlined),
            selectedIcon: Icon(Icons.upload),
            label: '导出',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_library_outlined),
            selectedIcon: Icon(Icons.photo_library),
            label: '素材',
          ),
        ],
      ),
    );
  }
}
