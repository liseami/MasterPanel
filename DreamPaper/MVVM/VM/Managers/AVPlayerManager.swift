import AVFoundation
import SwiftUI

// MARK: - 音频播放管理器

/// 音频播放管理器
/// 负责处理音频播放的核心逻辑，包括播放、暂停、进度跟踪等功能
class AVPlayerManager: ObservableObject {
    /// 当前是否正在播放
    @Published var isPlaying = false
    /// 当前播放时间
    @Published var currentTime: TimeInterval = 0
    /// 音频总时长
    @Published var duration: TimeInterval = 0
    /// 自动循环播放模式
    @Published var autoRepeat : Bool = true
    
    /// AVPlayer实例，用于音频播放
    var player: AVPlayer?
    /// 音频会话，用于管理应用的音频行为
    private var audioSession: AVAudioSession?
    
    /// 设置音频会话
    /// 配置应用的音频行为，确保可以正常播放
    @MainActor
    private func setupAudioSession() async {
        do {
            audioSession = AVAudioSession.sharedInstance()
            try audioSession?.setCategory(.playback, mode: .default)
            try audioSession?.setActive(true)
        } catch {
            print("设置音频会话失败: \(error)")
        }
    }
    
    /// 设置播放器
    /// 根据提供的URL初始化播放器，并设置相关观察者
    @MainActor
    func setupPlayer(with url: URL) async {
        await setupAudioSession()
        
        let asset = AVAsset(url: url)
        
        do {
            // 检查音频文件是否可播放
            guard try await asset.load(.isPlayable) else {
                handleInvalidAudioFile()
                return
            }
            
            let playerItem = AVPlayerItem(asset: asset)
            player = AVPlayer(playerItem: playerItem)
            
            setupTimeObserver()
            setupNotificationObserver(for: playerItem)
            
            duration = try await asset.load(.duration).seconds
        } catch {
            handleInvalidAudioFile()
        }
    }
    
    /// 设置时间观察器
    /// 用于跟踪和更新当前播放时间
    private func setupTimeObserver() {
        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
    }
    
    /// 设置通知观察器
    /// 用于监听播放完成事件
    private func setupNotificationObserver(for playerItem: AVPlayerItem) {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak self] _ in
            self?.isPlaying = false
            self?.currentTime = 0
            self?.player?.seek(to: .zero)
        }
    }
    
    /// 切换播放/暂停状态
    func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            if currentTime >= duration {
                player?.seek(to: .zero)
            }
            player?.play()
        }
        isPlaying.toggle()
    }
    
    /// 处理无效音频文件
    /// 当音频文件无法播放时，显示错误消息并关闭当前视图
    @MainActor
    private func handleInvalidAudioFile() {
        Apphelper.shared.pushNotification(type: .error(message: "无效的音频文件。"))
        Apphelper.shared.closeSheet()
    }
}
