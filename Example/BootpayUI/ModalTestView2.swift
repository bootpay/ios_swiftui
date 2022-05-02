//
//  ModalTestView2.swift
//  BootpayUI_Example
//
//  Created by Taesup Yoon on 2022/05/02.
//  Copyright © 2022 CocoaPods. All rights reserved.
//


import SwiftUI
import Alamofire
import Bootpay
import BootpayUI

struct ModalTestView2: View {
    @ObservedObject var viewModel = ViewModel()
//    @State private var showModal = false //상태

    var body: some View {
        VStack{
        Text("Hello, World!")
            Button(action: {
             print("hello button!!")
            
             self.viewModel.showBootpay()
//            self.showModal = true
            }){
                Text(/*@START_MENU_TOKEN@*/"Button"/*@END_MENU_TOKEN@*/)
            }
            .sheet(isPresented: $viewModel.showingBootpay) {
                BootpayBioUIModal2()
            }
        }
    }
}

struct BootpayBioUIModal2: View {

  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

  var body: some View {
    Group {
      Text("Modal view")
      Button(action: {
         self.presentationMode.wrappedValue.dismiss()
      }) {
        Text("Dismiss")
      }
    }
  }
}
