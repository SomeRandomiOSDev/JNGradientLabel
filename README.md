![Gradient Label](https://github.com/SomeRandomiOSDev/JNGradientLabel/blob/master/Images/JNGradientLabel.png)

JNGradientLabel
--------

An iOS [UILabel](https://developer.apple.com/documentation/uikit/uilabel) subclass that uses gradients as its text or background color.

[![License MIT](https://img.shields.io/cocoapods/l/JNGradientLabel.svg)](https://cocoapods.org/pods/JNGradientLabel)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/JNGradientLabel.svg)](https://cocoapods.org/pods/JNGradientLabel) 
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 
[![Platform](https://img.shields.io/cocoapods/p/JNGradientLabel.svg)](https://cocoapods.org/pods/JNGradientLabel)
[![Build](https://travis-ci.com/SomeRandomiOSDev/JNGradientLabel.svg?branch=master)](https://travis-ci.com/SomeRandomiOSDev/JNGradientLabel)
[![Codacy](https://api.codacy.com/project/badge/Grade/fda23fa315f043cf8b5ad9460f1de61f)](https://www.codacy.com/app/SomeRandomiOSDev/JNGradientLabel?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=SomeRandomiOSDev/JNGradientLabel&amp;utm_campaign=Badge_Grade)

Installation
--------

**JNGradientLabel**is available through [CocoaPods](https://cocoapods.org) and [Carthage](https://github.com/Carthage/Carthage). 

To install via CocoaPods, simply add the following line to your Podfile:

```ruby
pod 'JNGradientLabel'
```

To install via Carthage, simply add the following line to your Cartfile:

```ruby
github "SomeRandomiOSDev/JNGradientLabel"
```

Usage
--------

First import JNGradientLabel at the top of your source file:

Swift:

```swift
import JNGradientLabel
```

Objective-C:

```objc
@import JNGradientLabel;
```

After initializing the label (from a Storyboard/XIB or manually) call one of following methods:

Swift: 

```swift
// To produce an `Axial` (Linear) gradient
label.setAxialGradientParameters(startPoint: startPoint,
                                   endPoint: endPoint,
                                     colors: gradientColors,
                                  locations: gradientlocations,
                                    options: ... /* Optional CGGradientDrawingOptions parameter */)
```

OR

```swift
// To produce a `Radial` gradient
label.setRadialGradientParameters(startCenter: startCenter,
                                  startRadius: startRadius,
                                    endCenter: endCenter,
                                    endRadius: endRadius,
                                       colors: gradientColors,
                                    locations: gradientlocations,
                             radiiScalingRule: ... /* Optional RadialGradientRadiiScalingRule parameter */,
                                      options: ... /* Optional CGGradientDrawingOptions parameter */)
```

Objective-C:

```objc
// To produce an `Axial` (Linear) gradient
[label setAxialGradientParametersWithStartPoint:startPoint 
                                       endPoint:endPoint 
                                         colors:gradientColors 
                                      locations:gradientLocations
                                        options:gradientDrawingOptions];
```

OR

```objc
// To produce a `Radial` gradient
[label setRadialGradientParametersWithStartCenter:startCenter 
                                      startRadius:startRadius 
                                        endCenter:endCenter 
                                        endRadius:endRadius 
                                           colors:gradientColors 
                                        locations:gradientLocations 
                                 radiiScalingRule:radiiScalingRule 
                                          options:gradientDrawingOptions];
```

And thats it!

By default, the label draws the gradient as the color of the text. The label also supports drawing the gradient as the background of the text. To do this, simply set the `textGradientLocation` property as follows:

Swift: 

```swift
label.textGradientLocation = .background
```

Objective-C:

```objc
label.textGradientLocation = TextGradientLocationBackground;
```

OR 

```objc
[label setTextGradientLocation:TextGradientLocationBackground];
```

Screenshots
--------

Foreground Axial Gradient:
![Foreground Axial Gradient](https://github.com/SomeRandomiOSDev/JNGradientLabel/blob/master/Images/ForegroundAxial.png)

Foreground Radial Gradient:
![Foreground Radial Gradient](https://github.com/SomeRandomiOSDev/JNGradientLabel/blob/master/Images/ForegroundRadial.png)

Background Axial Gradient:
![Background Axial Gradient](https://github.com/SomeRandomiOSDev/JNGradientLabel/blob/master/Images/BackgroundAxial.png)

Background Radial Gradient:
![Background Radial Gradient](https://github.com/SomeRandomiOSDev/JNGradientLabel/blob/master/Images/BackgroundRadial.png)

Contributing
--------

If you have need for a specific feature or you encounter a bug, please open an issue. If you extend the functionality of **JNGradientLabel** yourself or you feel like fixing a bug yoruself, please submit a pull request.

Author
--------

Joseph Newton, somerandomiosdev@gmail.com

License
--------

**JNGradientLabel** is available under the MIT license. See the LICENSE file for more info.
