//
//  JNGradientLabel.swift
//  JNGradientLabel
//
//  Created by Joseph Newton on 1/9/19.
//  Copyright © 2019 Joseph Newton. All rights reserved.
//

import UIKit
import CoreGraphics

//MARK: - Enum (TextGradientLocation) Definition

/// An enum that describes how a gradient should be drawn in relation to the text
@objc public enum TextGradientLocation: Int {
    
    //MARK: - Public Cases
    
    /// The gradient should be drawn as the color of the text. The `textColor` property of the label and any text color specified as attributes on `attributedText` are ignored.
    case foreground = 0
    
    /// The gradient should be drawn as the background color of the text. The `backgroundColor` property of the label is ignored.
    case background = 1
    
    //MARK: - Private Constants
    
    fileprivate static let `default` = TextGradientLocation.foreground
}

//MARK: - Enum (RadialGradientRadiiScalingRule) Definition

/// An enum that describes how the radial gradient radius should be scaled when drawing
@objc public enum RadialGradientRadiiScalingRule: Int {
    
    //MARK: - Public Cases
    
    /// When scaling, the radial gradient radius should be multiplied by the current width of the label. `scaledRadius = radius * width`
    case width        = 0
    
    /// When scaling, the radial gradient radius should be multiplied by the current height of the label. `scaledRadius = radius * height`
    case height       = 1
    
    /// When scaling, the radial gradient radius should be multiplied by the smaller of the width and the height of the label. `scaledRadius = radius * min(width, height)`
    case minimumBound = 2
    
    /// When scaling, the radial gradient radius should be multiplied by the larger of the width and the height of the label. `scaledRadius = radius * max(width, height)`
    case maximumBound = 3
    
    //MARK: - Private Constants
    
    fileprivate static let `default` = RadialGradientRadiiScalingRule.maximumBound
}

//MARK: - Class (JNGradientLabel) Definition

public class JNGradientLabel: UILabel {
    
    //MARK: - Private Types
    
    private enum GradientType: Codable {
        
        //MARK: - Public Cases
        
        case axial(startPoint: CGPoint, endPoint: CGPoint)
        case radial(startCenter: CGPoint, startRadius: CGFloat, endCenter: CGPoint, endRadius: CGFloat, radiiScalingRule: RadialGradientRadiiScalingRule)
        
        //MARK: - Private Types
        
        private enum CodingKeys: String, CodingKey {
            
            // Axial/Radial
            case type
            case startPoint
            case endPoint
            
            // Radial
            case startRadius
            case endRadius
            case radiiScalingRule
        }
        
        //MARK: - Encodable Protcol Requirements
        
        func encode(to encoder: Encoder) throws {
            switch self {
            case let .axial(startPoint, endPoint):
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(0, forKey: .type)
                try container.encode(startPoint, forKey: .startPoint)
                try container.encode(endPoint, forKey: .endPoint)
                
            case let .radial(startCenter, startRadius, endCenter, endRadius, radiiScalingRule):
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(0, forKey: .type)
                try container.encode(startCenter, forKey: .startPoint)
                try container.encode(startRadius, forKey: .startRadius)
                try container.encode(endCenter, forKey: .endPoint)
                try container.encode(endRadius, forKey: .endRadius)
                try container.encode(radiiScalingRule.rawValue, forKey: .radiiScalingRule)
            }
        }
        
        //MARK: - Decodable Protocol Requirements
        
        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            switch try values.decode(Int.self, forKey: .type) {
            case 0: // Axial
                self = .axial(startPoint: try values.decode(CGPoint.self, forKey: .startPoint),
                                endPoint: try values.decode(CGPoint.self, forKey: .endPoint))
                
            case 1: // Radial
                self = .radial(startCenter: try values.decode(CGPoint.self, forKey: .startPoint),
                               startRadius: try values.decode(CGFloat.self, forKey: .startRadius),
                                 endCenter: try values.decode(CGPoint.self, forKey: .endPoint),
                                 endRadius: try values.decode(CGFloat.self, forKey: .endRadius),
                          radiiScalingRule: RadialGradientRadiiScalingRule(rawValue: try values.decode(Int.self, forKey: .radiiScalingRule)) ?? .default)
                
            default:
                fatalError()
            }
        }
    }
    
    private enum EncodingKeys: String {
        
        //MARK: - Cases
        
        case gradientType
        case gradientColors
        case gradientLocations
        case gradientOptions
        case textGradientLocation
    }
    
    //MARK: - Private Constants
    
    private static let defaultGradientDrawingOptions = CGGradientDrawingOptions(rawValue: 0)
    
    //MARK: - Private Properties
    
    private var gradientType: GradientType?
    private var textImage: UIImage?

    //MARK: - Public Properties
    
    /// The colors to be used when drawing the gradient
    @objc open var gradientColors: [UIColor]? = nil {
        didSet {
            if oldValue != gradientColors {
                super.setNeedsDisplay()
            }
        }
    }
    
    /// The locations of the gradient colors specified in 'gradientColors'
    @objc open var gradientLocations: [NSNumber]? = nil {
        didSet {
            if oldValue != gradientLocations {
                super.setNeedsDisplay()
            }
        }
    }
    
    /// The drawing options used when drawing the gradient
    @objc open var gradientOptions: CGGradientDrawingOptions = JNGradientLabel.defaultGradientDrawingOptions {
        didSet {
            if oldValue != gradientOptions {
                super.setNeedsDisplay()
            }
        }
    }
    
    /// The gradient location
    @objc open var textGradientLocation: TextGradientLocation = .default {
        didSet {
            if oldValue != textGradientLocation {
                super.setNeedsDisplay()
            }
        }
    }
    
    //MARK: - Initialization
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if let data = aDecoder.decodeObject(of: NSData.self, forKey: EncodingKeys.gradientType.rawValue) {
           let type = try? JSONDecoder().decode(GradientType.self, from: data as Data)
            gradientType = type
        }
        if let colors = aDecoder.decodeObject(of: NSArray.self, forKey: EncodingKeys.gradientColors.rawValue) {
            gradientColors = (colors as Array).compactMap({ $0 as? UIColor })
        }
        if let locations = aDecoder.decodeObject(of: NSArray.self, forKey: EncodingKeys.gradientLocations.rawValue) {
            gradientLocations = (locations as Array).compactMap({ $0 as? NSNumber })
        }
        
        gradientOptions      = CGGradientDrawingOptions(rawValue: UInt32(bitPattern: aDecoder.decodeInt32(forKey: EncodingKeys.gradientOptions.rawValue)))
        textGradientLocation = TextGradientLocation(rawValue: aDecoder.decodeInteger(forKey: EncodingKeys.textGradientLocation.rawValue)) ?? .default
    }
    
    //MARK: - NSCoding Methods
    
    override open func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        
        if let type = gradientType,
           let data = try? JSONEncoder().encode(type) {
            aCoder.encode(data, forKey: EncodingKeys.gradientType.rawValue)
        }
        if let colors = gradientColors {
            aCoder.encode(colors as NSArray, forKey: EncodingKeys.gradientColors.rawValue)
        }
        if let locations = gradientLocations {
            aCoder.encode(locations as NSArray, forKey: EncodingKeys.gradientLocations.rawValue)
        }
        
        aCoder.encode(Int32(bitPattern: gradientOptions.rawValue), forKey: EncodingKeys.gradientOptions.rawValue)
        aCoder.encode(textGradientLocation.rawValue, forKey: EncodingKeys.textGradientLocation.rawValue)
    }
    
    //MARK: - Public Methods
    
    /// Sets the gradient type to `axial` (also known as linear) and sets the start and end points, and optionally the gradient colors and locations.
    ///
    /// - parameter startPoint: The start point of the gradient with (0.0, 0.0) and (1.0, 1.0) representing the top-left and bottom-right corners of the label, respectively. Points whose coordinates lie outside of this range will be clamped
    /// - parameter endPoint: The end point of the gradient with (0.0, 0.0) and (1.0, 1.0) representing the top-left and bottom-right corners of the label, respectively. Points whose coordinates lie outside of this range will be clamped
    /// - parameter colors: The colors of the gradient
    /// - parameter locations: The locations of the gradient colors
    /// - parameter options: The gradient drawing options.
    @objc open func setAxialGradientParameters(startPoint: CGPoint, endPoint: CGPoint, colors: [UIColor]? = nil, locations: [NSNumber]? = nil, options: CGGradientDrawingOptions) {
        gradientOptions = options
        gradientType    = .axial(startPoint: startPoint.clamped(min: 0.0, max: 1.0),
                                   endPoint: endPoint.clamped(min: 0.0, max: 1.0))
        
        if let colors    = colors    { gradientColors    = colors }
        if let locations = locations { gradientLocations = locations }
        
        super.setNeedsDisplay()
    }
    
    /// Sets the gradient type to `axial` (also known as linear) and sets the start and end points, and optionally the gradient colors and locations.
    ///
    /// - parameter startPoint: The start point of the gradient with (0.0, 0.0) and (1.0, 1.0) representing the top-left and bottom-right corners of the label, respectively. Points whose coordinates lie outside of this range will be clamped
    /// - parameter endPoint: The end point of the gradient with (0.0, 0.0) and (1.0, 1.0) representing the top-left and bottom-right corners of the label, respectively. Points whose coordinates lie outside of this range will be clamped
    /// - parameter colors: The colors of the gradient
    /// - parameter locations: The locations of the gradient colors
    /// - parameter options: The gradient drawing options. If unspecified, this defaults to a null option set
    @nonobjc open func setAxialGradientParameters(startPoint: CGPoint, endPoint: CGPoint, colors: [UIColor]? = nil, locations: [CGFloat]? = nil, options: CGGradientDrawingOptions? = nil) {
        setAxialGradientParameters(startPoint: startPoint,
                                     endPoint: endPoint,
                                       colors: colors,
                                    locations: locations?.map({ NSNumber(value: Double($0)) }),
                                      options: options ?? JNGradientLabel.defaultGradientDrawingOptions)
    }
    
    
    
    
    /// Sets the gradient type to `radial` and sets the start and end cneter points, the start and end radii, and optionally the gradient colors and locations.
    ///
    /// - parameter startCenter: The start center of the gradient with (0.0, 0.0) and (1.0, 1.0) representing the top-left and bottom-right corners of the label, respectively. Points whose coordinates lie outside of this range will be clamped
    /// - parameter startRadius: The start radius of the gradient. The expected range of this value is [0.0, 1.0] and any value outside of this range will be clamped.
    /// - parameter endCenter: The end center of the gradient with (0.0, 0.0) and (1.0, 1.0) representing the top-left and bottom-right corners of the label, respectively. Points whose coordinates lie outside of this range will be clamped
    /// - parameter endRadius: The end radius of the gradient. The expected range of this value is [0.0, 1.0] and any value outside of this range will be clamped.
    /// - parameter radiusScalingRule: The rule to use when scaling up the radii from their [0.0, 1.0] range to the coordinate space of the label.
    /// - parameter colors: The colors of the gradient
    /// - parameter locations: The locations of the gradient colors
    /// - parameter options: The gradient drawing options.
    @objc open func setRadialGradientParameters(startCenter: CGPoint,
                                                startRadius: CGFloat,
                                                  endCenter: CGPoint,
                                                  endRadius: CGFloat,
                                                     colors: [UIColor]? = nil,
                                                  locations: [NSNumber]? = nil,
                                           radiiScalingRule: RadialGradientRadiiScalingRule,
                                                    options: CGGradientDrawingOptions) {
        gradientOptions = options
        gradientType    = .radial(startCenter: startCenter.clamped(min: 0.0, max: 1.0),
                                  startRadius: startRadius,
                                    endCenter: endCenter.clamped(min: 0.0, max: 1.0),
                                    endRadius: endRadius,
                             radiiScalingRule: radiiScalingRule)
        
        if let colors    = colors    { gradientColors    = colors }
        if let locations = locations { gradientLocations = locations }
        
        super.setNeedsDisplay()
    }
    
    /// Sets the gradient type to `radial` and sets the start and end cneter points, the start and end radii, and optionally the gradient colors and locations.
    ///
    /// - parameter startCenter: The start center of the gradient with (0.0, 0.0) and (1.0, 1.0) representing the top-left and bottom-right corners of the label, respectively. Points whose coordinates lie outside of this range will be clamped
    /// - parameter startRadius: The start radius of the gradient. The expected range of this value is [0.0, 1.0] and any value outside of this range will be clamped.
    /// - parameter endCenter: The end center of the gradient with (0.0, 0.0) and (1.0, 1.0) representing the top-left and bottom-right corners of the label, respectively. Points whose coordinates lie outside of this range will be clamped
    /// - parameter endRadius: The end radius of the gradient. The expected range of this value is [0.0, 1.0] and any value outside of this range will be clamped.
    /// - parameter radiusScalingRule: The rule to use when scaling up the radii from their [0.0, 1.0] range to the coordinate space of the label. If unspecified, this defaults to `maximumBound`
    /// - parameter colors: The colors of the gradient
    /// - parameter locations: The locations of the gradient colors
    /// - parameter options: The gradient drawing options. If unspecified, this defaults to a null option set
    @nonobjc open func setRadialGradientParameters(startCenter: CGPoint,
                                                   startRadius: CGFloat,
                                                     endCenter: CGPoint,
                                                     endRadius: CGFloat,
                                                        colors: [UIColor]? = nil,
                                                     locations: [CGFloat]? = nil,
                                              radiiScalingRule: RadialGradientRadiiScalingRule? = nil,
                                                       options: CGGradientDrawingOptions? = nil) {
        setRadialGradientParameters(startCenter: startCenter,
                                    startRadius: startRadius,
                                      endCenter: endCenter,
                                      endRadius: endRadius,
                                         colors: colors,
                                      locations: locations?.map({ NSNumber(value: Double($0)) }),
                               radiiScalingRule: radiiScalingRule ?? .default,
                                        options: options ?? JNGradientLabel.defaultGradientDrawingOptions)
    }
    
    
    
    @objc open func clearGradientParameters() {
        gradientType      = nil
        gradientColors    = nil
        gradientLocations = nil
        gradientOptions   = JNGradientLabel.defaultGradientDrawingOptions
        
        super.setNeedsDisplay()
    }
    
    //MARK: - UIView Overrides
    
    override open func setNeedsDisplay() {
        super.setNeedsDisplay()
        self.textImage = nil
    }
    
    override open func setNeedsDisplay(_ rect: CGRect) {
        super.setNeedsDisplay(rect)
        self.textImage = nil
    }
    
    
    
    override open func draw(_ rect: CGRect) {
        let size = bounds.size
        
        if textImage == nil {
            let drawText = {
                let backgroundColor = self.layer.backgroundColor
                
                self.layer.backgroundColor = UIColor.clear.cgColor
                super.draw(rect)
                self.layer.backgroundColor = backgroundColor
            }
            
            if #available(iOS 10.0, *) {
                textImage = UIGraphicsImageRenderer(size: size).image(actions: { _ in drawText() })
            } else {
                UIGraphicsBeginImageContext(size)
                defer { UIGraphicsEndImageContext() }
                
                drawText()
                textImage = UIGraphicsGetImageFromCurrentImageContext()
            }
        }
        
        if let context = UIGraphicsGetCurrentContext(),
           let gradientColors = gradientColors,
           let gradientType = gradientType {
            var gradient: CGGradient?
            
            if let gradientLocations = gradientLocations {
                gradientLocations.map({ CGFloat($0.doubleValue) }).withUnsafeBufferPointer({ (buffer: UnsafeBufferPointer<CGFloat>) in
                    gradient = CGGradient(colorsSpace: nil, colors: (gradientColors.map({ $0.cgColor }) as CFArray), locations: buffer.baseAddress)
                })
            } else {
                gradient = CGGradient(colorsSpace: nil, colors: (gradientColors.map({ $0.cgColor }) as CFArray), locations: nil)
            }
            
            if let gradient = gradient {
                switch gradientType {
                case let .axial(start, end):
                    context.drawLinearGradient(gradient, start: CGPoint(x: start.x * size.width, y: start.y * size.height),
                                                         end: CGPoint(x: end.x * size.width, y: end.y * size.height),
                                                         options: gradientOptions)
                    
                case let .radial(startCenter, startRadius, endCenter, endRadius, radiiScalingRule):
                    let radiiScale: CGFloat
                    switch radiiScalingRule {
                    case .width:        radiiScale = size.width
                    case .height:       radiiScale = size.height
                    case .minimumBound: radiiScale = min(size.width, size.height)
                    case .maximumBound: radiiScale = max(size.width, size.height)
                    }
                    
                    context.drawRadialGradient(gradient, startCenter: CGPoint(x: startCenter.x * size.width, y: startCenter.y * size.height),
                                                         startRadius: startRadius * radiiScale,
                                                         endCenter: CGPoint(x: endCenter.x * size.width, y: endCenter.y * size.height),
                                                         endRadius: endRadius * radiiScale,
                                                         options: gradientOptions)
                }
            }
        }
        
        switch textGradientLocation {
        case .foreground: textImage?.draw(at: .zero, blendMode: .destinationIn, alpha: 1.0)
        case .background: textImage?.draw(at: .zero)
        }
    }
}

//MARK: - Struct (CGPoint) Extension

extension CGPoint {
    
    fileprivate func clamped(minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat) -> CGPoint {
        precondition(minX <= maxX, "'minX' must be less than or equal to 'maxX'")
        precondition(minY <= maxY, "'minY' must be less than or equal to 'maxY'")
        
        var point = self
        
        if point.x < minX { point.x = minX }
        if point.y < minY { point.y = minY }
        
        if point.x > maxX { point.x = maxX }
        if point.y > maxY { point.y = maxY }
        
        return point
    }
    
    fileprivate func clamped(min: CGPoint, max: CGPoint) -> CGPoint {
        return clamped(minX: min.x, maxX: max.x, minY: min.y, maxY: max.y)
    }
    
    fileprivate func clamped(min: CGFloat, max: CGFloat) -> CGPoint {
        return clamped(minX: min, maxX: max, minY: min, maxY: max)
    }
}
