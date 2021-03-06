//
//  ConfirmationResultViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/16.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class ConfirmationResultViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var placedLabel: UILabel!
    @IBOutlet weak var placeInfoLabel: UILabel!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Need TokenA
    var needATipLabel: UILabel = UILabel()
    var needAInfoLabel: UILabel = UILabel()
    var needAUnderline: UIView = UIView()
    // Need TokenB
    var needBTipLabel: UILabel = UILabel()
    var needBInfoLabel: UILabel = UILabel()
    
    var order: OriginalOrder?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        self.navigationItem.title = NSLocalizedString("Confirmation", comment: "")
        configLabels()
        configRows()
        configButtons()
    }
    
    func configLabels() {
        placedLabel.font = UIFont(name: FontConfigManager.shared.getBold(), size: 40.0)
        placedLabel.text = NSLocalizedString("Placed!", comment: "")
        placeInfoLabel.font = UIFont(name: FontConfigManager.shared.getRegular(), size: 20.0)
        placeInfoLabel.textColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1)
        if isBalanceEnough() {
            placeInfoLabel.text = NSLocalizedString("Congradualations! Your order has been submited!", comment: "")
        } else {
            placeInfoLabel.text = NSLocalizedString("Your order has been submited!However, please make sure you have enough balance to complete the trade.", comment: "")
        }
    }
    
    func configRows() {
        
        guard !isBalanceEnough() else {return}
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        let padding: CGFloat = 15
        
        // 1st row: need A token
        needATipLabel.font = FontConfigManager.shared.getLabelFont()
        needATipLabel.text = NSLocalizedString("You Need More", comment: "")
        needATipLabel.frame = CGRect(x: padding, y: padding, width: 150, height: 40)
        scrollView.addSubview(needATipLabel)
        needAInfoLabel.font = FontConfigManager.shared.getLabelFont()
        needAInfoLabel.textAlignment = .right
        needAInfoLabel.frame = CGRect(x: padding + 150, y: needATipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(needAInfoLabel)
        needAUnderline.frame = CGRect(x: padding, y: needATipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        needAUnderline.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        scrollView.addSubview(needAUnderline)
        
        // 2nd row: need B token
        needBTipLabel.font = FontConfigManager.shared.getLabelFont()
        needBTipLabel.text = NSLocalizedString("You Need More", comment: "")
        needBTipLabel.frame = CGRect(x: padding, y: needATipLabel.frame.maxY + padding, width: 150, height: 40)
        scrollView.addSubview(needBTipLabel)
        needBInfoLabel.font = FontConfigManager.shared.getLabelFont()
        needBInfoLabel.textAlignment = .right
        needBInfoLabel.frame = CGRect(x: padding + 150, y: needBTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(needBInfoLabel)
    }
    
    func configButtons() {
        detailsButton.title = NSLocalizedString("Check Details", comment: "")
        detailsButton.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        detailsButton.layer.borderWidth = 1
        detailsButton.layer.cornerRadius = 23
        detailsButton.titleColor = UIColor.black
        detailsButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        if isBalanceEnough() {
            detailsButton.isEnabled = true
            detailsButton.backgroundColor = UIColor.white
        } else {
            detailsButton.isEnabled = false
            detailsButton.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        }
        
        doneButton.title = NSLocalizedString("Done", comment: "")
        doneButton.backgroundColor = UIColor.black
        doneButton.layer.cornerRadius = 23
        doneButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isBalanceEnough() -> Bool {
        return false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
