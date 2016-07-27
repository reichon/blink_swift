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
import MediaPlayer

enum Status {
    case Alert
    case Normal
    case Danger
    case Death
}

class ViewController: UIViewController, UIGestureRecognizerDelegate, MEMELibDelegate {
    
    
    //瞬き検知した回数を表示
    @IBOutlet weak var BrainMode: UILabel!
    @IBOutlet weak var SleepProgress: UIProgressView!
    @IBOutlet weak var SleepProgressView: UILabel!
    @IBOutlet weak var StopMusic: UIButton!
    
    //瞬き回数
    var count = 0
    var Alert = ""
    
    var Middle : [Float] = []
    var MiddleFreq : Float = 0.0
    
    var msecs : [Float] = []
    var freq : Float = 0.0

    
    var timer: NSDate?
    var startDate: NSDate?

    var status: Status = .Normal {
        didSet(oldStatus) {
            guard status != oldStatus else {
                return
            }
            
            switch status {
            case .Alert:
                player1.stop()
            case .Normal:
                player1.stop()
            case .Danger:
                player1.stop()
            case .Death:
                player1.skipToNextItem()
                player1.play()
            }
        }
    }
    
    let player1 = MPMusicPlayerController.applicationMusicPlayer()
    let speech = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MEMELib.sharedInstance().delegate = self
        
        let query = MPMediaQuery.songsQuery()
        
        guard let songs = query.items else {
            print("song not found")
            return
        }
        
        
        
        let index = Int(arc4random_uniform(UInt32(songs.count)))
        let song = songs[index]
        
        player1.setQueueWithQuery(query)
        player1.nowPlayingItem = song
        player1.shuffleMode = .Songs
        player1.repeatMode = .None
    }

    override func viewDidAppear(animated: Bool) {
        startDate = NSDate()
        timer = NSDate()
    }
    
    @IBAction func TapButton(sender: UILongPressGestureRecognizer) {
        if(sender.state == UIGestureRecognizerState.Ended){
            player1.stop()
        }
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
    }
    
    func memeRealTimeModeDataReceived(data: MEMERealTimeData!) {
        // 5分関係なくいつも実行される
        if Float(data.blinkSpeed) > 70 {
            msecs.append(Float(data.blinkSpeed))
        }
        
        // 実際
//        guard -(startDate!.timeIntervalSinceNow) >= 5 * 60 else {
//            // 5分経ってないときだけ
//        
//            if Float(data.blinkSpeed) > 70 {
//                Middle.append(Float(data.blinkSpeed))
//            }
//            
//            MiddleFreq = Middle.reduce(0, combine: +) / Float(Middle.count)
//            
//            BrainMode.text = "計測中"
//            
////            print(data.blinkSpeed)
//            
//            return
//        }
        
        MiddleFreq = 150.0
        
//        print(data.blinkSpeed, freq, MiddleFreq)
        
        
        // 5分経ったあとだけ
//        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(add), userInfo: nil, repeats: true)
 
        
//        msecs = Array(msecs.suffix(20))
//        guard msecs.count == 20 else {
//            return
//        }
        
        guard -(timer!.timeIntervalSinceNow) % 60 == 0 else {
            freq = msecs.reduce(0, combine: +) / Float(msecs.count)
            return
        }

        msecs = []

        let speechUtterance = AVSpeechUtterance(string: Alert)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")

        
        // 実際
        SleepProgress.setProgress((freq - (0.75 * MiddleFreq - 20.0)) / 100.0, animated: true)
        SleepProgressView.text = String(freq - (0.75 * MiddleFreq - 20.0))
        
        // 動画用
//        SleepProgress.setProgress((freq - 60.0) / 100.0, animated: true)
//        SleepProgressView.text = String(freq - 60.0)

//        if freq <= 60.0 {
//            BrainMode.text = "警戒状態です"
//            status = .Alert
//        } else if freq > 60.0 && freq < 110.0 {
//            BrainMode.text = "正常状態です"
//            status = .Normal
//        } else if freq >= 110.0 && freq < 140.0 {
//            BrainMode.text = "微・危険状態です"
//            Alert = "眠気を少し感知しました、窓を開けましょう"
//            
//            if !speech.speaking {
//                speech.speakUtterance(speechUtterance)
//            }
//            
//            status = .Danger
//        } else if freq >= 140.0 {
//            BrainMode.text = "超・危険状態です"
//            Alert = "今すぐ休憩してください"
//            
//            if !speech.speaking {
//                speech.speakUtterance(speechUtterance)
//            }
//            
//            status = .Death
//        }

        // 実際
        if freq >= 0.75 * MiddleFreq - 20.0 && freq <= 0.75 * MiddleFreq + 20.0 {
            BrainMode.text = "警戒状態です"
            status = .Alert
        } else if freq > 0.75 * MiddleFreq + 20.0 && freq < MiddleFreq + 20 {
            BrainMode.text = "正常状態です"
            status = .Normal
        } else if freq >= MiddleFreq + 20 && freq < MiddleFreq + 30 {
            BrainMode.text = "微・危険状態です"
            Alert = "眠気を少し感知しました、窓を開けましょう"
            if !speech.speaking {
                speech.speakUtterance(speechUtterance)
            }
            status = .Danger
        } else if freq >= MiddleFreq + 30 {
            BrainMode.text = "超・危険状態です"
            status = .Death
        }
        
    }
    
//    func add(data: MEMERealTimeData!) {
//        
//        
//        print(MiddleFreq, freq)
//        
//        msecs = []
//        
//        let speechUtterance = AVSpeechUtterance(string: Alert)
//        speechUtterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
//        
//        
//        // 実際
//        SleepProgress.setProgress((freq - (0.75 * MiddleFreq - 20.0)) / 100.0, animated: true)
//        SleepProgressView.text = String(freq - (0.75 * MiddleFreq - 20.0))
//        
//        if freq >= 0.75 * MiddleFreq - 20.0 && freq <= 0.75 * MiddleFreq + 20.0 {
//            BrainMode.text = "警戒状態です"
//            status = .Alert
//        } else if freq > 0.75 * MiddleFreq + 20.0 && freq < MiddleFreq + 20 {
//            BrainMode.text = "正常状態です"
//            status = .Normal
//        } else if freq >= MiddleFreq + 20 && freq < MiddleFreq + 30 {
//            BrainMode.text = "微・危険状態です"
//            Alert = "眠気を少し感知しました、窓を開けましょう"
//            if !speech.speaking {
//                speech.speakUtterance(speechUtterance)
//            }
//            status = .Danger
//        } else if freq >= MiddleFreq + 30 {
//            BrainMode.text = "超・危険状態です"
//            status = .Death
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}