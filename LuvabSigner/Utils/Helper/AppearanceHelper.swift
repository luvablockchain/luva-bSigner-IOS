//
//  AppearanceHelper.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 9/17/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import Foundation
import UIKit

struct AppearanceHelper {
    
    static func setDashBorders(for view: UIView, with color: CGColor) {
        let viewBorder = CAShapeLayer()
        viewBorder.strokeColor = color
        viewBorder.lineDashPattern = [6, 2]
        viewBorder.frame = view.bounds
        viewBorder.fillColor = nil
        viewBorder.path = UIBezierPath(rect: view.bounds).cgPath
        view.layer.addSublayer(viewBorder)
    }
    
    static func changeDashBorderColor(for view: UIView, with color: CGColor) {
        let viewBorder = view.layer.sublayers?.last as? CAShapeLayer
        viewBorder?.strokeColor = color
    }
    
    static func removeDashBorders(from view: UIView) {
        let viewBorder = view.layer.sublayers?.last as? CAShapeLayer
        viewBorder?.removeFromSuperlayer()
    }
}
