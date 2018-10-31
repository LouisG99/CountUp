//
//  CountValue.swift
//  CountUp
//
//  Created by Louis Gouirand on 9/13/18.
//  Copyright © 2018 Louis Gouirand. All rights reserved.
//

import UIKit

@IBDesignable class CountValue: UIStackView {

    // MARK: properties
    var value = 0
    var increment = 0
    @IBInspectable private var buttons = [UIButton(), UIButton()]
    
    @IBInspectable var buttonSize: CGSize = CGSize(width: 44.0, height: 44.0)

    
    // MARK: initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpButtons()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setUpButtons()
    }
    
    private func setUpButtons() {
        let tempIncr = UIButton()
        let tempDecr = UIButton()
        
        tempIncr.setImage(UIImage(named: "plusSign.png"), for: .normal)
        tempDecr.setImage(UIImage(named: "minusSign.png"), for: .normal)
        
        tempIncr.translatesAutoresizingMaskIntoConstraints = false
        tempDecr.translatesAutoresizingMaskIntoConstraints = false
        
        tempDecr.heightAnchor.constraint(equalToConstant: buttonSize.height).isActive = true
        tempDecr.widthAnchor.constraint(equalToConstant: buttonSize.width).isActive = true
        tempIncr.heightAnchor.constraint(equalToConstant: buttonSize.height).isActive = true
        tempIncr.widthAnchor.constraint(equalToConstant: buttonSize.width).isActive = true
        
        addArrangedSubview(tempIncr)
        addArrangedSubview(tempDecr)
        
        self.buttons[0] = tempIncr
        self.buttons[1] = tempDecr
        
        
    }

}
