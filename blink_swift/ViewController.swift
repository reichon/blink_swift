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
import CoreBluetooth

class ViewController: UIViewController, UIGestureRecognizerDelegate, MEMELibDelegate {
    //瞬き回数
    var blinkCnt = 0
    var count = 0
    
    var player: AVAudioPlayer?
    
    //瞬き検知した回数を表示
    @IBOutlet weak var lblBlinkCnt: UILabel!
    @IBOutlet weak var BrainMode: UILabel!
    @IBOutlet weak var SleepProgress: UIProgressView!
    @IBOutlet weak var SleepProgressView: UILabel!
    @IBOutlet weak var BTdetect: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MEMELib.sharedInstance().delegate = self
        let path = NSBundle.mainBundle().pathForResource("meteor", ofType: "mp3")!
        let url = NSURL(fileURLWithPath: path)
        player = try! AVAudioPlayer(contentsOfURL: url)
    }
    
    func memeAppAuthorized(status: MEMEStatus) {
        MEMELib.sharedInstance().startScanningPeripherals()
    }
    
    func memePeripheralFound(peripheral: CBPeripheral!, withDeviceAddress address: String!) {
        MEMELib.sharedInstance().connectPeripheral(peripheral)
    }
    
    func memePeripheralConnected(peripheral: CBPeripheral!) {
        print("device connected")
        let status = MEMELib.sharedInstance().startDataReport()
        print(status)
    }
    
    func checkMEMEStatus(status:MEMEStatus) {
        switch status {
        case MEME_OK:
            print("Status: MEME_OK")
        case MEME_ERROR_BL_OFF:
            let alert = UIAlertController(title: "App Auth Failed", message: "Invalid Application ID or Client Secret", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        default:
            let alert = UIAlertController(title: "Error", message: "sonota", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
        
//        if status == MEME_ERROR_APP_AUTH {
//            let alert = UIAlertController(title: "App Auth Failed", message: "Invalid Application ID or Client Secret", preferredStyle: .Alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
//            presentViewController(alert, animated: true, completion: nil)
//        } else if status == MEME_ERROR_SDK_AUTH{
//            UIAlertView(title: "SDK Auth Failed", message: "Invalid SDK. Please update to the latest SDK.", delegate: nil, cancelButtonTitle: "OK").show()
//        } else if status == MEME_CMD_INVALID {
//            UIAlertView(title: "SDK Error", message: "Invalid Command", delegate: nil, cancelButtonTitle: "OK").show()
//        } else if status == MEME_ERROR_BL_OFF {
//            UIAlertView(title: "Error", message: "Bluetooth is off.", delegate: nil, cancelButtonTitle: "OK").show()
//        } else if status == MEME_OK {
//            print("Status: MEME_OK")
//        }
    }
    
    func memeRealTimeModeDataReceived(data: MEMERealTimeData!) {
        print(data.description)
        
        if Float(data.blinkSpeed) > 0 {
        SleepProgress.setProgress((Float(data.blinkSpeed) - 80.0) / 100.0, animated: true)
        }
        
        lblBlinkCnt.text = String(blinkCnt)
        
//        if Double(data.blinkSpeed) < 208.31 {
//            BrainMode.text = "you are in ALERT mode";
//            player?.stop()
//        } else if Double(data.blinkSpeed) > 251.9{
//            BrainMode.text = "you are in SLEEP mode";
//            player?.currentTime = 0
//            player?.play()
//        }
        
//        if Float(data.blinkSpeed) < 130.0 {
//            BrainMode.text = "you are in ALERT mode"
//            player?.stop()
//        } else if Float(data.blinkSpeed) > 230.0{
//            BrainMode.text = "you are in SLEEP mode"
//            player?.currentTime = 0
//            player?.play()
//        } else if Float(data.blinkSpeed) > 180.0{
//            BrainMode.text = "take a rest"
//            player?.stop()
//        }
        
        if Float(data.blinkSpeed) < 80.0 {
            BrainMode.text = "you are in ALERT mode"
            player?.stop()
        } else if Float(data.blinkSpeed) > 180.0{
            BrainMode.text = "you are in SLEEP mode"
            player?.currentTime = 0
            player?.play()
        } else if Float(data.blinkSpeed) > 140.0{
            BrainMode.text = "take a rest"
            player?.stop()
        }
        
        // 頭が下を向いていたら忠告
        if data.accY > 7 {
            AudioServicesPlaySystemSound(1003)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}