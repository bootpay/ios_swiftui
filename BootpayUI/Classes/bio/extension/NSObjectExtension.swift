//
//  AssociatedObjectExtension.swift
//  BiometricAuthenticationExample
//
//  Copyright (c) 2018 Rushi Sangani
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import ObjectiveC.NSObjCRuntime

/// NSObject associated object
public extension NSObject {
    
    /// keys
    private struct AssociatedKeys {
        static var descriptiveName = "associatedObject"
    }
    
    /// set associated object
    @objc func setAssociated(object: Any) {
        objc_setAssociatedObject(self, &AssociatedKeys.descriptiveName, object, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// get associated object
    @objc func associatedObject() -> Any? {
        return objc_getAssociatedObject(self, &AssociatedKeys.descriptiveName)
    }
} 

public extension UIImage {
    @available(iOS 13.0, *)
    static func fromBundle(_ name: String) -> UIImage? {
        // 1. First try to load from the module bundle (SPM support)
        let frameworkBundle = Bundle(for: BootpayBio.self)

        // 2. Try CocoaPods resource bundle first
        if let bundleURL = frameworkBundle.url(forResource: "BootpayUI", withExtension: "bundle"),
           let resourceBundle = Bundle(url: bundleURL) {
            // Try loading PNG file directly from bundle
            if let imagePath = resourceBundle.path(forResource: name, ofType: "png"),
               let image = UIImage(contentsOfFile: imagePath) {
                return image
            }
            // Try loading from Images subfolder
            if let imagePath = resourceBundle.path(forResource: name, ofType: "png", inDirectory: "Images"),
               let image = UIImage(contentsOfFile: imagePath) {
                return image
            }
            // Try with UIImage named API
            if let image = UIImage(named: name, in: resourceBundle, compatibleWith: nil) {
                return image
            }
        }

        // 3. Try loading from resourceURL (for development pods)
        if let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("BootpayUI.bundle"),
           let resourceBundle = Bundle(url: bundleURL) {
            if let imagePath = resourceBundle.path(forResource: name, ofType: "png"),
               let image = UIImage(contentsOfFile: imagePath) {
                return image
            }
            if let image = UIImage(named: name, in: resourceBundle, compatibleWith: nil) {
                return image
            }
        }

        // 4. Try loading directly from framework bundle
        if let image = UIImage(named: name, in: frameworkBundle, compatibleWith: nil) {
            return image
        }

        // 5. As a last resort, try the main bundle
        return UIImage(named: name)
    }
}


public extension Double {
    func comma() -> String {
            let numberFormatter = NumberFormatter()
            numberFormatter.groupingSeparator = ","
            numberFormatter.groupingSize = 3
            numberFormatter.usesGroupingSeparator = true
            numberFormatter.decimalSeparator = "."
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: self as NSNumber)!
    }
}


public extension Int {
    func comma() -> String {
            let numberFormatter = NumberFormatter()
            numberFormatter.groupingSeparator = ","
            numberFormatter.groupingSize = 3
            numberFormatter.usesGroupingSeparator = true
            numberFormatter.decimalSeparator = "."
            numberFormatter.numberStyle = .decimal 
        return numberFormatter.string(from: self as NSNumber)!
    }
}
