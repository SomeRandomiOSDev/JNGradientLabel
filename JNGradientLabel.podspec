#
#  Be sure to run `pod spec lint JNGradientLabel.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  
  s.name         = "JNGradientLabel"
  s.version      = "1.0.0"
  s.summary      = "A `UILabel` subclass with a gradient color"
  s.description  = <<-DESC
                   An iOS Swift framework that that provides a `UILabel` subclass that renders its text with a gradient color
                   DESC
  
  s.homepage     = "https://github.com/SomeRandomiOSDev/JNGradientLabel"
  s.license      = "MIT"
  s.author       = { "Joseph Newton" => "somerandomiosdev@gmail.com" }
  
  s.platform     = :ios, '8.0'
  s.source       = { :git => "https://github.com/SomeRandomiOSDev/JNGradientLabel.git", :tag => s.version.to_s }
  
  s.source_files  = 'JNGradientLabel/Classes/**/*'
  s.frameworks    = 'UIKit', 'CoreGraphics'
  s.swift_version = '4.0'
  s.requires_arc  = true
  
end
