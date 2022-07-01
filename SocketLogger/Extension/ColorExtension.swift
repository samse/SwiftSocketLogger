//
//  ColorExtension.swift
//  HLFMOBRC
//
//  Created by Hyunjun Kwak on 2022/03/29.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, a: Int = 0xff) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xff,
            green: (rgb >> 8) & 0xff,
            blue: rgb & 0xff
        )
   }

    convenience init(argb: Int) {
        self.init(
            red: (argb >> 16) & 0xff,
            green: (argb >> 8) & 0xff,
            blue: argb & 0xff,
            a: (argb >> 24) & 0xff
        )
    }
}
