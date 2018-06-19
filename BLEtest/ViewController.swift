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
        //  peripheralManager initialization
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        //  centralManager initialization
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    private func publishservice() {
        // Create service
        let serviceUUID = CBUUID(string: "0000")
        let service = CBMutableService(type: serviceUUID, primary: true)
        
        // Create characteristic
        let characteristicUUID = CBUUID(string: "0001")
        let characteristic = CBMutableCharacteristic(type: characteristicUUID,
                                                     properties: .read,
                                                     value: nil,
                                                     permissions: .readable)
        
        // set a characteristic
        service.characteristics = [characteristic]
        // add a service
        peripheralManager.add(service)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Peripheral manager is called to change
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("state: \(peripheral.state)")
        
        switch peripheral.state {
        case .poweredOn:
            // Advertisement start
//            advstart()
            // サービス登録開始
            publishservice()
        default:
            break
        }
    }
    
    // Call to add a service
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            print("サービス追加失敗 error:\(error)")
            return
        }
        print("サービス追加成功")
        // Start advertise
        advstart()
    }
    
    // アドバタイズスタート用関数宣言
    private func advstart() {
        // Advertisement data create
        let advData = [CBAdvertisementDataLocalNameKey: "Test Device"]
        // Advertisement start
        peripheralManager.startAdvertising(advData)
        advBtn.setTitle("STOP ADVERTISING", for: .normal) // advBtn title change
    }
    
    private func advstop() {
        // Advertise stoping
        peripheralManager.stopAdvertising()
        advBtn.setTitle("START ADVERTISING", for: .normal) // advBtn title change
    }
    
    // Peripheral manager is called to change
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("アドバタイズ開始失敗! error: \(error)")
            return
        } else {
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
    private var peripheral: CBPeripheral!
    
    // CentralManager is called to change
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state: \(central.state)")
        
    }
    
    // Discover neighboring device
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("発見したBLEデバイス: \(peripheral)")
        
        if let name = peripheral.name, name.hasPrefix("iPad (2)") {
            self.peripheral = peripheral
            centralManager.connect(peripheral,options: nil)
        }
    }
    // It is called a successful connection with peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("接続成功")
        
        scnlabel.text = "iPad(2)に接続しました。"
        
        // サービス探索結果を受け取るためのデリゲートをセット
        peripheral.delegate = self as? CBPeripheralDelegate
        // サービス探索開始
        peripheral.discoverServices(nil)
    }
    
    // peripheralとの接続が失敗すると呼ばれる
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("接続失敗")
    }
    
    // サービス発見時に呼ばれる
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let error = error {
            print("エラー: \(error)")
            return
        }
        
        guard let services = peripheral.services , services.count > 0 else {
            print("No services")
            return
        }
        print("\(services.count)個のサービスを発見しました　\(services)")
        
        for service in services {
            // キャラクタリスティック探索開始
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // キャラクタリスティック発見時に呼ばれる
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?)
    {
        if let error = error {
            print("エラー: \(error)")
            return
        }
        
        let characteristics = service.characteristics
        print("\(String(describing: characteristics?.count)) 個のキャラクタリスティックを発見 \(String(describing: characteristics))")
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


