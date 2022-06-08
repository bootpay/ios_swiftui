//
//  BootpayBioController.swift
//  bootpayBio
//
//  Created by Taesup Yoon on 2021/05/17.
//

import UIKit
import Alamofire
import JGProgressHUD
import LocalAuthentication
import ObjectMapper
import Bootpay

public protocol BootpayBioProtocol {
    func clickCard(_ index: Int)
    func longClickCard(_ index: Int)
    func lastIndexChanged(_ index: Int)
}

/**
 1. 카드리스트를 받아와서
 2. 카드가 없으면 등록을 하고
 3. 이 기기에서 활성화 되지 않았다면, 생체인증을 활성화 한다
                        - ((비밀번호만 수행가능)
 */

@objc open class BootpayBioController: UIViewController {
    var presenter: BootpayBioPresenter?
    
    
//    var bioPayload = BootBioPayload()
    var bioTheme = BootBioTheme()
    var bioWebView = BootpayBioWebView()
//    var useViewController = false
    
//    var bgView = UIView()
    var toolBar = UIToolbar()
    var picker  = UIPickerView()
    var btnPicker = UIButton()
//    var biometricData = BiometricData()
//    var selectedQuotaRow = -1
        
    
//    let hideBtn = UIButton()
    let actionView = UIView()
    var pay_server_unixtime = 0 //결제용
//    var bioAuthType = 1 //1: 결제, 2: 비밀번호로 결제, 3: 카드생성, 4: 카드삭제, 5: 이 기기에서 활성화
    var bottomTitle: UILabel?
    var payButton = UIButton()
    
    private let bt1 = "이 카드로 결제합니다"
    private let bt2 = "새로운 카드를 등록합니다"
    private let bt3 = "다른 결제수단으로 결제합니다"
    var selectedCardIndex = 0
//    var actionViewHeight = CGFloat(0)
    var walletList = [WalletData]()
    var isEnableDeviceSoon = false
    var currentDeviceBioType = false
    
    var cardSelectView: CardSelectView!
    let hud = JGProgressHUD()
    var isShowCloseMsg = true
    var isWebViewPay = false
    
    var isShowQuota: Bool {
        get {
            return (BootpayBio.sharedBio.bioPayload?.price ?? 0) >= 50000
//            if let extra = bioPayload.extra, let cardQuota = extra.cardQuota {
//                return bioPayload.price >= 50000 && Int(cardQuota) ?? 0 > 2
//            }
//            return false
        }
    }
    
    func initPresenter() {
        presenter = BootpayBioPresenter()
        presenter?.initPresenter(vc: self, webView: self.bioWebView)
//        presenter?.bioPayload = self.bioPayload
//        presenter?.bioWebView = self.bioWebView
//        presenter?.bioController = self
        
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = .darkGray
        BootpayBio.sharedBio.selectedCardQuota = -1
        initPresenter()
        initBioAuthenticate()
        initUI()
        presenter?.startBioPay()
    }
    
    func initBioAuthenticate() {
        currentDeviceBioType = BioMetricAuthenticator.canAuthenticate()
    }
    
//    open override func viewWil(_ animated: Bool) {
//        BootpayBio.sharedBio.debounceClose()
//        super.viewWillDisappear(animated)
//    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        BootpayBio.sharedBio.debounceClose()
    }
    
//    open override func viewWillDisappear(_ animated: Bool) {
//        BootpayBio.sharedBio.debounceClose()
//        super.viewWillDisappear(animated)
//    }
    
//    open override func viewwil(_ animated: Bool) {
//        print("")
//        BootpayBio.sharedBio.debounceClose()
//        super.viewWillAppear(animated)
//    }
}

//init UI
extension BootpayBioController {
    
    func initUI() {
        self.view.backgroundColor = .white
        
//        bgView.backgroundColor = .black
//        bgView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
//        bgView.alpha = 0.3
//        self.view.addSubview(bgView)
//
//
//        hideBtn.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 100)
//        hideBtn.addTarget(self, action: #selector(hideActionView), for: .touchUpInside)
//        self.view.addSubview(hideBtn)
        
        
//        var bottomPadding = CGFloat(0)
//        if #available(iOS 11.0, *) {
//            let window = UIApplication.shared.keyWindow
//            bottomPadding = window?.safeAreaInsets.bottom ?? 0.0
//        }
//        if isShowQuota{
//            bottomPadding += 100
//        }
         
//        actionViewHeight = 396 + CGFloat(max(BootpayBio.sharedBio.bioPayload?.names.count ?? 0, 1) * 23) + 16 + CGFloat(30 * (BootpayBio.sharedBio.bioPayload?.prices.count ?? 0)) + bottomPadding
        
        
        initCardUI()
        initWebViewUI()
    }
    
    func initCardUI() {
//        actionView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(actionView)
        actionView.translatesAutoresizingMaskIntoConstraints = false
        
        let constrains = [
            actionView.topAnchor.constraint(equalTo: self.view.safeTopAnchor),
            actionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            actionView.bottomAnchor.constraint(equalTo: self.view.safeBottomAnchor),
            actionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ]
        NSLayoutConstraint.activate(constrains)
    }
    
    func initWebViewUI() {
//        var bottomPadding = CGFloat(0.0)
//        if #available(iOS 11.0, *) {
//            let window = UIApplication.shared.keyWindow
//            bottomPadding = window?.safeAreaInsets.bottom ?? 0.0
//        }
        
//        bioWebView.payload = self.bioPayload
//        bioWebView.resizeFrame()
        
        self.view.addSubview(bioWebView)
        
        bioWebView.translatesAutoresizingMaskIntoConstraints = false
        
        let constrains = [
            bioWebView.topAnchor.constraint(equalTo: self.view.safeTopAnchor),
            bioWebView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bioWebView.bottomAnchor.constraint(equalTo: self.view.safeBottomAnchor),
            bioWebView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ]
        NSLayoutConstraint.activate(constrains)
    }
    
    func getPickerTitle(row: Int) -> String {
//        guard let extra = bioPayload.extra, let cardQuota = extra.cardQuota else {
//            return ""
//        }
//        let quota = Int(cardQuota) ?? 0
        
//        if extra.quotas.count <= row { return "" }
        if row == 0 { return "일시불" }
        else { return "\(row + 1)개월" }
    }
}

extension BootpayBioController {
    
    @objc func hideActionView() {
        isShowCloseMsg = true
        
    
        let dic = [
            "message": "사용자가 결제창을 닫았습니다",
            "error_code": "CLIENT_CLOSE_BIO_ACTIONSHEET",
            "event": "cancel"
        ]
        BootpayBio.sharedBio.cancel?(dic)
        BootpayBio.sharedBio.debounceClose()
//        BootpayBio.sharedBio.close?()
        BootpayBio.removePaymentWindow()
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        
//        if(useViewController == false) {
////            bgView.alpha = 0
//            bioWebView.alpha = 0
//            UIView.animate(withDuration: 0.25, animations: {
//                self.actionView.frame = CGRect(x: self.actionView.frame.origin.x,
//                                               y: self.view.frame.height,
//                                               width: self.view.frame.width,
//                                               height: self.actionView.frame.height)
//
//            }, completion: { finish in
//                self.view.removeFromSuperview()
//            })
//        } else {
//            self.dismiss(animated: true, completion: nil)
//        }
    }
    
}

extension BootpayBioController: BootpayBioProtocol {
    public func longClickCard(_ index: Int) {
        deleteCard(cardSelectView.scalingCarousel.lastCurrentCenterCellIndex?.row ?? 0)
    }
    
    @objc func clickPayButton() {
        goClickCard(cardSelectView.scalingCarousel.lastCurrentCenterCellIndex?.row ?? 0)
    }
    
    @objc public func clickCard(_ index: Int) {
        goClickCard(cardSelectView.scalingCarousel.lastCurrentCenterCellIndex?.row ?? 0)
    }
    
    func goClickCard(_ index: Int) {
        presenter?.goClickCard(index)
    }
    
    func deleteCard(_ index: Int) {
//        print("deleteCard \(index)")
        presenter?.deleteCard(index)
    }
    
    
//    func goBiometricAddNewCard() {
////        print("goBiometricAddNewCard");
////        self.bioWebView.requestType = BioConstants.REQUEST_ADD_CARD
////        slideLeftCardUI()
////        self.bioWebView.alpha = 1.0
//    }
    
    public func lastIndexChanged(_ index: Int) {
        if index < walletList.count {
            payButton.setTitle(self.bt1, for: .normal)
            //self.bottomTitle?.text = self.bt1
        } else if index == walletList.count {
            payButton.setTitle(self.bt2, for: .normal)
//            self.bottomTitle?.text = self.bt2
        } else if index == walletList.count + 1 {
            payButton.setTitle(self.bt3, for: .normal)
//            self.bottomTitle?.text = self.bt3
        }
//        payButton.setTitle(self.bottomTitle?, for: <#T##UIControl.State#>)
    }
    
//    func getOTPValue(_ biometricSecretKey: String, serverTime: Int) -> String {
//        if let data = biometricSecretKey.base32DecodedData {
//            if let totp = TOTP(secret: data, digits: 8, timeInterval: 30, algorithm: .sha512) {
//                if let otpString = totp.generate(secondsPast1970: serverTime) {
//                    return otpString;
//                }
//            }
//        }
//        return "";
//    }
}

extension BootpayBioController {
    func showCardView() {
        self.actionView.alpha = 1
        self.actionView.frame = CGRect(x: 0,
                                       y: 0,
                                       width: self.view.frame.width,
                                       height: self.view.frame.height)
        
//        UIView.animate(withDuration: 0.3, animations: {
//            self.actionView.frame = CGRect(x: 0,
//                                           y: self.view.frame.height - self.actionViewHeight,
//                                           width: self.view.frame.width,
//                                           height: self.actionViewHeight)
//        })
    }
    
    func hideCardView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.actionView.alpha = 0
            self.actionView.frame = CGRect(x: 0,
                                           y: self.view.frame.height,
                                           width: self.view.frame.width,
                                           height: self.view.frame.height)
        })
    }
    
    func hideWebView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.bioWebView.alpha = 0
        })
    }
    
    func showWebView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.bioWebView.alpha = 1
        })
    }
    
    func isShowWebView() -> Bool {
        return self.bioWebView.alpha == 1
    }
    
    func isShowCardView() -> Bool {
        return self.actionView.alpha == 1
    }
     
    func setWalletList(_ walletList: [WalletData]) {
//        if(walletList.isEmpty) { return }
            
        self.walletList.removeAll()
        self.walletList = walletList
        
        appendCardUI()
        
        if walletList.count == 0 {
            self.payButton.setTitle(self.bt2, for: .normal)
        } else {
            self.payButton.setTitle(self.bt1, for: .normal)
        }
    }
    
    func appendCardUI() {
//        guard let payload = bioPayload else { return }
        
        for sub in actionView.subviews {
            sub.removeFromSuperview()
        }
        
        //white view added
        let roundHeader = UIView()
        let bgWhite = UIView()
        actionView.addSubview(roundHeader)
        actionView.addSubview(bgWhite)
        roundHeader.backgroundColor = bioTheme.bgColor
        bgWhite.backgroundColor = bioTheme.bgColor
        
        roundHeader.layer.cornerRadius = 16
        roundHeader.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(60)
        }
        bgWhite.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(30)
            make.width.equalToSuperview()
            make.height.equalToSuperview().offset(-30)
        }
        
        
        
//        if let logo = bioTheme.logoImage {
//            let logoImage = UIImageView()
//            logoImage.image = logo
//            logoImage.contentMode = .scaleAspectFit
//            actionView.addSubview(logoImage)
//            logoImage.snp.makeConstraints { (make) -> Void in
//                make.left.equalToSuperview().offset(10)
//                make.top.equalToSuperview().offset(5)
//                make.height.equalTo(25)
//            }
//        } else {
//            let pgLabel = UILabel()
//            pgLabel.text = PG.getName(payload.pg ?? "")
//            pgLabel.textColor = bioTheme.fontColor
//            actionView.addSubview(pgLabel)
//            pgLabel.snp.makeConstraints { (make) -> Void in
//                make.left.equalToSuperview().offset(10)
//                make.top.equalToSuperview().offset(10)
//                make.height.equalTo(30)
//            }
//        }
        let pgLabel = UILabel()
        pgLabel.text = PG.getName(BootpayBio.sharedBio.bioPayload?.pg ?? "")
        pgLabel.textColor = bioTheme.fontColor
        actionView.addSubview(pgLabel)
        pgLabel.textAlignment = .center
        pgLabel.font = .boldSystemFont(ofSize: 20.0)
        pgLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(15)
            make.width.equalToSuperview()
            make.height.equalTo(30)
        }
        
        let btnImage = UIImage.fromBundle("close")
        let btnCancel = UIButton()
        btnCancel.setImage(btnImage , for: .normal)
//        btnCancel.setTitle("취소", for: .normal)
        btnCancel.addTarget(self, action: #selector(hideActionView), for: .touchUpInside)
        btnCancel.contentHorizontalAlignment = .right
        btnCancel.alpha = 0.6
//        btnCancel.setTitleColor(bioTheme.fontColor.withAlphaComponent(0.7), for: .normal)
        actionView.addSubview(btnCancel)
        btnCancel.snp.makeConstraints { (make) -> Void in
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(15)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        let line1 = UIView()
        line1.backgroundColor = bioTheme.fontColor.withAlphaComponent(0.1)
        actionView.addSubview(line1)
        line1.snp.makeConstraints{ (make) -> Void in
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(60)
            make.height.equalTo(1)
        }
        
//        print(payload.names.cou)
        
        if(BootpayBio.sharedBio.bioPayload?.names.count == 0) {
            addPriceView(index: 0, value: BootpayBio.sharedBio.bioPayload?.orderName ?? "")
        } else {
            for (index, value) in (BootpayBio.sharedBio.bioPayload?.names ?? []).enumerated() {
                addPriceView(index: index, value: value)
            }
        }
        
        //sub function start
        func addPriceView(index: Int, value: String) {
            if index == 0 {
                let left = UILabel()
                left.text = "결제정보"
                left.textColor = bioTheme.fontInfoColor
                left.font = left.font.withSize(15.0)
                actionView.addSubview(left)
                left.snp.makeConstraints { (make) -> Void in
                    make.left.equalToSuperview().offset(15)
                    make.top.equalTo(line1).offset(20)
                    make.height.equalTo(20)
                }
            }

            let right = UILabel()
            right.text = value
            right.textColor = bioTheme.fontColor
            if (index != 0) { right.textColor = bioTheme.fontOptionColor }
            right.font = right.font.withSize(15.0)
            actionView.addSubview(right)
            right.snp.makeConstraints { (make) -> Void in
                make.right.equalToSuperview().offset(-15)
                make.top.equalTo(line1).offset(20 + index * 23)
                make.height.equalTo(20)
            }
        }
        //sub function end
        
        
//        let view2 = UIView()
//        //        view.frame = CGRect(x: 0, y: 40, width: self.view.frame.width, height: 1)
//        view2.backgroundColor = bioTheme.fontColor.withAlphaComponent(0.1)
//        actionView.addSubview(view2)
//        view2.snp.makeConstraints{ (make) -> Void in
//            make.left.equalToSuperview()
//            make.right.equalToSuperview()
//            make.top.equalTo(line1).offset(21 + max(payload.names.count, 1) * 25)
//            make.height.equalTo(1)
//        }
        
        for (index, priceInfo) in (BootpayBio.sharedBio.bioPayload?.prices ?? []).enumerated() {
            let left = UILabel()
            left.text = priceInfo.name
            left.textColor = bioTheme.fontInfoColor
            left.font = left.font.withSize(15.0)
            actionView.addSubview(left)
            left.snp.makeConstraints { (make) -> Void in
                make.left.equalToSuperview().offset(15)
                make.top.equalTo(line1).offset(10 + max(BootpayBio.sharedBio.bioPayload?.names.count ?? 0, 1) * 23 + 16 + 30 * index)
                make.height.equalTo(20)
            }
           
            let right = UILabel()
            right.text = priceInfo.price.comma() + "원"
            right.textColor = bioTheme.fontColor
            right.font = right.font.withSize(15.0)
            actionView.addSubview(right)
            right.snp.makeConstraints { (make) -> Void in
                make.right.equalToSuperview().offset(-15)
                make.top.equalTo(line1).offset(10 + max(BootpayBio.sharedBio.bioPayload?.names.count ?? 0, 1) * 23 + 16 + index * 30)
                make.height.equalTo(20)
            }
        }
         
        let left = UILabel()
        left.text = "총 결제금액"
        left.textColor = bioTheme.fontInfoColor
        left.font = left.font.withSize(16.0)
        actionView.addSubview(left)
        left.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(line1).offset(11 + max(BootpayBio.sharedBio.bioPayload?.names.count ?? 0, 1) * 23 + 16 + 30 * (BootpayBio.sharedBio.bioPayload?.prices.count ?? 0))
            make.height.equalTo(25)
        }

        let right = UILabel()
        right.text = (BootpayBio.sharedBio.bioPayload?.price ?? Double(0)).comma() + "원"
        right.textColor = bioTheme.blueColor
        right.textAlignment = .right
        right.font = UIFont.boldSystemFont(ofSize: 20.0)
        actionView.addSubview(right)
        right.snp.makeConstraints { (make) -> Void in
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(left)
            make.height.equalTo(25)
        }
             
       
        

//        let view3 = UIView()
//        view3.backgroundColor = bioTheme.fontColor.withAlphaComponent(0.1)
//        actionView.addSubview(view3)
//        view3.snp.makeConstraints{ (make) -> Void in
//            make.left.equalToSuperview()
//            make.right.equalToSuperview()
//            if isShowQuota {
//                make.top.equalTo(left).offset(105)
//            } else {
//                make.top.equalTo(left).offset(45)
//            }
//            make.height.equalTo(1)
//        }
        
        let cardBGView = UIView()
        cardBGView.backgroundColor = bioTheme.cardBgColor
        actionView.addSubview(cardBGView)
        cardBGView.snp.makeConstraints{ (make) -> Void in
//            make.centerX.equalToSuperview()
            make.top.equalTo(left).offset(45)
            make.width.equalToSuperview()
            make.height.equalTo(200)
        }
        
         
        cardSelectView = CardSelectView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 160))
        cardSelectView.sendable = self
        actionView.addSubview(cardSelectView)
        cardSelectView.snp.makeConstraints{ (make) -> Void in
//            make.centerX.equalToSuperview()
            make.top.equalTo(cardBGView).offset(20)
            make.width.equalToSuperview()
            make.height.equalTo(160)
        }
        cardSelectView.setData(self.walletList)
        cardSelectView.addCarousel()
        
        
        if isShowQuota {
//            let view = UIView()
//            view.backgroundColor = bioTheme.fontColor.withAlphaComponent(0.1)
//            actionView.addSubview(view)
//            view.snp.makeConstraints{ (make) -> Void in
//                make.left.equalToSuperview()
//                make.right.equalToSuperview()
//                make.top.equalTo(cardBGView).offset(220)
//                make.height.equalTo(1)
//            }
            
//            let left = UILabel()
//            left.text = "할부설정"
//            left.textColor = bioTheme.fontColor.withAlphaComponent(0.7)
//            left.font = left.font.withSize(14.0)
//            actionView.addSubview(left)
//            left.snp.makeConstraints { (make) -> Void in
//                make.left.equalToSuperview().offset(100)
//                make.top.equalTo(cardBGView).offset(220)
//                make.height.equalTo(20)
//            }
            
            let pickerImg = UIImageView()
            pickerImg.image = UIImage.fromBundle("selectbox_icon")
            pickerImg.contentMode = .scaleAspectFit
            actionView.addSubview(pickerImg)
            pickerImg.snp.makeConstraints{ (make) -> Void in
//                make.ght.equalToSuperview().offset(-20)
                make.right.equalToSuperview().offset(-90)
                make.width.equalTo(20)
                make.top.equalTo(cardBGView).offset(230)
                make.height.equalTo(20)
            }

            btnPicker.setTitle(getPickerTitle(row: 0), for: .normal)
            btnPicker.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btnPicker.addTarget(self, action: #selector(showQuotaPicker), for: .touchUpInside)
            btnPicker.contentHorizontalAlignment = .center
            btnPicker.layer.borderColor = bioTheme.fontColor.withAlphaComponent(0.1).cgColor
            btnPicker.layer.borderWidth = 1
            btnPicker.layer.cornerRadius = 5
            btnPicker.setTitle("일시불", for: .normal)
            btnPicker.setTitleColor(bioTheme.fontColor, for: .normal)
            btnPicker.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
            actionView.addSubview(btnPicker)
            btnPicker.snp.makeConstraints{ (make) -> Void in
//                make.left.equalTo(100)
                make.left.equalToSuperview().offset(80)
                make.width.equalToSuperview().offset(-160)
                make.top.equalTo(cardBGView).offset(220)
                make.height.equalTo(40)
            }
        }
        
        
        payButton = UIButton()
        payButton.setTitle(self.bt2, for: .normal)
        payButton.layer.cornerRadius = 5
        payButton.setBackgroundColor(bioTheme.blueColor,  cornerRadius: 6.0, for: .normal)
        payButton.addTarget(self, action: #selector(clickPayButton), for: .touchUpInside)
        actionView.addSubview(payButton)
        payButton.bottomAnchor.constraint(equalTo: self.view.safeBottomAnchor).isActive = true
        payButton.snp.makeConstraints{ (make) -> Void in
//            make.centerX.equalToSuperview()
            make.left.equalTo(15)
            make.right.equalToSuperview().offset(-15)
//            make.bottom.a
//            make.bottom.equalTo(self.view).offset(-10)
//            if(isShowQuota) {
//                make.top.equalTo(cardSelectView).offset(300)
//            } else {
//                make.top.equalTo(cardSelectView).offset(200)
//            }
            
            make.height.equalTo(60)
        }
        

//        let bottomTitle = UILabel()
//        bottomTitle.text = self.bt2
//        bottomTitle.font =  bottomTitle.font.withSize(14)
//        bottomTitle.textColor = bioTheme.fontColor.withAlphaComponent(0.7)
//        actionView.addSubview(bottomTitle)
//        self.bottomTitle = bottomTitle
//        bottomTitle.snp.makeConstraints{ (make) -> Void in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(cardSelectView).offset(210)
//            make.height.equalTo(20)
//        }
//
//        let btnBarcode = UIButton()
//        if let image =  UIImage.fromBundle("barcode") {
//            btnBarcode.setImage(image, for: .normal)
//        }
//
//        actionView.addSubview(btnBarcode)
//        btnBarcode.snp.makeConstraints{ (make) -> Void in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(bottomTitle).offset(30)
//            make.width.height.equalTo(50)
//        }
//        btnBarcode.addTarget(self, action: #selector(clickBarcode), for: .touchUpInside)
    }
}

 
  

//picker
extension BootpayBioController: UIPickerViewDataSource, UIPickerViewDelegate {
    @objc func showQuotaPicker() {
        picker = UIPickerView.init()
        picker.delegate = self
        picker.backgroundColor = bioTheme.bgColor
        picker.setValue(bioTheme.fontColor, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
//        Bootpay.shared
         
        if BootpayBio.sharedBio.selectedCardQuota != -1 { picker.selectRow(BootpayBio.sharedBio.selectedCardQuota, inComponent: 0, animated: true) }
        
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width:
            UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(picker)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 45))
        toolBar.barStyle = .blackTranslucent
        toolBar.items = [UIBarButtonItem.init(title: "완료", style: .done, target: self, action: #selector(onDoneQuotaPicker))]
        self.view.addSubview(toolBar)
    }
    
    @objc func onDoneQuotaPicker() {
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
    }
    
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return 5
        guard let extra = BootpayBio.sharedBio.bioPayload?.extra, let cardQuota = extra.cardQuota else { return 12 }
        return Int(cardQuota) ?? 12
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print(getPickerTitle(row: row))
        return getPickerTitle(row: row)
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        quotaTextField?.text = "\(String(describing: bioPayload?.quotas[row]))"
//        if let payload = bioPayload {
//            btnPicker.setTitle("\(row)", for: .normal)
//
//        }
        BootpayBio.sharedBio.selectedCardQuota = row
        btnPicker.setTitle(getPickerTitle(row: row), for: .normal)
    }
}

extension BootpayBioController {
    func showAlert(title: String, message: String) {
        let okAction = AlertAction(title: OKTitle)
        let alertController = getAlertViewController(type: .alert, with: title, message: message, actions: [okAction], showCancel: false) { (button) in
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func showDeleteAlert(title: String, message: String, OKTitle: String = "초기화", wallet_id: String) {
        let okAction = AlertAction(title: OKTitle)
        let alertController = getAlertViewController(type: .alert, with: title, message: message, actions: [okAction], showCancel: true) { (button) in
            if(button == OKTitle) {
//                self.goDeleteCardAll(wallet_id: wallet_id)
            }
//            self.dismiss()
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func showLoginSucessAlert() {
        showAlert(title: "Success", message: "Login successful")
    }
    
    func showErrorAlert(message: String) {
        showAlert(title: "Error", message: message)
    }
    
    func showGotoSettingsAlert(message: String) {
        let settingsAction = AlertAction(title: "Go to settings")
        
        let alertController = getAlertViewController(type: .alert, with: "Error", message: message, actions: [settingsAction], showCancel: true, actionHandler: { (buttonText) in
            if buttonText == CancelTitle { return }
            
            // open settings
            #if swift(>=4.2)
            let url = URL(string: UIApplication.openSettingsURLString)
            #else
            let url = URL(string: UIApplicationOpenSettingsURLString)
            #endif
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:])
            }
            
        })
        present(alertController, animated: true, completion: nil)
    }
    
//    func goEnableThisDevice() {
//        let okAction = AlertAction(title: OKTitle)
//        let alertController = getAlertViewController(type: .alert, with: title, message: "이 기기에서 결제할 수 있도록 설정합니다\n(최초 1회)", actions: [okAction], showCancel: true) { (btnTitle) in
//            if btnTitle == OKTitle {
//                self.bioWebView.requestType = BioConstants.REQUEST_ADD_BIOMETRIC
////                self.goBiometricAuth()
//
////                self.bioWebView.requestType = BioConstants.REQUEST_TYPE_ENABLE_DEVICE
////                self.slideLeftCardUI()
////                if let bioPayload = self.bioPayload { self.bioWebView.verifyPassword(bioPayload) }
//            }
//          }
//        present(alertController, animated: true, completion: nil)
//    }
}
 
