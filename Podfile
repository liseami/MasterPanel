#_          * *      *                 *                      _
#| |__   ___| | |_   *| |*_   ___   ___ | | __  *_*   ___   **| |**_
#| '_ \ / * \ | | | | | '* \ / * \ / * \| |/ / | '_ \ / * \ / *` / __|
#| |_) |  __/ | | |_| | |_) | (_) | (_) |   <  | |_) | (_) | (_| \__ \
#|_.__/ \___|_|_|\__, |_.__/ \___/ \___/|_|\_\ | .__/ \___/ \__,_|___/
#               |___/                         |_|

# 设置最低部署目标
platform :ios, '16.0'

target 'DreamPaper' do
  # 基础配置
  use_frameworks!                # 强制使用动态库
  use_modular_headers!          # 开启 modular headers，支持 @import 导入
  
  # 网络相关
  pod 'Moya', '~> 15.0'         # 网络底层
  pod 'Moya/Combine', '~> 15.0' # 网络底层结合SwiftUI Combine
  
  # JSON 处理
  pod 'KakaJSON'               # JSON处理
  pod 'SwiftyJSON'             # JSON处理
  
  # UI 组件
  pod 'lottie-ios'             # JSON动画
  pod 'Kingfisher'             # Web图片
  pod 'SwiftUIIntrospect'      # SwiftUI 调试工具
  pod 'PanModal'               # Slack 开源弹窗
  pod 'Lantern'                # 照片详情
  pod 'JDStatusBarNotification'# 通知小弹窗
  pod 'SPAlert'                # 仿苹果的底部通知
  
  # 功能增强
  pod 'SwifterSwift'           # 语法糖
  pod 'Tagly'                  # 标签云
  
  # 已注释的可选组件
  # pod 'AliyunOSSiOS'         # 阿里云OSS
  # pod 'UMCommon'             # 友盟统计
  # pod 'UMDevice'             # 友盟设备信息
  # pod 'JCore'                # 极光推送core
  # pod 'JPush'                # 极光推送
  
  # 配置
  warn_for_unused_master_specs_repo = false
end

# 安装后配置
post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
        config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
      end
    end
  end
end
