import Foundation
import Bootpay
import ObjectMapper

public class BootBioPayload: NSObject, Codable  {
    
    @objc public var applicationId = ""
    @objc public var pg: String?
    @objc public var method: String?
    @objc public var methods: [String]?
    
    @objc public var orderName: String?
    @objc public var price = Double(0)
    @objc public var taxFree = Double(0)
    
    @objc public var orderId = ""
    @objc public var subscriptionId = ""
    @objc public var authenticationId = ""
    @objc public var easyType = "" //생체인증 결제, 비밀번호 결제 시 사용됨 
    
//    @objc public var params: String?
     
    @objc public var isPasswordMode = false
    @objc public var isEditdMode = false 
    @objc public var walletId = "";
    @objc public var token = "";
    @objc public var authenticateType = "";
    @objc public var userToken = "";
    @objc public var metadata: [String:String]?
    
    @objc public var names = [String]()
    @objc public var prices = [BootBioPrice]()
    
    
    @objc public var extra: BootBioExtra?
    @objc public var user: BootUser? = BootUser()
    @objc public var items: [BootItem]?
     
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(applicationId, forKey: .applicationId)
        try container.encodeIfPresent(pg, forKey: .pg)
 
        if (methods?.count ?? 0) > 0 {
            try container.encodeIfPresent(methods!, forKey: .method)
        } else {
            try container.encodeIfPresent(method, forKey: .method)
        }
        try container.encodeIfPresent(orderName, forKey: .orderName)
        try container.encodeIfPresent(price, forKey: .price)
        try container.encodeIfPresent(taxFree, forKey: .taxFree)        
        
        try container.encodeIfPresent(walletId, forKey: .walletId)
        try container.encodeIfPresent(orderId, forKey: .orderId)
        try container.encodeIfPresent(subscriptionId, forKey: .subscriptionId)
        try container.encodeIfPresent(authenticationId, forKey: .authenticationId)
        try container.encodeIfPresent(easyType, forKey: .easyType)
        
        try container.encodeIfPresent(token, forKey: .token)
        try container.encodeIfPresent(authenticateType, forKey: .authenticateType)
        try container.encodeIfPresent(userToken, forKey: .userToken)
        try container.encodeIfPresent(metadata, forKey: .metadata)
         
        
        try container.encodeIfPresent(extra, forKey: .extra)
        try container.encodeIfPresent(user, forKey: .user)
        try container.encodeIfPresent(items, forKey: .items)
    }
    
    public func mapping(map: Map) {
        applicationId <- map["application_id"]
        pg <- map["pg"]
        method <- map["method"]
        methods <- map["methods"]
        
        orderName <- map["order_name"]
        price <- map["price"]
        taxFree <- map["tax_free"]
        
        orderId <- map["order_id"]
        subscriptionId <- map["subscription_id"]
        authenticationId <- map["authentication_id"]
        easyType <- map["easy_type"]
        
        walletId <- map["wallet_id"]
        token <- map["token"]
        authenticateType <- map["authenticate_type"]
        userToken <- map["user_token"]
        metadata <- map["metadata"]
//        token <- map["token"]
        
        extra <- map["extra"]
        user <- map["user"]
        items <- map["items"]
    }
     
    
    fileprivate func methodsToJson() -> String {
        
        guard let methods = self.methods else {return "" }
        var result = ""
        for v in methods {
            if result.count == 0 {
                result += "'\(v)'"
            } else {
                result += ",'\(v)'"
            }
        }
        return "[\(result)]"
    }
}

