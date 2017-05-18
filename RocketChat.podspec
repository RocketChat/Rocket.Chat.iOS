Pod::Spec.new do |s|
  s.name     = 'RocketChat'
  s.version  = '0.1.0'
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = 'The ultimate Free Open Source Solution for team communications.'
  s.homepage = 'https://github.com/RocketChat/Rocket.Chat.iOS'
  s.author   = { 'Lucas Woo' => 'legendecas@gmail.com', 'Rafael Kellermann Streit' => 'rafaelks@me.com' }
  s.source   = { :git => 'https://github.com/RocketChat/Rocket.Chat.iOS.git', :tag => "v#{s.version.to_s}" }

  s.description = <<-DESC
TODO: Add long description of the pod here.
                  DESC

  s.public_header_files = 'Rocket.Chat.SDK/Rocket.Chat.SDK.h'
  s.source_files = 'Rocket.Chat.{SDK,Shared}/**/*.swift'
  s.resource_bundles = {
    'RocketChat' => ['Rocket.Chat.{SDK,Shared}/**/*.{storyboard,xib}'],
  }

  s.frameworks = 'UIKit'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'

  # Code utilities
  s.dependency 'SwiftyJSON'
  s.dependency 'semver'

  # Database
  s.dependency 'RealmSwift'

  # Network
  s.dependency 'SDWebImage', '~> 3.8'
  s.dependency 'Starscream', '~> 2.0.0'

  # UI
  s.dependency 'SlackTextViewController'
  s.dependency 'MobilePlayer'
  s.dependency 'URBMediaFocusViewController'

  # Text Processing
  s.dependency 'TSMarkdownParser'

end
