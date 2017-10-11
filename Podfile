source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

def shared_pods
  # Crash Report
  pod 'Fabric'
  pod 'Crashlytics'

  # Code utilities
  pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git', :tag => '4.0.0-alpha.1'
  pod 'semver', :git => 'https://github.com/rafaelks/Semver.Swift.git', :branch => 'chore/swift4'

  # UI
  pod 'SideMenuController', :git => 'https://github.com/rafaelks/SideMenuController.git'
  pod 'SlackTextViewController', :path => '~/dev/RocketChat/SlackTextViewController'#:git => 'https://github.com/rafaelks/SlackTextViewController.git', :branch => 'chore/swift4_xcode9_ios11'
  pod 'MobilePlayer'
  pod 'SimpleImageViewer', :git => 'https://github.com/cardoso/SimpleImageViewer.git'

  # Text Processing
  pod 'RCMarkdownParser'

  # Database
  pod 'RealmSwift'

  # Network
  pod 'SDWebImage', '~> 3'
  pod 'Starscream', :git => 'https://github.com/daltoniam/Starscream.git', :branch => 'swift4'
  pod 'ReachabilitySwift', :git => 'https://github.com/ashleymills/Reachability.swift.git', :branch => 'develop'

  # Authentication SDKs
  pod '1PasswordExtension'
  pod 'Google/SignIn'
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
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.1'
    end
  end
end
