//
//  BootBioPrice.swift
//  SwiftyBootpay
//
//  Created by Taesup Yoon on 14/10/2020.
//


import Foundation

public class BootBioPrice: NSObject, Codable {
    @objc public var name = ""
    @objc public var price = Double(0)
    @objc public var priceStroke = Double(0)
    
    public override init() {}
}


