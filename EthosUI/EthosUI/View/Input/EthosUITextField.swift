//
//  EthosUITextField.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public class EthosUITextField: BaseUIView {
    
    private let textField = UITextField(frame: CGRect.zero)
    
    public override func createLayout() {
        super.createLayout()
        self.addSubview(textField)
        
        self.padding = Rect<CGFloat>(8, 2, 8, 2)
    }
    
    public override func frameUpdate() {
        super.frameUpdate()
        self.textField.frame = self.bounds.insetBy(padding: padding)
    }
    
}
