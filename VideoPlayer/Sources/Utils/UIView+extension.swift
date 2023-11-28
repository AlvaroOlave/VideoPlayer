//
//  File.swift
//  
//
//  Created by Álvaro Olave Bañeres on 22/11/23.
//

import Foundation

internal extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach(addSubview)
    }
}
