import Foundation
import Bootpay

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
    
    @objc public var params: String?
     
    @objc public var isPasswordMode = false 
    @objc public var walletId = "";
    @objc public var token = "";
    @objc public var authenticateType = "";
    @objc public var userToken = "";
    @objc public var metadata: [String:String]?
    
    @objc public var names = [String]()
    @objc public var prices = [BootBioPrice]()
    
    
    @objc public var extra: BootExtra?
    @objc public var user: BootUser? = BootUser()
    @objc public var items: [BootItem]?
     
    
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

