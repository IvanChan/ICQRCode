#
# Be sure to run `pod lib lint ICQRCode.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ICQRCode'
  s.version          = '1.0.0'
  s.summary          = 'QRCode scan & generate feature.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  QRCode scan & generate feature, base on system API.
                       DESC

  s.homepage         = 'https://github.com/IvanChan/ICQRCode'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '_ivanC' => '_ivanC'}
  s.source           = { :git => 'https://github.com/IvanChan/ICQRCode.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  
  s.source_files = 'ICQRCode/Classes/**/*'
  s.public_header_files = 'ICQRCode/Classes/**/*.h'

  # s.resource_bundles = {
  #   'ICQRCode' => ['ICQRCode/Assets/*.png']
  # }

  
  s.frameworks = 'UIKit', 'MobileCoreServices'
  # s.dependency 'AFNetworking', '~> 2.3'
end
