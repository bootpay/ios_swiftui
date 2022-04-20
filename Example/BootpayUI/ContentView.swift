//
//  ContentView.swift
//  Shared
//
//  Created by Taesup Yoon on 2021/10/28.
//

import SwiftUI
import WebKit
import Bootpay
import BootpayUI



struct ContentView: View {
//    @State private var showModal = false
    @State private var showingBootpay = false
    private var payload = Payload()
       
    var body: some View {
        GeometryReader { geometry in
            VStack { 
                
                if(self.showingBootpay) {
                    BootpayUI(payload: payload)
                        .onCancel { data in
                            print("-- cancel: \(data)")
                        }
                        .onReady { data in
                            print("-- ready: \(data)")
                        }
                        .onConfirm { data in
                            print("-- confirm: \(data)")
                            return true //재고가 있어서 결제를 최종 승인하려 할 경우
//                            return false //재고가 없어서 결제를 승인하지 않을때
                        }
                        .onDone { data in
                            print("-- done: \(data)")
                        }
                        .onError { data in
                            print("-- error: \(data)")
                        }
                        .onClose {
                            print("-- close")
                            self.showingBootpay = false 
                        }
                } else {
                    Button("부트페이 결제테스트") {
                        showingBootpay = true

                        #if os(macOS) 
                        payload.applicationId = "5b8f6a4d396fa665fdc2b5e7" //web application id
                        #elseif os(iOS)
                        payload.applicationId = "5b8f6a4d396fa665fdc2b5e9" //ios application id
                        #endif

                        payload.pg = "nicepay"
                        payload.method = "kakao"
                        
                        payload.price = 1000
                        payload.orderId = String(NSTimeIntervalSince1970)
                        payload.name = "테스트 아이템"
                        
                        payload.extra = BootExtra()
                        payload.extra?.quota = "0,2,3,4,5,6"

                        let user = BootUser()
                        user.username = "테스트 유저"
                        user.phone = "01012345678"
                        payload.userInfo = user
                    }.sheet(isPresented: self.$showingBootpay) {
                    }
                }
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
 
