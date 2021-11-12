//
//  CardSelectView.swift
//  SwiftyBootpay
//
//  Created by Taesup Yoon on 13/10/2020.
//
 
import Bootpay

class CardCell: ScalingCarouselCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        mainView = UIView(frame: contentView.bounds)
        contentView.addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objc public class CardSelectView: BTView {
    
    var data: [CardInfo]?
    
    // MARK: - Properties (Private)
    public var scalingCarousel: ScalingCarouselView!
    
    var sendable: BootpayBioProtocol?

    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
    }
     
    public func setData(_ data: [CardInfo]) {
        self.data = data
    }
    
    // MARK: - Configuration
    
    public func addCarousel() {
        
        let inset = self.frame.width * 0.2
        let height = self.frame.height
         
        scalingCarousel = ScalingCarouselView(withFrame: frame, andInset: inset)
        scalingCarousel.scrollDirection = .horizontal
        scalingCarousel.sendable = self.sendable
        scalingCarousel.dataSource = self
        scalingCarousel.delegate = self
        scalingCarousel.translatesAutoresizingMaskIntoConstraints = false
        scalingCarousel.backgroundColor = .clear
        
        scalingCarousel.register(CardViewCell.self, forCellWithReuseIdentifier: "cell")
        
        self.addSubview(scalingCarousel)
        
//         Constraints
        scalingCarousel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1).isActive = true
        scalingCarousel.heightAnchor.constraint(equalToConstant: height).isActive = true
        scalingCarousel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        scalingCarousel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    }
}

extension CardSelectView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = data?.count ?? 0
        return count + 2
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        
        
        if let scalingCell = cell as? CardViewCell {
            if indexPath.row < data?.count ?? 0 {
                if let data = self.data {
                    scalingCell.setData(data: data[indexPath.row])
                }
            } else if indexPath.row == data?.count ?? 0 {
                let temp = CardInfo()
                temp.card_type = 1
                scalingCell.setData(data: temp)
            } else if indexPath.row == (data?.count ?? 0) + 1 {
                let temp = CardInfo()
                temp.card_type = 2
                scalingCell.setData(data: temp)
            }
            
            cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellClick(_:))))
        }
        
        DispatchQueue.main.async {
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
        }

        return cell
    }
    
    @objc func cellClick(_ sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: scalingCarousel)
        let indexPath = scalingCarousel.indexPathForItem(at: location)
       
        if let index = indexPath {
            sendable?.clickCard(index.row)
        }
    }
    
    
    @objc func cardClick(sender: UIButton) {
        sendable?.clickCard(sender.tag)
    }
}

extension CardSelectView: UICollectionViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scalingCarousel.didScroll()
    }
     
}
