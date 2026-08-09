# 变焦动画相机（zoomlens）

一款面向普通用户的移动应用：通过屏幕层面的缩放动画技术，为照片和视频添加专业的变焦动画效果。支持拍摄素材、以**变焦点（Focal Point）**为锚点编辑变焦曲线、实时预览并导出带变焦效果的视频。

> 能力边界：不控制手机摄像头的真实光学/数码变焦参数，仅实现拍摄后的屏幕层面缩放动画处理。

## 项目结构

```
lib/
  main.dart                  # 入口
  app.dart                   # MaterialApp、深/浅色主题
  core/
    math/
      easing.dart            # 缓动函数（线性/缓入/缓出/缓入缓出/贝塞尔）
      zoom_transform.dart    # 以任意点为中心的缩放矩阵变换
    models/
      keyframe.dart          # 关键帧 { time, scale, easing, focalPoint }
      zoom_curve.dart        # 多关键帧变焦曲线（缩放 + 变焦点插值）
  features/
    capture/                 # 拍摄模块（权限、预览、拍照、录像）
    editor/                  # 曲线编辑器（时间轴、关键帧、变焦点标记）
    presets/                 # 效果预设库（电影推拉/呼吸变焦/冲击缩放/平滑拉远/心跳节奏）
    export/                  # 导出模块（分辨率/帧率/编码选择，FFmpeg）
    library/                 # 素材管理（历史记录、项目草稿）
    home/                    # 主页导航
test/                        # 单元测试（核心算法 + 冒烟测试）
.github/workflows/build.yml  # CI/CD 流水线（唯一构建平台）
docs/                        # 规划文档（见下）
```

## 构建与测试

遵循「不在本地构建」原则：所有构建统一在 GitHub Actions 完成（见 `.github/workflows/build.yml`）。

本地仅做静态检查与单测（需 Flutter SDK）：

```bash
flutter pub get
flutter analyze
flutter test
```

## 开发流程

1. 从 `develop` 切分支 → 提交代码 → 开 PR 到 `develop`（或 `main`）
2. CI 自动执行 lint + 单测 +（合入前）构建
3. 至少 1 人 review 通过，且所有 CI 检查通过后方可合并
4. 打 `v*` tag 触发正式构建与发布

## 规划文档

详见 `docs/development-plan.md`（开发规划文档修订版）。
