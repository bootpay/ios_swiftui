//
//  WalletData.swift
//  bootpayBio
//
//  Created by Taesup Yoon on 2022/03/03.
//

import ObjectMapper

public class WalletData: NSObject, Mappable, Decodable {
    public override init() {}
    public required init?(map: Map) {}
        
    @objc public var wallet_id = ""
    @objc public var type = 0
    @objc public var sandbox = 1
    @objc public var batch_data: WalletCardData? 
    @objc public var wallet_type = 0; // 1: new, 2: other
      
    public func mapping(map: Map) {
        wallet_id <- map["wallet_id"]
        type <- map["type"]
        sandbox <- map["sandbox"]
        batch_data <- map["batch_data"]
    }
}
