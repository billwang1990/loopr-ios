//
//  AssetBalanceTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AssetBalanceTableViewCell: UITableViewCell {

    @IBOutlet weak var balanceLabel: TickerLabel!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var marketView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconView: IconView!
    @IBOutlet weak var marketLabel: UILabel!
    @IBOutlet weak var marketDisplayLabel: UILabel!
    @IBOutlet weak var marketBalanceLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var marketButton: UIButton!
    
    var asset: Asset?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        balanceLabel.setFont(UIFont.init(name: FontConfigManager.shared.getRegular(), size: 27)!)
        balanceLabel.animationDuration = 0.25
        balanceLabel.textAlignment = NSTextAlignment.center
        balanceLabel.initializeLabel()
        balanceLabel.theme_backgroundColor = GlobalPicker.backgroundColor
        balanceLabel.textColor = Themes.isNight() ? UIColor.white : UIStyleConfig.defaultTintColor
        
        marketView.layer.cornerRadius = 20
        marketButton.layer.borderColor = UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1).cgColor
        marketButton.layer.cornerRadius = 20
        marketButton.layer.borderWidth = 1
        self.theme_backgroundColor = ["#fff", "#000"]
    }

    func update() {
        if let asset = self.asset {
            balanceLabel.setText(asset.balance.description, animated: false)
            displayLabel.text = asset.display
            if asset.icon != nil {
                iconImageView.image = asset.icon
                iconImageView.isHidden = false
                iconView.isHidden = true
            } else {
                iconView.isHidden = false
                iconView.symbol = asset.symbol
                iconView.symbolLabel.text = asset.symbol
                iconImageView.isHidden = true
            }
            if asset.symbol.lowercased() == "eth" || asset.symbol.lowercased() == "weth" {
                marketLabel.text = "Ethereum"
                if let price = PriceQuoteDataManager.shared.getPriceBySymbol(of: "ETH") {
                    marketDisplayLabel.text = price.currency
                }
                changeLabel.isHidden = true
                marketBalanceLabel.isHidden = true
            } else {
                let tradingPair = asset.symbol + "/WETH"
                if let market = MarketDataManager.shared.getMarket(by: tradingPair) {
                    marketLabel.text = market.description
                    marketBalanceLabel.text = market.balance.description
                    changeLabel.text = market.changeInPat24
                    changeLabel.textColor = UIStyleConfig.getChangeColor(sign: market.changeInPat24.first?.description ?? "+")
                    marketDisplayLabel.text = market.display
                }
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    class func getCellIdentifier() -> String {
        return "AssetBalanceTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 244
    }
}
