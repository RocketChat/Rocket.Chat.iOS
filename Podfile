source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.0'
use_frameworks!
inhibit_all_warnings!

def database_pods
  pod 'RealmSwift'
  pod 'SwiftyJSON'
end

def ui_pods
  pod 'MBProgressHUD', '~> 1.1.0'
end

def diff_pods
  pod 'DifferenceKit', '~> 1.0'
end

def shared_pods
  # Analytics
  pod 'Firebase/Core'

  # Crash Report
  pod 'Fabric'
  pod 'Crashlytics'

  # Code utilities
  pod 'semver'

  # UI
  pod 'RocketChatViewController', :git => 'https://github.com/RocketChat/RocketChatViewController'
  pod 'MobilePlayer', :git => 'https://github.com/RocketChat/RCiOSMobilePlayer'
  pod 'SimpleImageViewer', :git => 'https://github.com/cardoso/SimpleImageViewer.git'
  pod 'SwipeCellKit'
  ui_pods

  # Text Processing
  pod 'RCMarkdownParser', :git => 'https://github.com/RocketChat/RCMarkdownParser.git'

  # Database
  database_pods

  # Network
  pod 'Nuke', '~> 7.6'
  pod 'Nuke-FLAnimatedImage-Plugin'
  pod 'Starscream', '~> 3'
  pod 'ReachabilitySwift'

  # Authentication SDKs
  pod 'OAuthSwift'
  pod '1PasswordExtension'

  # Debugging
  pod 'SwiftLint', :configurations => ['Debug']
  pod 'FLEX', '~> 2.0', :configurations => ['Debug', 'Beta']
end

target 'Rocket.Chat.ShareExtension' do
  pod 'Nuke-FLAnimatedImage-Plugin'
  database_pods
  ui_pods
  diff_pods
end

target 'Rocket.Chat' do
  shared_pods
end

target 'Rocket.ChatTests' do
  shared_pods
end

post_install do |installer|
  swift42Targets = ['RCMarkdownParser', 'MobilePlayer']

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.1'
      config.build_settings['ENABLE_BITCODE'] = 'NO'

      if config.name == 'Debug'
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
      else
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
    end
    if swift42Targets.include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
      end
    end
  end
end

