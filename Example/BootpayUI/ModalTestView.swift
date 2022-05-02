//
//  ModalTestView.swift
//  BootpayUI_Example
//
//  Created by Taesup Yoon on 2022/04/27.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import SwiftUI
import Alamofire
import Bootpay
import BootpayUI

struct ModalTestView: View {
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
//                        self.manager.getUserToken(
//                            restApplicationId: "5b8f6a4d396fa665fdc2b5ea",
//                            privateKey: "rm6EYECr6aroQVG2ntW0A6LpWnkTgP4uQ3H18sDDUYw=",
//                            user: user) { result, token in
//
//
//
////                                self.showingBootpay = true
//                        }
               }
               .sheet(isPresented: self.$viewModel.showingBootpay) {
                   BootpayBioUIModal(payload: self.payload, userToken: self.viewModel.easyPayUserToken, showBootpay: self.$viewModel.showingBootpay)
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
                           BootpayBio.removePaymentWindow()
//                           self.viewModel.showingBootpay = false
                       }
                       
               }
//               } else {
//                   BootpayBioUI(payload: payload, userToken: viewModel.easyPayUserToken)
//                       .onError{ data in
//                           print("error \(data)")
//                       }.onIssued{ data in
//                           print("ready \(data)")
//                       }
//                       .onConfirm { data in
//                           print("confirm  \(data)")
//                           return true
//                       }
//                       .onCancel { data in
//                           print("cancel  \(data)")
//                       }
//                       .onDone { data in
//                           print("done \(data)")
//                       }
//                       .onClose {
//                           print("close")
////                            self.showingBootpay = false
//                       }
//                       .background(Color.red)
//               }
           }.frame(width: geometry.size.width, height: geometry.size.height)
       }
   }
    
//    @State private var showModal = false //상태
//
//    var body: some View {
//        VStack{
//        Text("Hello, World!")
//            Button(action: {
//             print("hello button!!")
//            self.showModal = true
//            }){
//                Text(/*@START_MENU_TOKEN@*/"Button"/*@END_MENU_TOKEN@*/)
//            }
//            .sheet(isPresented: self.$showModal) {
//                BootpayBioUIModal()
//            }
//        }
//    }
}

//struct BootpayBioUIModal: View {
//
//  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
//
//  var body: some View {
//    Group {
//      Text("Modal view")
//      Button(action: {
//         self.presentationMode.wrappedValue.dismiss()
//      }) {
//        Text("Dismiss")
//      }
//    }
//  }
//}
