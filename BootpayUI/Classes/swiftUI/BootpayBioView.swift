//
//  BootpayBioView.swift
//  BootpayUI
//
//  Created by Taesup Yoon on 2021/11/04.
//

import UIKit
import WebKit
import SnapKit
import JGProgressHUD
import LocalAuthentication
import Alamofire
import Bootpay
import SCLAlertView

public class BootpayBioView: UIView {
//    var parent: BootpayBioUI!
    
    
    //subviews 관련
    let hideBtn = UIButton()
    let actionView = UIView()
    var bottomTitle = UILabel()
    var bioWebView: BootpayBioWebView?
    
    
    var toolBar = UIToolbar()
    var picker  = UIPickerView()
    let btnPicker = UIButton()
    var cardSelectView: CardSelectView!
    let hud = JGProgressHUD()
    
    //내부 변수 관련
    var bioPayload: BootBioPayload?
    var payServerUnixtime = 0 //결제용    
    var selectedCardIndex = 0
    var selectedQuotaRow = -1 //picker
    var currentDeviceBioType = false // 생체인증 유형에 따라 호출해야할 api가 달라짐
    var isShowCloseMsg = true //종료시 onClose message 호출할지
    var isWebViewPay = false //기타 결제수단으로 결제할지
    var actionViewHeight = CGFloat(0)
    var cardInfoList = [CardInfo]()
    var isEnableDeviceSoon = false
    
    //
    private let bt1 = "이 카드로 결제합니다"
    private let bt2 = "새로운 카드를 등록합니다"
    private let bt3 = "다른 결제수단으로 결제합니다"
    
    let request = BootpayBioRequest()
    
    
    init(frame: CGRect, bioPayload: BootBioPayload) {
        super.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
         
        self.backgroundColor = .blue
        
        let shadowView = UIView(frame: frame)
        shadowView.backgroundColor = .black
        shadowView.alpha = 0.3
        self.addSubview(shadowView)
        self.bioPayload = bioPayload
        
        initUI()
    }
     
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//view 관련
extension BootpayBioView {
    func initUI() {
        
        initSubviewComponents()
        initCardUI()
        initWebViewUI()
        
        
        Bootpay.shared.payload = nil
        slideUpCardUI()
        initBootpayEvent()
        
        goRequestData()
    }
    
    func initBootpayEvent() {
        
        
//        onClose {
//            Bootpay.removePaymentWindow()
//            self.hideActionView()
//        }
//        onCancel { data in
//            print("onCancel \(data)")
//        }
//        onError { data in
//            print("onError \(data)")
////            print(data)
//        }
////        onConfirm{ data in
////            if let confirm = Bootpay.shared.confirm {
////                if(confirm(data)) {
////                    Bootpay.transactionConfirm(data: data)
////                } else {
////                    Bootpay.removePaymentWindow()
////                }
////            }
//////            print("onConfirm \(data)")
//////            return false
////        }
//        onDone { data in
//            print("onDone \(data)")
//        }
        onEasyError { data in
//            print(data)
            print("onEasyError \(data)")
        }
        onEasyCancel{ data in
            print("onEasyCancel \(data)")
            self.hideActionView()
        }
        onEasySuccess { data in
            print("onEasySuccess \(data)")
            self.callbackEasySuccess(data: data)
        }
    }
    
    func initSubviewComponents() {
        hideBtn.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        hideBtn.addTarget(self, action: #selector(hideActionView), for: .touchUpInside)
        self.addSubview(hideBtn)
        
        var bottomPadding = CGFloat(0)
        if #available(iOS 11.0, *) {
            bottomPadding = self.safeAreaInsets.bottom
        }
        
        
        if isShowQuota() {
            bottomPadding += 60
        }
        
        //line1 + line2 + line 3 + 170 + 28 + 50 + 28
        if let payload = bioPayload {
            actionViewHeight = CGFloat(50 + 21 + payload.names.count * 25 + 21 + 25 * payload.prices.count + 36 + 170 + 28 + 50 + 28 + 10 + 6 + 60) + bottomPadding
        } else {
            actionViewHeight = self.frame.height * 0.72
        }
    }
    
    func initCardUI() {
        actionView.backgroundColor = BootpayBioConstants.bgColor
        actionView.frame = CGRect(
            x: 0,
            y: self.frame.height,
            width: self.frame.width,
            height: actionViewHeight
        )
        self.addSubview(actionView)
    }
    
    func initWebViewUI() {
        
        var bottomPadding = CGFloat(0)
        var topPadding = CGFloat(0)
        if #available(iOS 11.0, *) {
            topPadding = self.safeAreaInsets.top
            bottomPadding = self.safeAreaInsets.bottom
        } 
        
        bioWebView = BootpayBioWebView()
        bioWebView?.frame = CGRect(x: self.frame.width,
                        y: 0,
                        width: self.frame.width,
                        height: self.frame.height - bottomPadding - topPadding
        )
      
        bioWebView?.alpha = 0
        self.addSubview(bioWebView!)
    }
    
    func goWebViewPay(isPasswordPay: Bool) {
        isWebViewPay = true
        isShowCloseMsg = false
 
        Bootpay.shared.payload = bioPayload
        Bootpay.loadSessionValues()
        
        if(isPasswordPay == false) {
            self.bioPayload?.userToken = ""
        } else {
            self.bioPayload?.method = "easy_card"
        }
       
        slideLeftCardUI()
        self.bioWebView?.startBootpay()
    }
    
    
    func startBiometricPayUI(_ cardList: NSArray?) {
        self.cardInfoList.removeAll()
        
        if let cardList = cardList {
            for card in cardList {
                if let obj = card as? [String: AnyObject] {
                    let cardInfo = CardInfo()
                    cardInfo.setData(obj)
                    self.cardInfoList.append(cardInfo)
                }
            }
        }
        
        appendCardUI()
        if cardList != nil {
            self.bottomTitle.text = self.bt1
        } else {
            self.bottomTitle.text = self.bt2
        }
        
        if isEnableDeviceSoon == true {
            goBiometricAuth()
        }
    }
    
    
    func slideUpCardUI() {
        UIView.animate(withDuration: 0.3, animations: {
            self.actionView.frame = CGRect(x: 0,
                                           y: self.frame.height - self.actionViewHeight,
                                           width: self.frame.width,
                                           height: self.actionViewHeight)
        })
    }
    
    func slideLeftCardUI() {
        bioWebView?.alpha = 1
        UIView.animate(withDuration: 0.25, animations: {
            self.actionView.frame = CGRect(x: -self.frame.width,
                                           y: self.actionView.frame.origin.y,
                                           width: self.frame.width,
                                           height: self.actionView.frame.height)
             
            
            self.bioWebView?.frame = CGRect(x: 0,
                                   y: self.bioWebView?.frame.origin.y ?? 0,
                                   width: self.bioWebView?.frame.width ?? 0,
                                   height: self.bioWebView?.frame.height ?? 0)
        })
    }
    
    func slideRightCardUI() {
        UIView.animate(withDuration: 0.25, animations: {
            self.actionView.frame = CGRect(x: 0,
                                           y: self.actionView.frame.origin.y,
                                           width: self.frame.width,
                                           height: self.actionView.frame.height)
            
            self.bioWebView?.frame = CGRect(x: self.frame.width,
                                   y: 0,
                                   width: self.bioWebView?.frame.width ?? 0,
                                   height: self.bioWebView?.frame.height ?? 0)
        }, completion: { finished in
            self.bioWebView?.alpha = 0
        })
    }
    
    
    func appendCardUI() {
        guard let payload = bioPayload else { return }
        
        for sub in actionView.subviews {
            sub.removeFromSuperview()
        }
        
        let pgLabel = UILabel()
        pgLabel.text = PG.getName(payload.pg ?? "")
        pgLabel.textColor = BootpayBioConstants.fontColor
        actionView.addSubview(pgLabel)
        pgLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(30)
        }
        
        
        
        
        let btnCancel = UIButton()
        btnCancel.setTitle("취소", for: .normal)
        btnCancel.addTarget(self, action: #selector(hideActionView), for: .touchUpInside)
        btnCancel.contentHorizontalAlignment = .right
        btnCancel.setTitleColor(BootpayBioConstants.fontColor.withAlphaComponent(0.7), for: .normal)
        actionView.addSubview(btnCancel)
        btnCancel.snp.makeConstraints { (make) -> Void in
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
//        btnCancel.frame = CGRect(x: 10, y: 10, width: 100, height: 20)
        
        
        let line1 = UIView()
        line1.backgroundColor = BootpayBioConstants.fontColor.withAlphaComponent(0.1)
//            UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.1)
        actionView.addSubview(line1)
        line1.snp.makeConstraints{ (make) -> Void in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(50)
            make.height.equalTo(1)
        }
        
        for (index, value) in payload.names.enumerated() {
            if index == 0 {
                let left = UILabel()
                left.text = "결제정보"
                left.textColor = BootpayBioConstants.fontColor.withAlphaComponent(0.7)
                actionView.addSubview(left)
                left.snp.makeConstraints { (make) -> Void in
                    make.left.equalToSuperview().offset(10)
                    make.top.equalTo(line1).offset(11)
                    make.height.equalTo(30)
                }
            }

            let right = UILabel()
            right.text = value
            right.textColor = BootpayBioConstants.fontColor
            right.font = right.font.withSize(14.0)
            actionView.addSubview(right)
            right.snp.makeConstraints { (make) -> Void in
                make.right.equalToSuperview().offset(-10)
                make.top.equalTo(line1).offset(11 + index * 25)
                make.height.equalTo(20)
            }
        }
         
        
        
        let view2 = UIView()
        //        view.frame = CGRect(x: 0, y: 40, width: self.view.frame.width, height: 1)
        view2.backgroundColor = BootpayBioConstants.fontColor.withAlphaComponent(0.1)
        actionView.addSubview(view2)
        view2.snp.makeConstraints{ (make) -> Void in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(line1).offset(21 + payload.names.count * 25)
            make.height.equalTo(1)
        }
        
        for (index, priceInfo) in payload.prices.enumerated() {
            let left = UILabel()
            left.text = priceInfo.name
            left.textColor = BootpayBioConstants.fontColor.withAlphaComponent(0.7)

            left.font = left.font.withSize(14.0)
            actionView.addSubview(left)
            left.snp.makeConstraints { (make) -> Void in
                make.left.equalToSuperview().offset(100)
                make.top.equalTo(view2).offset(16 + 25 * index)
                make.height.equalTo(20)
            }
           
            let right = UILabel()
            right.text = priceInfo.price.comma() + "원"
            right.textColor = BootpayBioConstants.fontColor
            right.font = right.font.withSize(14.0)
            actionView.addSubview(right)
            right.snp.makeConstraints { (make) -> Void in
                make.right.equalToSuperview().offset(-10)
                make.top.equalTo(view2).offset(16 + index * 25)
                make.height.equalTo(20)
            }
        }
         
        let left = UILabel()
        left.text = "총 결제금액"
        left.textColor = BootpayBioConstants.fontColor
        left.font = UIFont.boldSystemFont(ofSize: 14)
        actionView.addSubview(left)
        left.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(100)
            make.top.equalTo(view2).offset(21 + 25 * payload.prices.count)
            make.height.equalTo(30)
        }

        let right = UILabel()
        right.text = payload.price.comma() + "원"
        right.textColor = BootpayBioConstants.fontColor
        right.textAlignment = .right
        right.font = UIFont.boldSystemFont(ofSize: 16.0)
        actionView.addSubview(right)
        right.snp.makeConstraints { (make) -> Void in
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(left)
            make.height.equalTo(20)
        }
              
        
        if isShowQuota() {
            let view = UIView()
            view.backgroundColor = BootpayBioConstants.fontColor.withAlphaComponent(0.1)
            actionView.addSubview(view)
            view.snp.makeConstraints{ (make) -> Void in
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.top.equalTo(left).offset(38)
                make.height.equalTo(1)
            }
            
            let left = UILabel()
            left.text = "할부설정"
            left.textColor = BootpayBioConstants.fontColor.withAlphaComponent(0.7)
            left.font = left.font.withSize(14.0)
            actionView.addSubview(left)
            left.snp.makeConstraints { (make) -> Void in
                make.left.equalToSuperview().offset(100)
                make.top.equalTo(view).offset(20)
                make.height.equalTo(20)
            }
            
            let pickerImg = UIImageView()
            pickerImg.image = UIImage.fromBundle("selectbox_icon")
            pickerImg.contentMode = .scaleAspectFit
            actionView.addSubview(pickerImg)
            pickerImg.snp.makeConstraints{ (make) -> Void in
                make.right.equalToSuperview().offset(-20)
                make.width.equalTo(20)
                make.top.equalTo(view).offset(20)
                make.height.equalTo(20)
            }

            btnPicker.setTitle(getPickerTitle(row: 0), for: .normal)
            btnPicker.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btnPicker.addTarget(self, action: #selector(showQuotaPicker), for: .touchUpInside)
            btnPicker.contentHorizontalAlignment = .right
            btnPicker.layer.borderColor = BootBioTheme.fontColor.withAlphaComponent(0.1).cgColor
            btnPicker.layer.borderWidth = 1
            btnPicker.layer.cornerRadius = 5
            btnPicker.setTitleColor(UIColor.black, for: .normal)
            btnPicker.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 35)
            actionView.addSubview(btnPicker)
            btnPicker.snp.makeConstraints{ (make) -> Void in
//                make.left.equalTo(100)
                make.right.equalToSuperview().offset(-10)
                make.width.equalTo(160)
                make.top.equalTo(view).offset(10)
                make.height.equalTo(40)
            }
        }
        

        let view3 = UIView()
        //        view.frame = CGRect(x: 0, y: 40, width: self.view.frame.width, height: 1)
        view3.backgroundColor = BootpayBioConstants.fontColor.withAlphaComponent(0.1)
        actionView.addSubview(view3)
        view3.snp.makeConstraints{ (make) -> Void in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            if isShowQuota() {
                make.top.equalTo(left).offset(98)
            } else {
                make.top.equalTo(left).offset(38)
            }
            make.height.equalTo(1)
        }
         
        cardSelectView = CardSelectView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 150))
        cardSelectView.sendable = self
        actionView.addSubview(cardSelectView)
        cardSelectView.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(view3).offset(20)
            make.width.equalToSuperview()
            make.height.equalTo(150)
        }
        cardSelectView.setData(cardInfoList)
        cardSelectView.addCarousel()



        let bottomTitle = UILabel()
        bottomTitle.text = self.bt2
        bottomTitle.font =  bottomTitle.font.withSize(14)
        bottomTitle.textColor = BootpayBioConstants.fontColor.withAlphaComponent(0.7)
        actionView.addSubview(bottomTitle)
        self.bottomTitle = bottomTitle
        bottomTitle.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(cardSelectView).offset(170)
            make.height.equalTo(20)
        }
 
        let btnBarcode = UIButton()
        if let image =  UIImage.fromBundle("barcode") {
            btnBarcode.setImage(image, for: .normal)
        }


        actionView.addSubview(btnBarcode)
        btnBarcode.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(bottomTitle).offset(30)
            make.width.height.equalTo(50)
        }
        btnBarcode.addTarget(self, action: #selector(clickBarcode), for: .touchUpInside)
    }
}



//MARK - UIPicker
extension BootpayBioView: UIPickerViewDataSource, UIPickerViewDelegate {
    @objc func showQuotaPicker() {
        picker = UIPickerView.init()
        picker.delegate = self
        picker.backgroundColor = BootBioTheme.bgColor
        picker.setValue(BootBioTheme.fontColor, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        if selectedQuotaRow != -1 { picker.selectRow(selectedQuotaRow, inComponent: 0, animated: true) }
        
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 360, width:
            UIScreen.main.bounds.size.width, height: 300)
        self.addSubview(picker)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 320, width: UIScreen.main.bounds.size.width, height: 45))
        toolBar.barStyle = .black
        toolBar.isTranslucent = true
        toolBar.items = [UIBarButtonItem.init(title: "완료", style: .done, target: self, action: #selector(onDoneQuotaPicker))]
        self.addSubview(toolBar)
    }
    
    @objc func onDoneQuotaPicker() {
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
    }
    
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bioPayload?.extra?.quotas.count ?? 0
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return getPickerTitle(row: row)
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedQuotaRow = row
        btnPicker.setTitle(getPickerTitle(row: row), for: .normal)
    }
       
    
    func getPickerTitle(row: Int) -> String {
        if let quotas = bioPayload?.extra?.quotas {
            if quotas.count <= row { return "" }
            if quotas[row] == 0 { return "일시불" }
            else { return "\(quotas[row])개월" }
        }
        return ""
    }
    
    func isShowQuota() -> Bool {
        if let payload = bioPayload, let quotas = bioPayload?.extra?.quotas {
            return payload.price >= 50000 && quotas.count > 0
        }
        return false
    }
}


//MARK - bootpay protocol
extension BootpayBioView {
    func easyCancel(_ action: @escaping ([String : Any]) -> Void) -> Void {
        Bootpay.shared.easyCancel = action
    }
    
    func easySuccess(_ action: @escaping ([String : Any]) -> Void) -> Void {
        Bootpay.shared.easySuccess = action
    }
    
    func easyError(_ action: @escaping ([String : Any]) -> Void) -> Void {
        Bootpay.shared.easyError = action
    }
    
    func onReady(_ action: @escaping ([String : Any]) -> Void) -> Void {
        Bootpay.shared.ready = action
    }
    
    func onDone(_ action: @escaping ([String : Any]) -> Void) -> Void {
        Bootpay.shared.done = action
    }
    
    func onConfirm(_ action: @escaping ([String : Any]) -> Bool) -> Void {
        Bootpay.shared.confirm = action
    }
    
    func bootpayConfirm(data: [String : Any]) {
        if let confirm = Bootpay.shared.confirm {
            if(confirm(data)) {
                self.request.transactionConfirmRequest(
                    view: self,
                    bioPayload: self.bioPayload!,
                    data: data) { result, data in
                        if(result == true) {
                            Bootpay.shared.done?(data as! [String: AnyObject])
                        } else {
                            Bootpay.shared.error?(data as! [String: AnyObject])
                        }
                        self.hideActionView()
                }
            } else {
                self.hideActionView()
            }
        }
    }
    
    func onError(_ action: @escaping ([String : Any]) -> Void) -> Void {
        Bootpay.shared.error = action
    }
    
    func onCancel(_ action: @escaping ([String : Any]) -> Void) -> Void {
        Bootpay.shared.cancel = action
    }
    
    func onClose(_ action: @escaping () -> Void) -> Void {
        Bootpay.shared.close = action
    }
    
    func onEasyCancel(_ action: @escaping ([String : Any]) -> Void) -> Void {
        Bootpay.shared.easyCancel = action
    }
    
    func onEasyError(_ action: @escaping ([String : Any]) -> Void) -> Void {
        Bootpay.shared.easyError = action
    }
    
    func onEasySuccess(_ action: @escaping ([String : Any]) -> Void) -> Void {
        Bootpay.shared.easySuccess = action
    }
    
    
    func getOTPValue(_ biometricSecretKey: String, serverTime: Int) -> String {
        if let data = biometricSecretKey.base32DecodedData {
            if let totp = TOTP(secret: data, digits: 8, timeInterval: 30, algorithm: .sha512) {
                if let otpString = totp.generate(secondsPast1970: serverTime) {
                    return otpString;
                }
            }
        }
        return "";
    }
    
    func callbackEasySuccess(data: [String : Any]) {
        if (self.bioWebView?.requestType == BootpayBioConstants.REQUEST_TYPE_VERIFY_PASSWORD) {
            if let sub = data["data"], let token = (sub as! [String: Any])["token"] {
                registerBioAble(token: token as! String)
            }
        } else if(self.bioWebView?.requestType == BootpayBioConstants.REQUEST_TYPE_VERIFY_PASSWORD_FOR_PAY) {
            if let sub = data["data"], let token = (sub as! [String: Any])["token"] {
                cardPayRequest(token as? String, walletId: cardInfoList[selectedCardIndex].wallet_id)
            }
        } else if(self.bioWebView?.requestType == BootpayBioConstants.REQUEST_TYPE_REGISTER_CARD) {
            slideRightCardUI()
            cardWalletList()
        } else if(self.bioWebView?.requestType == BootpayBioConstants.REQUEST_TYPE_PASSWORD_CHANGE) {
            slideRightCardUI()
            cardWalletList()
        } else if(self.bioWebView?.requestType == BootpayBioConstants.REQUEST_TYPE_ENABLE_DEVICE) {
            isEnableDeviceSoon = true
            if let sub = data["data"], let token = (sub as! [String: Any])["token"] {
                registerBioAble(token: token as! String)
            }
        }
    }
}

//logic 관련
extension BootpayBioView : BootpayBioProtocol {
    
    @objc func hideActionView() {
        isShowCloseMsg = true
        
        UIView.animate(withDuration: 0.25, animations: {
            self.actionView.frame = CGRect(x: 0,
                                           y: self.frame.height,
                                           width: self.frame.width,
                                           height: self.actionViewHeight)
            
            self.bioWebView?.frame = CGRect(x: 0,
                                   y: self.frame.height,
                                   width: self.bioWebView?.frame.width ?? 0,
                                   height: self.bioWebView?.frame.height ?? 0)
        }, completion: { finished  in
            Bootpay.removePaymentWindow() 
        })
    }
    
    
    @objc func goBiometricAuth() {
           
        BioMetricAuthenticator.shared.allowableReuseDuration = nil
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { [weak self] (result) in
 
        switch result {
            case .success( _):
                self?.cardPayRequest(nil, walletId: self?.cardInfoList[self?.selectedCardIndex ?? 0].wallet_id ?? "")
               
            case .failure(let error):
                switch error {
                   // device does not support biometric (face id or touch id) authentication
                case .biometryNotAvailable:
                    if let alert = self?.initAlert() {
                        alert.showError("", subTitle: error.message(), closeButtonTitle: "확인", animationStyle: .bottomToTop)
                    }
                    break
                case .biometryNotEnrolled:
                    self?.showGotoSettingsAlert(message: error.message())
                    break
                case .fallback:
                    print("fallback")
    //                   self?.txtUsername.becomeFirstResponder() // enter username password manually
                       // Biometry is locked out now, because there were too many failed attempts.
                   // Need to enter device passcode to unlock.
                case .biometryLockedout:
                    
                    if let alert = self?.initAlert() {
                        alert.showEdit("인식 실패", subTitle: "Touch ID 인식에 여러 번 실패하여,\n비밀번호로 결제합니다.", closeButtonTitle: "확인", animationStyle: .bottomToTop).setDismissBlock {
                            
                            self?.bioWebView?.requestType = BootpayBioConstants.REQUEST_TYPE_VERIFY_PASSWORD_FOR_PAY
                            self?.slideLeftCardUI()
                            self?.bioWebView?.verifyPassword(self!.bioPayload!)
                        }
                    }
                    break
                case .canceledBySystem, .canceledByUser:
                    break
                   // show error for any other reason
                default:
    //                self?.showErrorAlert(message: error.message())
                    break
                   
                }
            }
        }
    }
    
    func isEnableBioPayThisDevice() -> Bool {
        
        return BootpayDefaultHelper.getString(key: "biometric_secret_key").count > 0 && BootpayDefaultHelper.getInt(key: "use_device_biometric") == 1 && BootpayDefaultHelper.getInt(key: "use_biometric") == 1
    }
    
    
    
    @objc func clickBarcode() {
        goClickCard(cardSelectView.scalingCarousel.lastCurrentCenterCellIndex?.row ?? 0)
    }
    
    
    @objc public func lastIndexChanged(_ index: Int) {
        if index < cardInfoList.count {
            self.bottomTitle.text = self.bt1
        } else if index == cardInfoList.count {
            self.bottomTitle.text = self.bt2
        } else if index == cardInfoList.count + 1 {
            self.bottomTitle.text = self.bt3
        }
    }
    
    @objc public func clickCard(_ tag: Int) {
        goClickCard(tag)
    }
    
    func goClickCard(_ index: Int) {
        if index < cardInfoList.count {
            isWebViewPay = false
            //결제수단 선택
            self.selectedCardIndex = index
            if isEnableBioPayThisDevice() {
                goBiometricAuth()
            } else {
                goEnableThisDevice()
            }
        } else if index == cardInfoList.count {
            //new card
            goBiometricAddNewCard()
        } else if index == cardInfoList.count + 1 {
            //etc
            goWebViewPay(isPasswordPay: false)
        }
    }
    
    func goBiometricAddNewCard() {
        self.bioWebView?.requestType = BootpayBioConstants.REQUEST_TYPE_REGISTER_CARD
        slideLeftCardUI()
        self.bioWebView?.alpha = 1.0
        if let bioPayload = bioPayload {
            self.bioWebView?.registerCard(bioPayload)
        }
    }
}


//http request 관련
extension BootpayBioView {
    func goRequestData() {
//        cardWalletList()
        currentDeviceBioType = BioMetricAuthenticator.canAuthenticate()
        if(currentDeviceBioType) {
            cardWalletList()
        } else {
            goWebViewPay(isPasswordPay: true)
        }
    }
    
    func registerBioOTP(key: String, serverTime: Int) {
        
        let value = self.getOTPValue(key, serverTime: serverTime)
        self.request.registerBioOTP(
            view: self,
            otp: value,
            bioPayload: self.bioPayload!) { result, value in
                
                if(result == true) {
                    
                    //카드리스트를 요청 후
                    self.slideRightCardUI()
                    self.cardWalletList()
                } else {
                    if let jsonString = String(data: value as! Data, encoding: String.Encoding.utf8), let json = jsonString.convertToDictionary() {
                        if let code = json["code"] as? Int, let msg = json["message"] as? String {
                            let alert = self.initAlert()
                            alert.showError("에러코드1: \(code)", subTitle: msg, animationStyle: .bottomToTop).setDismissBlock {
                                self.hideActionView()
                            }
                        }
                    }
                }
        }
    }
    
    func registerBioAble(token: String) {
        request.registerBioAble(
            view: self,
            token: token,
            bioPayload: self.bioPayload!) { result, value in
                
                if(result == true) {
                    if let data = value as? [String: AnyObject] {
                        if let biometric_secret_key = data["biometric_secret_key"] as? String, let biometric_device_id = data["biometric_device_id"] as? String, let server_unixtime = data["server_unixtime"] as? CLong {
                            
                            
                           BootpayDefaultHelper.setValue("biometric_secret_key", value: biometric_secret_key)
                           BootpayDefaultHelper.setValue("biometric_device_id", value: biometric_device_id)
                            
                            self.slideRightCardUI()
                            
                            self.registerBioOTP(key: biometric_secret_key, serverTime: server_unixtime)
                        }
                    }
                  
                } else {
                    if let jsonString = String(data: value as! Data, encoding: String.Encoding.utf8), let json = jsonString.convertToDictionary() {
                        if let code = json["code"] as? Int, let msg = json["message"] as? String {
                            let alert = self.initAlert()
                            alert.showError("에러코드2: \(code)", subTitle: msg, animationStyle: .bottomToTop).setDismissBlock {
                                self.hideActionView()
                            }
                        }
                    }
                }
        }
    }
    
    
    func cardWalletList() {
        request.cardWalletList(bioPayload: bioPayload) { result, value in
            if(result == true) {
                guard let res = value as? [String: AnyObject] else { return }
                guard let data = res["data"] as? [String: AnyObject] else { return }
                guard let user = data["user"] as? [String: AnyObject] else { return }
                guard let wallets = data["wallets"] as? [String: AnyObject] else { return }
           
                if let server_unixtime = user["server_unixtime"] as? CLong {
                    self.payServerUnixtime = server_unixtime
                }
                 
                
               self.startBiometricPayUI(wallets["card"] as? NSArray)
            } else {
                if let jsonString = String(data: value as! Data, encoding: String.Encoding.utf8), let json = jsonString.convertToDictionary() {
                    if let code = json["code"] as? Int, let msg = json["message"] as? String {
                        let alert = self.initAlert()
                        alert.showError("에러코드4: \(code)", subTitle: msg, animationStyle: .bottomToTop).setDismissBlock {
                            self.hideActionView()
                        }
                    }
                }
            }
        }
    }
    
    
    func cardPayRequest(_ token: String?, walletId: String) {
        request.cardPayRequest(
            view: self,
            bioPayload: bioPayload,
            token: token,
            walletId: walletId,
            serverTime: self.payServerUnixtime) { (result, value) in
                if(result == true) {
                    guard let res = value as? [String: AnyObject] else { return }
                    self.bootpayConfirm(data: res)
//                    Bootpay.goConfirm(res)
                } else {
                    if let jsonString = String(data: value as! Data, encoding: String.Encoding.utf8), let json = jsonString.convertToDictionary() {
                        if let code = json["code"] as? Int, let msg = json["message"] as? String {
                            self.showDeleteAlert(
                                title: "에러코드: \(code)",
                                message: "\(msg)\n등록된 결제수단 정보를 초기화 합니다.",
                                walletId: walletId
                            )
                        }
                    }
                }
        }
    }
    
    func deleteWalletRequest(walletId: String) {
        request.deleteWalletRequest(
            view: self,
            userToken: self.bioPayload?.userToken ?? "",
            walletId: walletId) { (result, value) in
                if(result == true) {
                    self.hideActionView()
                } else {
                    if let jsonString = String(data: value as! Data, encoding: String.Encoding.utf8), let json = jsonString.convertToDictionary() {
                        if let code = json["code"] as? Int, let msg = json["message"] as? String {
                            let alert = self.initAlert()
                            alert.showError("에러코드5: \(code)", subTitle: msg, animationStyle: .bottomToTop).setDismissBlock {
                                self.hideActionView()
                            }
                        }
                    }
                }
        }
    }
}


// MARK: - Alerts
extension BootpayBioView {
    
    func initAlert() -> SCLAlertView {
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: 300, showCircularIcon: false
        )
        return SCLAlertView(appearance: appearance)
    }
 
    func showDeleteAlert(title: String, message: String, OKTitle: String = "초기화", walletId: String) {
        let alert = initAlert()
        alert.showError(title, subTitle: message, closeButtonTitle: OKTitle, animationStyle: .bottomToTop).setDismissBlock {
            self.deleteWalletRequest(walletId: walletId)
        }
    }
 
    func showGotoSettingsAlert(message: String) {
        let alert = initAlert()
        alert.showEdit("설정하기", subTitle: message, closeButtonTitle: OKTitle, animationStyle: .bottomToTop ).setDismissBlock {

            let url = URL(string: UIApplicationOpenSettingsURLString)
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:])
            }
        }
    }

    func goEnableThisDevice() {
        let alert = initAlert()
        alert.showEdit("",
                       subTitle: "이 기기에서 결제할 수 있도록 설정합니다\n(최초 1회)",
                       closeButtonTitle: "설정",
                       animationStyle: .bottomToTop).setDismissBlock {

            self.bioWebView?.requestType = BootpayBioConstants.REQUEST_TYPE_ENABLE_DEVICE
            self.slideLeftCardUI()
            self.bioWebView?.verifyPassword(self.bioPayload!)
        }
    }
}
 
