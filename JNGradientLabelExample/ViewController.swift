//
//  ViewController.swift
//  JNGradientLabel
//
//  Created by Joseph Newton on 01/20/2020.
//  Copyright (c) 2020 Joseph Newton. All rights reserved.
//

import JNGradientLabel
import UIKit

// MARK: - Class (ViewController) Definition

class ViewController: UIViewController {

    // MARK: Interface Builder Outlets

    @IBOutlet private weak var foregroundAxialGradientLabel: JNGradientLabel!
    @IBOutlet private weak var backgroundAxialGradientLabel: JNGradientLabel!

    @IBOutlet private weak var foregroundRadialGradientLabel: JNGradientLabel!
    @IBOutlet private weak var backgroundRadialGradientLabel: JNGradientLabel!

    // MARK: View Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        let gradientColors: [UIColor]    = [.purple, .cyan]
        let gradientlocations: [CGFloat] = [1.0, 0.0]

        foregroundAxialGradientLabel.textGradientLocation = .foreground
        foregroundAxialGradientLabel.setAxialGradientParameters(startPoint: CGPoint(x: 0.0, y: 0.0),
                                                                endPoint: CGPoint(x: 1.0, y: 0.0),
                                                                colors: gradientColors,
                                                                locations: gradientlocations)

        backgroundAxialGradientLabel.textColor = .white
        backgroundAxialGradientLabel.textGradientLocation = .background
        backgroundAxialGradientLabel.setAxialGradientParameters(startPoint: CGPoint(x: 0.0, y: 0.0),
                                                                endPoint: CGPoint(x: 1.0, y: 0.0),
                                                                colors: gradientColors,
                                                                locations: gradientlocations)

        foregroundRadialGradientLabel.textGradientLocation = .foreground
        foregroundRadialGradientLabel.setRadialGradientParameters(startCenter: CGPoint(x: 0.5, y: 0.5),
                                                                  startRadius: 0.0,
                                                                  endCenter: CGPoint(x: 0.5, y: 0.5),
                                                                  endRadius: 0.5,
                                                                  colors: gradientColors,
                                                                  locations: gradientlocations,
                                                                  radiiScalingRule: .maximumBound)

        backgroundRadialGradientLabel.textColor = .white
        backgroundRadialGradientLabel.textGradientLocation = .background
        backgroundRadialGradientLabel.setRadialGradientParameters(startCenter: CGPoint(x: 0.5, y: 0.5),
                                                                  startRadius: 0.0,
                                                                  endCenter: CGPoint(x: 0.5, y: 0.5),
                                                                  endRadius: 0.5,
                                                                  colors: gradientColors,
                                                                  locations: gradientlocations,
                                                                  radiiScalingRule: .maximumBound)
    }
}
