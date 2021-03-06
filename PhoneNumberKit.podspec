#
# Be sure to run `pod lib lint PhoneNumberKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PhoneNumberKit'
  s.version          = '2.5.5'
  s.summary          = 'Swift framework for working with phone numbers (Forked)'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
                        A forked Swift framework for parsing, formatting and validating international phone numbers. Inspired by Google's libphonenumber.
                       DESC

  s.homepage         = 'https://github.com/oskarirauta/PhoneNumberKit'
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = {
			'Roy Marmelstein' => 'marmelroy@gmail.com',
			'Oskari Rauta' => 'oskari.rauta@gmail.com'
			}
  s.source           = { :git => 'https://github.com/oskarirauta/PhoneNumberKit.git', :tag => s.version.to_s }

  s.requires_arc = true
  s.dependency 'CommonKit'

  s.ios.frameworks = 'CoreTelephony'
  s.swift_version = '5.0'
  s.ios.deployment_target = '13.2'

  #s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }
  s.source_files	= [
			'PhoneNumberKit/*.{swift}',
			'PhoneNumberKit/UI/*.{swift}'
			]
  s.resources		= 'PhoneNumberKit/Resources/PhoneNumberMetadata.json'

end
