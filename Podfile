source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

def webimage_pods
  pod 'SDWebImage', '~> 4'
  pod 'SDWebImage/GIF'
end

def database_pods
  pod 'RealmSwift'
  pod 'SwiftyJSON'
end

def ui_pods
  pod 'MBProgressHUD', '~> 1.1.0'
end

def shared_pods
  # Crash Report
  pod 'Fabric'
  pod 'Crashlytics'

  # Code utilities
  pod 'semver'

  # UI
  pod 'SideMenuController', :git => 'https://github.com/rafaelks/SideMenuController.git'
  pod 'SlackTextViewController', :git => 'https://github.com/rafaelks/SlackTextViewController.git'
  pod 'MobilePlayer'
  pod 'SimpleImageViewer', :git => 'https://github.com/cardoso/SimpleImageViewer.git'
  pod 'TagListView', '~> 1.0'
  pod 'SearchTextField'
  ui_pods

  # Text Processing
  pod 'RCMarkdownParser', :git => 'https://github.com/RocketChat/RCMarkdownParser.git'

  # Database
  database_pods

  # Network
  webimage_pods
  pod 'Starscream', '~> 2'
  pod 'ReachabilitySwift'

  # Authentication SDKs
  pod 'OAuthSwift'
  pod '1PasswordExtension'

  # Debugging
  pod 'Instabug', :configurations => ['Debug', 'Beta']
  pod 'SwiftLint', :configurations => ['Debug']
  pod 'FLEX', '~> 2.0', :configurations => ['Debug', 'Beta']
end

target 'Rocket.Chat.ShareExtension' do
  webimage_pods
  database_pods
  ui_pods
end

target 'Rocket.Chat' do
  # Shared pods
  shared_pods
end

target 'Rocket.ChatTests' do
  # Shared pods
  shared_pods
end

post_install do |installer|
  swift4Targets = ['OAuthSwift', 'TagListView', 'SearchTextField']
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.1'
      if config.name == 'Debug'
        config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
    end
    if swift4Targets.include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.0'
      end
    end
  end
end

