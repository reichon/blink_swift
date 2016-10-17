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

    var KSS = 2
    
    var timer: NSTimer? = nil
    var startDate: NSDate?
    
    var player: AVAudioPlayer!
    let player1 = MPMusicPlayerController.applicationMusicPlayer()
    let speech = AVSpeechSynthesizer()
    
    var status: Status = .Normal {
        didSet(oldStatus) {
            guard status != oldStatus else {
                return
            }
            
            switch status {
            case .Alert:
//                player1.stop()
                player?.stop()
            case .Normal:
//                player1.stop()
                player?.stop()
            case .Danger:
                player?.stop()
//                player1.stop()
                
//                player1.skipToNextItem()
//                player1.play()
                
            case .Death:
//                if player1.playbackState == .Playing {
//                    player1.stop()
//                }
//                player1.skipToNextItem()
//                player1.play()
                
                player?.play()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MEMELib.sharedInstance().delegate = self
        
        let path = NSBundle.mainBundle().pathForResource("destiny", ofType: "mp3")!
        let url = NSURL(fileURLWithPath: path)
        player = try! AVAudioPlayer(contentsOfURL: url)
        
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
    }
    
    @IBAction func TapButton(sender: UILongPressGestureRecognizer) {
        if(sender.state == UIGestureRecognizerState.Ended){
//            if player1.playbackState == .Playing{
//                player1.stop()
//            }
            if ((player?.playing.boolValue) != nil){
                player?.stop()
            }
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
        print("Ready to Blink")
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
            let alert = UIAlertController(title: "Error", message: "else", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func memeRealTimeModeDataReceived(data: MEMERealTimeData!) {
        // 5分関係なくいつも実行される
        
        
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
//            return
//        }
        
        MiddleFreq = 163.0
        
        // 5分経ったあとだけ
        
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(add), userInfo: nil, repeats: true)
        }
        
        if Float(data.blinkSpeed) > 70 {
            msecs.append(Float(data.blinkSpeed))
            
        }

        freq = msecs.reduce(0, combine: +) / Float(msecs.count)
//
//        let speechUtterance = AVSpeechUtterance(string: Alert)
//        speechUtterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
//
//        SleepProgress.setProgress((freq - (0.75 * MiddleFreq - 20.0)) / 100.0, animated: true)
//        SleepProgressView.text = String(freq - (0.75 * MiddleFreq - 20.0))
//
//        if freq >= 0.75 * MiddleFreq - 20.0 && freq <= 0.75 * MiddleFreq + 20.0 {
//            BrainMode.text = "警戒状態です"
//            status = .Alert
//        } else if freq > 0.75 * MiddleFreq + 20.0 && freq < MiddleFreq + 5 {
//            BrainMode.text = "正常状態です"
//            status = .Normal
//        } else if freq >= MiddleFreq + 5 && freq < MiddleFreq + 20 {
//            BrainMode.text = "微・危険状態です"
//            Alert = "眠気を少し感知しました、窓を開けましょう"
//            if !speech.speaking {
//                speech.speakUtterance(speechUtterance)
//            }
//            status = .Danger
//        } else if freq >= MiddleFreq + 20 {
//            BrainMode.text = "超・危険状態です"
//            status = .Death
//        }
        
    }
    
    func add(data: MEMERealTimeData!) {
        
        print(MiddleFreq, freq)
        print(msecs)
        
        msecs = []
        
        let speechUtterance = AVSpeechUtterance(string: Alert)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        
        
        // 実際
        SleepProgress.setProgress((freq - (0.75 * MiddleFreq - 20.0)) / (250.0 - (0.75 * MiddleFreq - 20.0)), animated: true)
        SleepProgressView.text = String((freq - (0.75 * MiddleFreq - 20.0)) / (250.0 - (0.75 * MiddleFreq - 20.0)) * 100)
        
        if freq >= 0.75 * MiddleFreq - 20.0 && freq <= 0.75 * MiddleFreq + 20.0 {
            BrainMode.text = "警戒状態です"
            status = .Alert
        } else if freq > 0.75 * MiddleFreq + 20.0 && freq < MiddleFreq + 20.0 {
            BrainMode.text = "正常状態です"
            status = .Normal
        } else if freq >= MiddleFreq + 20.0 && freq < MiddleFreq + 40.0 {
            BrainMode.text = "微・危険状態です"
            Alert = "眠気を感知しました、休憩しましょう。危険です。"
            if !speech.speaking {
                speech.speakUtterance(speechUtterance)
            }
            status = .Danger
        } else if freq >= MiddleFreq + 40.0 {
            BrainMode.text = "超・危険状態です"
            status = .Death
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}