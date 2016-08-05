source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'
use_frameworks!

def shared_pods
  # Logging
  pod 'Log'

  # Code utilities
  pod 'SwiftyJSON'

  # UI
  pod 'SideMenu'

  # Database
  pod 'RealmSwift'

  # Network
  pod 'SDWebImage', '~> 3.8'
  pod 'Starscream', '~> 1.1.3'
end

target 'Rocket.Chat' do
  # Shared pods
  shared_pods
end

target 'Rocket.ChatTests' do
  # Shared pods
  shared_pods
end
