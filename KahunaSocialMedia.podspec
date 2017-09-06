#
# Be sure to run `pod lib lint KahunaSocialMedia.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KahunaSocialMedia'
  s.version          = '0.1.15'
  s.summary          = 'KahunaSocialMedia helps to retrieve twitter, facebook, instagram and youtube data from server'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
KahunaSocialMedia helps to retrieve twitter, facebook, instagram and youtube data from server. It can be configured with a paramters.
                       DESC

  s.homepage         = 'https://github.com/siddharthchopra/KahunaSocialMedia'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'siddharthchopra' => 'siddharth.chopra@kahunasystems.com' }
  s.source           = { :git => 'https://github.com/siddharthchopra/KahunaSocialMedia.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'KahunaSocialMedia/Classes/**/*'
  
  # s.resource_bundles = {
  #   'KahunaSocialMedia' => ['KahunaSocialMedia/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SQLite.swift', '~> 0.10.1'
  s.pod_target_xcconfig = {
    'SWIFT_VERSION' => '2.3',
  }
end
