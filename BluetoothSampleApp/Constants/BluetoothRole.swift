//
//  BluetoothRole.swift
//  BluetoothSampleApp
//
//  Created by kotomi takahashi on 2023/10/01.
//

import Foundation

/// これらはBluetooth通信を行う際使用される、2つのデバイスタイプ
/// Central - ペリフェラルのサービスへアクセスを行う側。通信の制御の主導権を握る。
/// Peripheral - Centralと接続し、コミュニケーションを取る。
enum BluetoothRole {
    case central // The host device
    case peripheral // A client connecting to a host
}
