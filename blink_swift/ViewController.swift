//
//  ViewController.swift
//  blink_swift
//
//  Created by Rei K on 2016/06/29.
//  Copyright © 2016年 Rei K. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class ViewController: UIViewController, UIGestureRecognizerDelegate, MEMELibDelegate {
    //瞬き回数
    var blinkCnt = 0;
    
    var player: AVAudioPlayer?
    
//    var accelerometerUpdateInterval: NSTimeInterval;
    
    //瞬き検知した回数を表示
    @IBOutlet weak var lblBlinkCnt: UILabel!
    @IBOutlet weak var BrainMode: UILabel!
    @IBOutlet var TapCount: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MEMELib.sharedInstance().delegate = self
        let path = NSBundle.mainBundle().pathForResource("meteor", ofType: "mp3")!
        let url = NSURL(fileURLWithPath: path)
        player = try! AVAudioPlayer(contentsOfURL: url)
        
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapped(_:)))
        tapGesture.delegate = self;
        self.view.addGestureRecognizer(tapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func memeAppAuthorized(status: MEMEStatus) {
        MEMELib.sharedInstance().startScanningPeripherals()
    }
    
    func memePeripheralFound(peripheral: CBPeripheral!, withDeviceAddress address: String!) {
        MEMELib.sharedInstance().connectPeripheral(peripheral)
    }
    
    func memePeripheralConnected(peripheral: CBPeripheral!) {
        let status = MEMELib.sharedInstance().startDataReport()
        print(status)
    }
    
    func tapped(sender: UITapGestureRecognizer){
        blinkCnt += 1
        lblBlinkCnt.text = String(blinkCnt)
        print("tap")
        
        if blinkCnt % 10 == 0 {
            BrainMode.text = "sleep"
            player?.currentTime = 0
            player?.play()
        } else {
            BrainMode.text = "alert"
            player?.stop()
        }
    }
    
//    func memeRealTimeModeDataReceived(data: MEMERealTimeData!) {
//        
//        print(data.description)
//        
//        lblBlinkCnt.text = String(blinkCnt)
//        
//        if data.blinkSpeed > 196.17 && data.blinkSpeed < 208.31 {
//            BrainMode.text = "you are in ALERT mode";
//        } else if data.blinkSpeed > 251.9 && data.blinkSpeed < 265.24 {
//            BrainMode.text = "you are in SLEEP mode";
//            
//            player?.play()
//        }
//    }

}

