source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

def shared_pods
  # Crash Report
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Instabug'

  # Code utilities
  pod 'SwiftyJSON'
  pod 'semver', :git => 'https://github.com/rafaelks/Semver.Swift.git', :branch => 'chore/swift4'

  # UI
  pod 'SideMenuController', :git => 'https://github.com/rafaelks/SideMenuController.git'
  pod 'SlackTextViewController', :git => 'https://github.com/rafaelks/SlackTextViewController.git'
  pod 'MobilePlayer'
  pod 'SimpleImageViewer', :git => 'https://github.com/cardoso/SimpleImageViewer.git'
  pod 'TagListView', '~> 1.0'
  pod 'SearchTextField'

  # Text Processing
  pod 'RCMarkdownParser', :git => 'https://github.com/RocketChat/RCMarkdownParser.git'

  # Database
  pod 'RealmSwift'

  # Network
  pod 'SDWebImage', '~> 4'
  pod 'SDWebImage/GIF'
  pod 'Starscream'
  pod 'ReachabilitySwift'

  # Authentication SDKs
  pod 'OAuthSwift'
  pod '1PasswordExtension'
  pod 'GoogleSignIn'

  # Debugging
  pod 'SwiftLint', :configurations => ['Debug']
  pod 'FLEX', '~> 2.0', :configurations => ['Debug', 'Beta']
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

