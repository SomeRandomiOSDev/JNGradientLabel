Pod::Spec.new do |s|
  
  s.name         = "JNGradientLabel"
  s.version      = "1.0.2"
  s.summary      = "A `UILabel` subclass with a gradient color"
  s.description  = <<-DESC
                   An iOS Swift framework that that provides a `UILabel` subclass that renders its text with a gradient color
                   DESC
  
  s.homepage     = "https://github.com/SomeRandomiOSDev/JNGradientLabel"
  s.license      = "MIT"
  s.author       = { "Joseph Newton" => "somerandomiosdev@gmail.com" }
  
  s.platform     = :ios, '8.0'
  s.source       = { :git => "https://github.com/SomeRandomiOSDev/JNGradientLabel.git", :tag => s.version.to_s }
  
  s.source_files  = 'JNGradientLabel/**/*.swift'
  s.frameworks    = 'UIKit', 'CoreGraphics'
  s.swift_version = '5.0'
  s.requires_arc  = true
  
end
