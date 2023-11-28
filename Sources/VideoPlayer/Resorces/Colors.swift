//
//  File.swift
//  
//
//  Created by Álvaro Olave Bañeres on 27/11/23.
//

import Foundation
import UIKit

public enum Colors {
    public static let IconTint = UIColor.secureName(name: "iconTint")
    public static let InterfaceBackground = UIColor.secureName(name: "interfaceBackground")
    public static let CurrentProgress = UIColor.secureName(name: "currentProgress")
    public static let TitleColor = UIColor.secureName(name: "titleColor")
}

extension UIColor {
    public static func secureName(name: String) -> UIColor {
        return UIColor(named: name, in: .module, compatibleWith: nil) ?? .clear
    }
}

extension UIImage {
    public static func secureImage(name: String) -> UIImage? {
        return UIImage(named: name, in: .module, compatibleWith: nil)
    }
}
