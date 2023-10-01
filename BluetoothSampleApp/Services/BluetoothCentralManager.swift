//
//  BluetoothCentralManager.swift
//  BluetoothSampleApp
//
//  Created by kotomi takahashi on 2023/10/01.
//

import UIKit
import CoreBluetooth

/// Bluetooth接続に伴い、ホストとしての統制を行うclass
final class BluetoothCentralManager: NSObject {
    /// Bluetooth接続に伴い、ホストとしての統制を行うclass
    private var centralManager: CBCentralManager?
    
    // スキャンが延長されたか
    private var scanPending = false
    
    /// エリア内のperipheralデバイスのスキャン開始
    public func start() {
        // セントラルマネージャーを作成（これによりBluetoothの起動 開始）。
        if centralManager == nil {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
        
        // Bluetoothの電源が完全にオンになるまでスキャンを開始できない場合があるため、遅延を想定する必要がある
        guard centralManager?.state == .poweredOn else {
            scanPending = true
            return
        }
        
        // central側のBluetooth機能が準備できていたら、スキャンを開始する
        startScanning()
    }
}

// MARK: - Private -
extension BluetoothCentralManager {
    fileprivate func startScanning() {
        guard !(centralManager?.isScanning ?? true) else { return }
        
        centralManager?.scanForPeripherals(withServices: [BluetoothService.chatServiceID], options: nil)
        
        scanPending = false
    }
}

// MARK: - Central Manager Delegate -
extension BluetoothCentralManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central の状態が `.unknown` に変更されました")
        case .resetting:
            print("central の状態が `.resetting` に変更されました")
        case .unsupported:
            print("central の状態が `.unsupported` に変更されました")
        case .unauthorized:
            print("central の状態が `.unauthorized` に変更されました")
        case .poweredOff:
            print("central の状態が `.poweredOff` に変更されました")
        case .poweredOn:
            print("central の状態が `.poweredOn` に変更されました")
            if scanPending { startScanning() }
        @unknown default:
            print("central の状態が `an unknown state` に変更されました")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("FOUND")
    }
    
}
