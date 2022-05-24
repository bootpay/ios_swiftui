//
//  BioView.swift
//  BootpayUI_Example
//
//  Created by Taesup Yoon on 2021/10/28.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SwiftUI
import Alamofire
import Bootpay
import BootpayUI


let _unique_user_id = "123456abcdffffe2345678901234561324516789122"


struct BootpayBioView: View {
    @ObservedObject private var viewModel = ViewModel()
    private var _payload = BootBioPayload()
    let user = BootUser()
    private var payload = BootBioPayload()
    
    
    
   var body: some View {
       GeometryReader { geometry in
           VStack {
//               if(self.viewModel.showingBootpay == false) {
               Button("생체인증 결제테스트") {
                   
                   user.id = _unique_user_id
                   user.area = "서울"
                   user.gender = 1
                   user.email = "test1234@gmail.com"
                   user.phone = "01012344567"
                   user.birth = "1988-06-10"
                   user.username = "홍길동"
                   
                   #if os(macOS)
                   payload.applicationId = "5b8f6a4d396fa665fdc2b5e7" //web application id
                   #elseif os(iOS)
                   payload.applicationId = "5b8f6a4d396fa665fdc2b5e9" //ios application id
                   #endif

                   payload.pg = "nicepay"

                   payload.price = 1000
                   payload.orderId = String(NSTimeIntervalSince1970)
                   //                        payload.name = "테스트 아이템"
                   payload.orderName = "Touch ID 인증 결제 테스트"

                   payload.names = ["플리츠레이어 카라숏원피스", "블랙 (COLOR)", "55 (SIZE)"]
                      
//                        payload.userToken = token
                   payload.user = user

                   payload.extra = BootExtra()
                   payload.extra?.cardQuota = "6"
                   payload.extra?.displaySuccessResult = true

                   let p1 = BootBioPrice()
                   let p2 = BootBioPrice()
                   let p3 = BootBioPrice()

                   p1.name = "상품가격"
                   p1.price = 89000

                   p2.name = "쿠폰적용"
                   p2.price = -2500

                   p3.name = "배송비"
                   p3.price = 2500

                   payload.prices = [p1, p2, p3]
                   viewModel.getUserToken(user: user)
               }
               .sheet(isPresented: self.$viewModel.showingBootpay) {
                   BootpayBioUI(payload: self.payload, userToken: self.viewModel.easyPayUserToken, showBootpay: self.$viewModel.showingBootpay)
                       .onError{ data in
                           print("-- error \(data)")
                       }.onIssued{ data in
                           print("-- ready \(data)")
                       }
                       .onConfirm { data in
                           print("-- confirm  \(data)")
                           return true
//                           BootpayBio.transactionConfirm()
//                           return false
                       }
                       .onCancel { data in
                           print("-- cancel  \(data)")
                       }
                       .onDone { data in
                           print("-- done \(data)")
                       }
                       .onClose {
                           print("-- close")
                       }
                       
               }
           }.frame(width: geometry.size.width, height: geometry.size.height)
       }
   }
}

//struct BioView_Previews: PreviewProvider {
//    static var previews: some View {
//        BioView()
//    }
//}
  
