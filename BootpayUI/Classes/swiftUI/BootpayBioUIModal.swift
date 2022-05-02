//
//  BootpayBioUIModal.swift
//  BootpayUI
//
//  Created by Taesup Yoon on 2022/04/27.
//

import SwiftUI
import Bootpay

public struct BootpayBioUIModal: View {

  public var bioPayload: BootBioPayload
//  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
  public init(payload: BootBioPayload, userToken: String, showBootpay:  Binding<Bool>) {
      self.bioPayload = payload
      self.bioPayload.userToken = userToken
      
      BootpayBio.sharedBio.bioPayload = self.bioPayload
      BootpayBio.sharedBio.bioUIModal = self
      BootpayBio.sharedBio.showBootpay = showBootpay
  }
    
  public var body: some View {
    Group {
        BootpayBioUIController(payload: self.bioPayload)
//        Text("dismiss")
//      Button(action: {
//         self.presentationMode.wrappedValue.dismiss()
//      }) {
//        Text("Dismiss")
//      }
    }
  }
}


extension BootpayBioUIModal {
    
    public func onError(_ action: @escaping ([String : Any]) -> Void) -> BootpayBioUIModal {
        BootpayBio.sharedBio.error = action
        return self
    }

    public func onIssued(_ action: @escaping ([String : Any]) -> Void) -> BootpayBioUIModal {
        BootpayBio.sharedBio.issued = action
        return self
    }
    
    public func onClose(_ action: @escaping () -> Void) -> BootpayBioUIModal {
        BootpayBio.sharedBio.close = action
        return self
    }
    
    public func onConfirm(_ action: @escaping([String : Any]) -> Bool) -> BootpayBioUIModal {
        BootpayBio.sharedBio.confirm = action
        return self
    }
    
    public func onCancel(_ action: @escaping ([String : Any]) -> Void) -> BootpayBioUIModal {
        BootpayBio.sharedBio.cancel = action
        return self
    }
    
    public func onDone(_ action: @escaping ([String : Any]) -> Void) -> BootpayBioUIModal {
        BootpayBio.sharedBio.done = action
        return self
    }
}
 
