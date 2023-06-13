#
# Be sure to run `pod lib lint JUNRouter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JUNRouter'
  s.version          = '0.4.0'
  s.summary          = 'A simple intra-application routing framework.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A simple intra-application routing framework.
                       DESC

  s.homepage         = 'https://github.com/Jun2786184671/JUNRouter'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jun Ma' => 'maxinchun5@gmail.com' }
  s.source           = { :git => 'git@github.com:Jun2786184671/JUNRouter.git', :tag => s.version.to_s }
  s.social_media_url = 'https://t.me/JunMa5'

  s.ios.deployment_target = '9.0'

  s.source_files = 'JUNRouter/Classes/**/*.{h,m}'
  
  # s.resource_bundles = {
  #   'JUNRouter' => ['JUNRouter/Assets/*.png']
  # }

  s.public_header_files = 'JUNRouter/Classes/JUNRouteExpress.h'
  s.frameworks = 'Foundation', 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
