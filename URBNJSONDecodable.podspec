Pod::Spec.new do |s|
  s.name             = 'URBNJSONDecodable'
  s.version          = '1.2'
  s.summary          = 'A swifty, lightweight, operator based approach to decoding JSON.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/urbn/URBNJSONDecodable'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'URBN Mobile Team' => 'mobileteam@urbn.com' }
  s.source           = { :git => 'https://github.com/urbn/URBNJSONDecodable.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'Pod/Classes/**/*'
end
