//
//  ViewController.swift
//  BLEtest
//
//  Created by 杉浦圭相 on 2018/06/04.
//  Copyright © 2018年 杉浦圭相. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralManagerDelegate, CBCentralManagerDelegate {
    
    var peripheralManager: CBPeripheralManager!
    @IBOutlet var advBtn: UIButton!
    @IBOutlet var advlabel: UILabel!
    @IBOutlet var scnBtn: UIView!
    @IBOutlet weak var scnlabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //  peripheralManagerを初期化
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        //  centralManagerの初期化
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // ペリフェラルマネージャーが変化すると呼ばれる
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("state: \(peripheral.state)")
        
        switch peripheral.state {
        case .poweredOn:
            // アドバタイズ開始
            advstart()
        default:
            break
        }
    }
    
    // アドバタイズスタート用関数宣言
    private func advstart() {
        print("advsrart")
        // アドバタイズメントデータを作成する
        let advData = [CBAdvertisementDataLocalNameKey: "Test Device"]
        // アドバタイズスタート
        peripheralManager.startAdvertising(advData)
        advBtn.setTitle("STOP ADVERTISING", for: .normal) // ボタンタイトル変更
    }
    
    private func advstop() {
        // アドバタイズストップ
        peripheralManager.stopAdvertising()
        advBtn.setTitle("START ADVERTISING", for: .normal) // ボタンタイトル変更
    }
    
    // ペリフェラルマネージャーの状態が変化すると呼ばれる
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            advlabel.text = "ERROR"
            print("アドバタイズ開始失敗! error: \(error)")
            return
        } else {
            advlabel.text = "SUCCESS"
            print("アドバタイズ開始成功！")
        }
    }
    
    @IBAction func advBtnTapped(sender: UIButton) {
        if !peripheralManager.isAdvertising {
            advstart()
        } else {
            advstop()
        }
    }
    
    private var isScanning = false
    private var centralManager: CBCentralManager!
    
    // セントラルマネージャーの状態が変化したら呼ばれる
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state: \(central.state)")
        
    }
    
    // 周辺にあるデバイスを発見する
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("発見したBLEデバイス: \(peripheral)")
        scnlabel.text = "BLEDevice get!"
    }
    
    @IBAction func scnBtnTapped(sender: UIButton) {
        if !isScanning {
            isScanning = true
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            sender.setTitle("STOP SCAN", for: .normal)
        } else {
            centralManager.stopScan()
            sender.setTitle("START SCAN", for: .normal)
            isScanning = false
        }
    }
    
    
}

