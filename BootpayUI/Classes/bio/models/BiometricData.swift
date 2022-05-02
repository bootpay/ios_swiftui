//
//  BiometricData.swift
//  bootpayBio
//
//  Created by Taesup Yoon on 2022/03/03.
//

import ObjectMapper

public class BiometricData: NSObject, Mappable, Decodable {
    public override init() {}
    public required init?(map: Map) {} 
    
    @objc public var biometric_confirmed = false
    @objc public var server_unixtime = 0
      
    public func mapping(map: Map) {
        biometric_confirmed <- map["biometric_confirmed"]
        server_unixtime <- map["server_unixtime"]
    }
}


