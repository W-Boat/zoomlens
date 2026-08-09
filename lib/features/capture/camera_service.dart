/// 拍摄模块服务抽象（规划文档 2.1 节）。
///
/// 真实实现基于 `camera` 插件（Android 端 CameraX / iOS 端 AVFoundation）。
/// 本骨架仅定义稳定接口，平台实现待后续迭代补充（构建在 CI 完成）。
abstract class CameraService {
  /// 申请相机权限并返回是否授权。
  Future<bool> requestPermission();

  /// 初始化相机（前后摄像头）。
  Future<void> initialize({bool useFrontCamera = false});

  /// 释放相机资源（内存/句柄检查点）。
  Future<void> dispose();

  /// 预览缩放：仅影响取景构图，不改变实际光学变焦。
  /// 实现时通过矩阵变换作用于预览层（见 core/math/zoom_transform.dart）。
  void setPreviewZoom(double scale);

  /// 拍照，返回原始分辨率照片文件路径（不应用任何实时滤镜）。
  Future<String> takePhoto();

  /// 开始录像，返回视频文件路径。
  Future<String> startRecording();

  /// 停止录像。
  Future<void> stopRecording();

  /// 前后摄像头切换。
  Future<void> toggleCamera();

  /// 闪光灯模式（off/auto/on/torch）。
  Future<void> setFlashMode(String mode);
}
