//
//  BootpayBioUIModal.swift
//  BootpayUI
//
//  Created by Taesup Yoon on 2022/04/27.
//

import SwiftUI
import Bootpay

public struct BootpayBioUI: View {

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
    }
  }
}


extension BootpayBioUI {
    
    public func onError(_ action: @escaping ([String : Any]) -> Void) -> BootpayBioUI {
        BootpayBio.sharedBio.error = action
        return self
    }

    public func onIssued(_ action: @escaping ([String : Any]) -> Void) -> BootpayBioUI {
        BootpayBio.sharedBio.issued = action
        return self
    }
    
    public func onClose(_ action: @escaping () -> Void) -> BootpayBioUI {
        BootpayBio.sharedBio.close = action
        return self
    }
    
    public func onConfirm(_ action: @escaping([String : Any]) -> Bool) -> BootpayBioUI {
        BootpayBio.sharedBio.confirm = action
        return self
    }
    
    public func onCancel(_ action: @escaping ([String : Any]) -> Void) -> BootpayBioUI {
        BootpayBio.sharedBio.cancel = action
        return self
    }
    
    public func onDone(_ action: @escaping ([String : Any]) -> Void) -> BootpayBioUI {
        BootpayBio.sharedBio.done = action
        return self
    }
}
 
