//
//  TextFieldTableViewCell.swift
//  BluetoothSampleApp
//
//  Created by kotomi takahashi on 2023/10/07.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            return true
        }
}
