//
//  WalletCardData.swift
//  bootpayBio
//
//  Created by Taesup Yoon on 2022/03/03.
//


import ObjectMapper

public class WalletCardData: NSObject, Mappable, Decodable {
    public override init() {}
    public required init?(map: Map) {}
    
    
    @objc public var card_no = ""
    @objc public var card_company = ""
    @objc public var card_company_code = ""
    @objc public var card_type = 1
    @objc public var card_hash = ""
      
    public func mapping(map: Map) {
        card_no <- map["card_no"]
        card_company <- map["card_company"]
        card_company_code <- map["card_company_code"]
        card_type <- map["card_type"]
        card_hash <- map["card_hash"]
    }
}

