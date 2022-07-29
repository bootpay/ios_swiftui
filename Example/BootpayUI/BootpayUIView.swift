//
//  BootpayUIView.swift
//  BootpayUI_Example
//
//  Created by Taesup Yoon on 2022/05/24.
//  Copyright © 2022 CocoaPods. All rights reserved.
//


import SwiftUI
import WebKit
import Bootpay
import BootpayUI

struct BootpayUIView: View {
//    @State private var showModal = false
    @State private var showingBootpay = false
    private var payload = Payload()
       
    var body: some View {
        GeometryReader { geometry in
            VStack {
                
                if(self.showingBootpay) {
                    BootpayUI(payload: payload, requestType: BootpayRequest.TYPE_PAYMENT)
                        .onCancel { data in
                            print("-- cancel: \(data)")
                        }
                        .onIssued { data in
                            print("-- ready: \(data)")
                        }
                        .onConfirm { data in
                            print("-- confirm: \(data)")
                            return true //재고가 있어서 결제를 최종 승인하려 할 경우
//                            return true //재고가 없어서 결제를 승인하지 않을때
//                            return false
                        }
                        .onDone { data in
                            print("-- done: \(data)")
                        }
                        .onError { data in
                            print("-- error: \(data)")
                            self.showingBootpay = false
                        }
                        .onClose {
                            print("-- close")
                            self.showingBootpay = false
                        }
                } else {
                    Button("부트페이 결제테스트") {

//                        #if os(macOS)
//                        payload.applicationId = "5b8f6a4d396fa665fdc2b5e7" //web application id
//                        #elseif os(iOS)
//                        payload.applicationId = "5b8f6a4d396fa665fdc2b5e9" //ios application id
//                        #endif

                        #if os(macOS)
                        payload.applicationId = "5b8f6a4d396fa665fdc2b5e7" //web application id
                        #elseif os(iOS)
                        payload.applicationId = "59bfc733e13f337dbd6ca489" //ios application id
                        #endif
                        payload.pg = "웰컴페이먼츠"
                        payload.method = "디지털카드"

                        payload.price = 1000
                        payload.orderId = String(NSTimeIntervalSince1970)
                        payload.orderName = "테스트 아이템"

                        payload.extra = BootExtra()
//                        payload.extra?.separatelyConfirmed = false
//                        payload.extra?.cardQuota = "6"

                        let user = BootUser()
                        user.username = "테스트 유저"
                        user.phone = "01012345678"
                        payload.user = user
                        showingBootpay = true
                    }.sheet(isPresented: self.$showingBootpay) {
                    }
                }
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
 
