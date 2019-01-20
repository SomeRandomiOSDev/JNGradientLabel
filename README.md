![Gradient Label](https://github.com/SomeRandomiOSDev/JNGradientLabel/blob/master/Images/JNGradientLabel.png)

# JNGradientLabel

An iOS [UILabel](https://developer.apple.com/documentation/uikit/uilabel) subclass that uses gradients as its text or background color.

[![Version](https://img.shields.io/cocoapods/v/JNGradientLabel.svg?style=flat)](https://cocoapods.org/pods/JNGradientLabel)
[![License](https://img.shields.io/cocoapods/l/JNGradientLabel.svg?style=flat)](https://cocoapods.org/pods/JNGradientLabel)
[![Platform](https://img.shields.io/cocoapods/p/JNGradientLabel.svg?style=flat)](https://cocoapods.org/pods/JNGradientLabel)

## Installation

JNGradientLabel is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'JNGradientLabel'
```

## Usage

First import JNGradientLabel at the top of your Swift file:

```swift
import JNGradientLabel
```

```objc
@import JNGradientLabel;
```

After initializing the label (from a Storyboard/XIB or manually) call one of following methods:

```swift
// To produce an `Axial` (Linear) gradient
label.setAxialGradientParameters(startPoint: startPoint,
                                   endPoint: endPoint,
                                     colors: gradientColors,
                                  locations: gradientlocations,
                                    options: ... /* Optional CGGradientDrawingOptions parameter */)
                                    
OR

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

```objc
// To produce an `Axial` (Linear) gradient
[label setAxialGradientParametersWithStartPoint:startPoint 
                                       endPoint:endPoint 
                                         colors:gradientColors 
                                      locations:gradientLocations
                                        options:gradientDrawingOptions];

OR

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

```swift
label.textGradientLocation = .background
```

```objc
label.textGradientLocation = TextGradientLocationBackground;

OR 

[label setTextGradientLocation:TextGradientLocationBackground];
```

## Screenshots

Foreground Axial Gradient:
![Foreground Axial Gradient](https://github.com/SomeRandomiOSDev/JNGradientLabel/blob/master/Images/ForegroundAxial.png)

Foreground Radial Gradient:
![Foreground Radial Gradient](https://github.com/SomeRandomiOSDev/JNGradientLabel/blob/master/Images/ForegroundRadial.png)

Background Axial Gradient:
![Background Axial Gradient](https://github.com/SomeRandomiOSDev/JNGradientLabel/blob/master/Images/BackgroundAxial.png)

Background Radial Gradient:
![Background Radial Gradient](https://github.com/SomeRandomiOSDev/JNGradientLabel/blob/master/Images/BackgroundRadial.png)

## Author

Joseph Newton, somerandomiosdev@gmail.com

## License

JNGradientLabel is available under the MIT license. See the LICENSE file for more info.
