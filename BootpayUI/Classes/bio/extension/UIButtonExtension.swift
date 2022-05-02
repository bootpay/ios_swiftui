//
//  UIButtonExtension.swift
//  bootpayBio
//
//  Created by Taesup Yoon on 2022/03/16.
//

import UIKit

public extension UIButton {
    func setBackgroundColor(_ color: UIColor?, cornerRadius: CGFloat = 8.0, for state: UIControl.State) {
          
          guard let color = color else {
              self.setBackgroundImage(nil, for: state)
              return
          }
          
          let length = 1 + cornerRadius * 2
          let size = CGSize(width: length, height: length)
          let rect = CGRect(origin: .zero, size: size)
          
          var backgroundImage = UIGraphicsImageRenderer(size: size).image { (context) in
              // Fill the square with the black color for later tinting.
              color.setFill()
              UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).fill()
          }
          
          backgroundImage = backgroundImage.resizableImage(withCapInsets: UIEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius))
          
          // Apply the `color` to the `backgroundImage` as a tint color
          // so that the `backgroundImage` can update its color automatically when the currently active traits are changed.
          if #available(iOS 13.0, *) {
              backgroundImage = backgroundImage.withTintColor(color, renderingMode: .alwaysOriginal)
          }
          
          self.setBackgroundImage(backgroundImage, for: state)
      }
}
