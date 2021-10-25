Pod::Spec.new do |s|
  
  s.name         = "JNGradientLabel"
  s.version      = "1.0.3"
  s.summary      = "An `UILabel` subclass with a gradient color"
  s.description  = <<-DESC
                   An iOS/tvOS Swift framework that that provides a `UILabel` subclass that renders its text with a gradient color
                   DESC
  
  s.homepage     = "https://github.com/SomeRandomiOSDev/JNGradientLabel"
  s.license      = "MIT"
  s.author       = { "Joe Newton" => "somerandomiosdev@gmail.com" }
  s.source       = { :git => "https://github.com/SomeRandomiOSDev/JNGradientLabel.git", :tag => s.version.to_s }

  s.ios.deployment_target  = '9.0'
  s.tvos.deployment_target = '9.0'

  s.source_files      = 'Sources/JNGradientLabel/*.swift'
  s.swift_versions    = ['5.0']
  s.cocoapods_version = '>= 1.7.3'
  
end
