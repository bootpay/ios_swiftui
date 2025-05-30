//
//  CardView.swift
//  SwiftyBootpay
//
//  Created by Taesup Yoon on 13/10/2020.
//

import UIKit
import SnapKit

@available(iOS 13.0, *)
class CardViewCell: ScalingCarouselCell {
    var cardName: UILabel!
    var cardNo: UILabel!
    var cardChip: UIImageView!
    var cardIconCircleBg: UIView!
    var cardIcon: UIImageView!
//    var type = 0 //0: 기존 카드, 1: 신규카드, 2: 다른 결제수단
    var btnClick: UIButton!
    var cardLabel: UILabel!
    var bioTheme = BioDefaultTheme()
    var bioThemeData: BioThemeData?
    
    
    public func setBioThemeData(_ data: BioThemeData) {
        self.bioThemeData = data
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        mainView = UIView(frame: contentView.bounds)
        
        
        contentView.addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            mainView.heightAnchor.constraint(equalToConstant: contentView.frame.width * 0.75)
            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        
        mainView.layer.borderColor = UIColor.gray.cgColor
        
         

        cardName = UILabel()
        cardName.font =  UIFont.boldSystemFont(ofSize: 15.0)
        mainView.addSubview(cardName)

        cardNo = UILabel()
        cardNo.font =  UIFont.boldSystemFont(ofSize: 15.0)
        cardNo.textAlignment = .right
        mainView.addSubview(cardNo)
        
        cardChip = UIImageView()
        cardChip.image = UIImage.fromBundle("card_chip")
        cardChip.contentMode = .scaleAspectFit
        mainView.addSubview(cardChip)
        
        cardIconCircleBg = UIView()
        cardIconCircleBg.layer.backgroundColor = UIColor.red.cgColor
        // circle의 radius를 width(height)의 반으로 설정하여 원 모양으로 만듬
        cardIconCircleBg.layer.cornerRadius = 18
        mainView.addSubview(cardIconCircleBg)
        // circle의 그림자 설정
//        cardIconCircleBg.layer.shadowOpacity = 0.5
//        cardIconCircleBg.layer.shadowRadius = 7
        
        
        cardIcon = UIImageView()
        cardIcon.image = UIImage.fromBundle("ico_plus")
//        cardIcon.alpha = 0.8
        cardIcon.contentMode = .scaleAspectFit
        mainView.addSubview(cardIcon)
        
        cardLabel = UILabel()
        cardLabel.textColor = .white
        cardLabel.font =  UIFont.boldSystemFont(ofSize: 16.0)
        cardLabel.textAlignment = .center
        cardLabel.text = "다른 결제수단"
        
//        if(BootpayBio.sharedBio.bioPayload?.isEditdMode == false) {
//            mainView.addSubview(cardLabel)
//        }
        mainView.addSubview(cardLabel)
        
        
        btnClick = UIButton()
//        mainView.addSubview(btnClick)
    }
    
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(data: WalletData?, tag: Int) {
        if let data = data {
            let colors = CardCode.getColor(code: data.batch_data?.card_company_code ?? "")
            
            if data.wallet_type == 0 {
                if let batch_data = data.batch_data {
                    mainView.backgroundColor = colors[0]
                    cardName.text = batch_data.card_company
                    cardName.textColor = colors[1]
                    cardNo.text = batch_data.card_no
                    cardNo.textColor = colors[1]
                }
            } else if data.wallet_type == 1 {
                mainView.backgroundColor = bioThemeData?.card1Color ?? bioTheme.newCardColor
            } else if data.wallet_type == 2 {
                mainView.backgroundColor = bioThemeData?.card2Color ?? bioTheme.blueColor
            }            
            
            cardName.snp.makeConstraints{ (make) -> Void in
                make.left.equalToSuperview().offset(20)
                make.top.equalToSuperview().offset(10)
                make.width.equalTo(100)
                make.height.equalTo(20)
            }
            
            cardNo.snp.makeConstraints{ (make) -> Void in
                make.right.equalToSuperview().offset(-20)
                make.bottom.equalToSuperview().offset(-15)
                make.height.equalTo(20)
            }
            
            cardChip.snp.makeConstraints{(make) -> Void in
                make.left.equalTo(cardName)
                make.top.equalTo(cardName).offset(30)
                make.width.equalTo(35)
                make.height.equalTo(25)
            }
            
            
            cardIconCircleBg.snp.makeConstraints{(make) -> Void in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-20)
                make.width.height.equalTo(36)
//                make.height.height.equalTo(36)
            }
            
            cardIcon.snp.makeConstraints{(make) -> Void in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-20)
                make.width.height.equalTo(18)
//                make.height.height.equalTo(18)
            }
            
            cardLabel.snp.makeConstraints{(make) -> Void in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(20)
                make.width.height.equalTo(40)
                make.width.height.equalToSuperview()
            }
            
            
            btnClick.tag = tag
            
            
            mainView.layer.borderWidth = data.wallet_type == 0 ? 0.5 : 1
            cardName.isHidden = data.wallet_type != 0
            cardNo.isHidden = data.wallet_type != 0
            cardChip.isHidden = data.wallet_type != 0
            cardIconCircleBg.isHidden = data.wallet_type == 0
            cardIcon.isHidden = data.wallet_type == 0
            cardLabel.isHidden = data.wallet_type == 0
            
            if(data.wallet_type == 1) {
          
                if #available(iOS 13.0, *) {
                    cardIcon.image = UIImage.fromBundle("ico_plus_outline")?.withTintColor(.white, renderingMode: .alwaysOriginal)
                } else {
                    // Fallback on earlier versions
                    cardIcon.image = UIImage.fromBundle("ico_plus_outline")
                }
                
                cardLabel.text = "새로운 카드 등록"
                cardLabel.textColor = bioThemeData?.cardText1Color ?? bioTheme.blueColor
                cardIconCircleBg.backgroundColor = bioThemeData?.cardText1Color ?? bioTheme.blueColor
                mainView.layer.borderColor = bioThemeData?.card1Color?.cgColor ?? bioTheme.newCardBorderColor.cgColor
            } else if(data.wallet_type == 2) {
                if let iconColor = bioThemeData?.cardIconColor {
                    if #available(iOS 13.0, *) {
                        cardIcon.image = UIImage.fromBundle("ico_card_outline")?.withTintColor(iconColor, renderingMode: .alwaysOriginal)
                    } else {
                        // Fallback on earlier versions
                        cardIcon.image = UIImage.fromBundle("ico_card_outline")
                    }
                } else {
                    cardIcon.image = UIImage.fromBundle("ico_card_outline")
                }
                  
                cardLabel.text = "다른 결제수단"
                cardLabel.textColor = bioThemeData?.cardText2Color ?? .white
                cardIconCircleBg.backgroundColor = bioThemeData?.cardText2Color ?? .white
                mainView.layer.borderColor = bioThemeData?.card2Color?.cgColor ?? bioTheme.blueColor.cgColor
            }
        }
        
    }
    
}
