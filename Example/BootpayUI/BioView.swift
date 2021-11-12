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

struct BioView: View {
    @State private var showingBootpay = false
    private var _payload = BootBioPayload()
    private var _bootUser = BootUser()
    
    var manager = BootpayRest()
    let user = BootUser()
//    @State private var showModalBootpay = false
    private var payload = BootBioPayload()
     
    var body: some View {
        GeometryReader { geometry in
            VStack {
                    
               
                if(self.showingBootpay == false) {
                    Button("pay ") {
                        
                        user.userId = "12345"
                        user.area = "서울"
                        user.gender = 1
                        user.email = "test1234@gmail.com"
                        user.phone = "010-1234-4567"
                        user.birth = "1988-06-10"
                        user.username = "홍길동"
                        
                        self.manager.getUserToken(
                            restApplicationId: "5b8f6a4d396fa665fdc2b5ea",
                            privateKey: "rm6EYECr6aroQVG2ntW0A6LpWnkTgP4uQ3H18sDDUYw=",
                            user: user) { result, token in
                            
                                #if os(macOS)
                                payload.applicationId = "5b8f6a4d396fa665fdc2b5e7" //web application id
                                #elseif os(iOS)
                                payload.applicationId = "5b8f6a4d396fa665fdc2b5e9" //ios application id
                                #endif

                                payload.pg = "nicepay"

                                payload.price = 1000
                                payload.orderId = String(NSTimeIntervalSince1970)
                                //                        payload.name = "테스트 아이템"
                                payload.name = "Touch ID 인증 결제 테스트"

                                payload.names = ["플리츠레이어 카라숏원피스", "블랙 (COLOR)", "55 (SIZE)"]
                                   
                                payload.userToken = token
                                payload.userInfo = user
                                
                                payload.extra = BootExtra()
                                payload.extra?.quotas = [0,2,3,4,5,6]

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
                                
                                self.showingBootpay = true
                        }
                    }
                } else {
                    
                    BootpayBioUI(
                            bioPayload: payload)
                        .onError{ data in
                            print("error \(data)")
                        }.onReady{ data in
                            print("ready \(data)")
                        }
                        .onConfirm { data in
                            print("confirm  \(data)")
                            return true
                        }
                        .onCancel { data in
                            print("cancel  \(data)")
                        }
                        .onDone { data in
                            print("done \(data)")
                        }
                        .onClose {
                            print("close")
                            self.showingBootpay = false
                        }
                        .background(Color.red)
                }
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct BioView_Previews: PreviewProvider {
    static var previews: some View {
        BioView()
    }
}
  