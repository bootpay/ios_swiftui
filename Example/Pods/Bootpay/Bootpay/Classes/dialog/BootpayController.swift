//
//  BootpayController.swift
//  SwiftBootpay
//
//  Created by Taesup Yoon on 2021/05/12.
//
import UIKit

class BootpayController: UIViewController {
    let bootpayWebView = BootpayWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(bootpayWebView)
    }
    
}
