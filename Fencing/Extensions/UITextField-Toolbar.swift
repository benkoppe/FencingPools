//
//  UITextField-Toolbar.swift
//  Fencing
//
//  Created by Ben K on 7/8/21.
//

import Foundation
import UIKit

extension UITextField {

    func addButtonsOnKeyboard(beforeField: UITextField?, nextField: UITextField?){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let up = CustomUIBarButtonItem(image: UIImage(systemName: "chevron.up"), style: .plain, target: self, action: #selector(self.nextField(nextField:)))
        if beforeField == nil {
            up.isEnabled = false
        } else {
            up.goToField = beforeField
        }
        
        let down = CustomUIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: self, action: #selector(self.nextField(nextField:)))
        
        if nextField == nil {
            down.isEnabled = false
        } else {
            down.goToField = nextField
        }
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [up, down, flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func nextField(nextField: CustomUIBarButtonItem) {
        let field = nextField.goToField
        
        if let nextField = field {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            self.resignFirstResponder()
        }
    }
    
    @objc func doneButtonAction(){
        self.resignFirstResponder()
    }
}

class CustomUIBarButtonItem: UIBarButtonItem {
    var goToField: UITextField?
}
