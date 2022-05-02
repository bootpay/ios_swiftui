//
//  ViewModel.swift
//  BootpayUI_Example
//
//  Created by Taesup Yoon on 2022/04/27.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import SwiftUI
import Bootpay

class ViewModel: ObservableObject {
    let restApplicationId = "5b8f6a4d396fa665fdc2b5ea"
    let privateKey = "rm6EYECr6aroQVG2ntW0A6LpWnkTgP4uQ3H18sDDUYw="
//    var manager = BootpayRest()
    
    @Published var easyPayUserToken = ""
    @Published var showingBootpay = false
    
    var bootUser = BootUser()
    
    func getUserToken(user: BootUser) {
        self.bootUser = user
        
        BootpayRest.getRestToken(
            sendable: self,
            restApplicationId: restApplicationId,
            privateKey: privateKey
        )
    }
    
    func showBootpay() {
        self.showingBootpay = true
    }
    
    func hideBootpay() {
        self.showingBootpay = false
    }
}

extension ViewModel: BootpayRestProtocol {
   func callbackRestToken(resData: [String : Any]) {
       print("callbackRestToken: \(resData)")
       if let token = resData["access_token"] {
           BootpayRest.getEasyPayUserToken(
               sendable: self,
               restToken: token as! String,
               user: bootUser
           )
       }
   }
   
   func callbackEasyCardUserToken(resData: [String : Any]) {
       print("callbackEasyCardUserToken: \(resData)")
       if let userToken = resData["user_token"] as? String {
           self.easyPayUserToken = userToken
           self.showBootpay()
//           self.showingBootpay = true
       }
   }
   
//   func getRestToken () {
//       //production
////        let restApplicationId = "5b8f6a4d396fa665fdc2b5ea"
////        let privateKey = "n9jO7MxVFor3o//c9X5tdep95ZjdaiDvVB4h1B5cMHQ="
//
//       //development
//       let restApplicationId = "5b9f51264457636ab9a07cde"
//       let privateKey = "sfilSOSVakw+PZA+PRux4Iuwm7a//9CXXudCq9TMDHk="
//
//        BootpayRest.getRestToken(sendable: self, restApplicationId: restApplicationId, privateKey: privateKey)
//   }

}
