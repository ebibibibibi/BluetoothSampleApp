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
    
    // 接続したペリフェラル
    private var peripheral: CBPeripheral?
    
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
    /// Bluetoothが起動し、準備ができたら、サポートするサービスを宣伝しているペリフェラルをスキャンを開始します。
    fileprivate func startScanning() {
        guard !(centralManager?.isScanning ?? true) else { return }
        
        centralManager?.scanForPeripherals(withServices: [BluetoothService.chatServiceID], options: nil)
        
        scanPending = false
    }
}

// MARK: - Central Manager Delegate -
extension BluetoothCentralManager: CBCentralManagerDelegate {
    /// centralManagerの Bluetoothの状態が変化したときに呼び出される
    /// 主にBluetoothが起動完了したとき呼び出される。
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
    
    /// スキャン中、互換性のあるデバイスが検出されると呼び出される。
    func centralManager(_ central: CBCentralManager,
                            didDiscover peripheral: CBPeripheral,
                            advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        print("FOUND")
        // 他のペリフェラルは無視
        // TODO: ※ なぜ？
        guard self.peripheral == nil else { return }
        
        // advertisementData には CBAdvertisementDataServiceUUIDsKey に定義された全てのサービスUUIDに加えて、デバイスの名前やメーカー名などのペリフェラルに関する情報が含まれている。
        // CBAdvertisementDataLocalNameKey は通常、ペリフェラルのデバイス名を保持
        if let deviceName = advertisementData[CBAdvertisementDataLocalNameKey] {
            print("Peripheral \(deviceName) discovered.")
        } else {
            print("Compatible device discovered.互換性のあるデバイスが見つかりました。")
        }
        // RSSI = 相対信号強度
        print("RSSI is \(RSSI)")
        
        // ペリフェラルオブジェクトへの強力な参照を保持。
        // そうしないと、接続中に解放されてしまう。
        self.peripheral = peripheral
        
        // サービスIDに一致するペリフェラルを見つけたら、それに接続する。
        centralManager?.connect(peripheral, options: nil)
    }
    
    /// ペリフェラルへの接続を確立できたときに呼び出される。
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
    }
    
}
