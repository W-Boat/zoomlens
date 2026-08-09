import 'package:flutter/material.dart';

import 'features/home/home_screen.dart' show HomeScreen;

/// 应用根组件（规划文档 4 节：深色/浅色主题适配）。
class ZoomLensApp extends StatelessWidget {
  const ZoomLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '变焦动画相机',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
