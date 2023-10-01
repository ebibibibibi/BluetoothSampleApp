//
//  ViewController.swift
//  BluetoothSampleApp
//
//  Created by kotomi takahashi on 2023/10/02.
//

import UIKit

class ViewController: UIViewController {

    //private var bluetoothCentral = BluetoothCentralManager()
    private var bluetoothPeripheral = BluetoothPeripheralManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        //bluetoothCentral.start()
        bluetoothPeripheral.start()
    }
}
