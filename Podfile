source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'
use_frameworks!

def shared_pods
  # Code utilities
  pod 'SwiftyJSON'
  pod 'semver'

  # Database
  pod 'RealmSwift'

  # Network
  pod 'SDWebImage', '~> 3.8'
  pod 'Starscream', '~> 2.0.0'
end

def app_pods
  # Crash Report
  pod 'Fabric'
  pod 'Crashlytics'

  # UI
  pod 'SideMenuController', :git => 'https://github.com/rafaelks/SideMenuController.git'
  pod 'SlackTextViewController'
  pod 'MobilePlayer'
  pod 'URBMediaFocusViewController'

  # Text Processing
  pod 'TSMarkdownParser'

  # Authentication SDKs
  pod '1PasswordExtension'
  pod 'Google/SignIn'
end

target 'Rocket.Chat' do
  shared_pods
  app_pods
end

target 'Rocket.ChatTests' do
  shared_pods
  app_pods
end

target 'Rocket.ChatUITests' do

end

target 'Rocket.Chat.SDK' do
    shared_pods
end

target 'Rocket.Chat.SDKTests' do
    shared_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.1'
    end
  end
end
