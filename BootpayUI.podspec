#
# Be sure to run `pod lib lint BootpayUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BootpayUI'
  s.version          = '4.1.7'
  s.summary          = 'Bootpay에서 지원하는 공식 SwiftUI 및 생체인증 결제 라이브러리 입니다. ios 14 이상부터 사용가능합니다.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/bootpay/ios_swiftui'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'bootpay' => 'bootpay.co.kr@gmail.com' }
  s.source           = { :git => 'https://github.com/bootpay/ios_swiftui.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '14.0'

  s.source_files = 'BootpayUI/Classes/**/*'
  
   s.resource_bundles = {
     'BootpayUI' => ['BootpayUI/*.xcassets']
   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  
  s.static_framework = true
  s.dependency 'Bootpay', '~> 4.1.6'
  s.dependency 'SCLAlertView'
  s.dependency 'CryptoSwift'
  s.dependency 'Alamofire'
  s.dependency 'ObjectMapper'
#  pod 'SwiftOTP',  '~> 3.0.0'
  s.dependency 'SnapKit'
  s.dependency 'JGProgressHUD'
  s.dependency 'SwiftyJSON'
  
end
