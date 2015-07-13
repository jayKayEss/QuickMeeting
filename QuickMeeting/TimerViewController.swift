//
//  ViewController.swift
//  QuickMeeting
//
//  Created by Justin Sheckler on 5/16/15.
//  Copyright (c) 2015 Justin Sheckler. All rights reserved.
//

import UIKit
import AVFoundation

class TimerViewController: UIViewController, CountdownTimerDelegate {

    var timer: CountdownTimer?
    var duration: CFTimeInterval = 0
    var interval: CFTimeInterval = 0
    var displayTimer: NSTimer?
    var speechSynth: AVSpeechSynthesizer?
    var bellSound: SystemSoundID = 0
    
    @IBOutlet weak var displayLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = CountdownTimer(duration: duration, interval: interval, delegate: self)
        speechSynth = AVSpeechSynthesizer()

        updateDisplay()
        displayTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self,
            selector: "updateDisplay", userInfo: nil, repeats: true)
        
        timer?.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        AudioServicesDisposeSystemSoundID(bellSound)
        speechSynth = nil
    }
    
    override func viewWillDisappear(animated: Bool) {
        timer?.stop()
    }
    
    func updateDisplay() {
        if let timeRemaining = timer?.timeRemaining {
            displayLabel?.text = String(format: "%02d:%02d", timeRemaining.mins, timeRemaining.secs)
        }
    }
    
    func saySomething(text: String) {
        if (bellSound == 0) {
            if let audioUrl = NSBundle.mainBundle().URLForResource("bell", withExtension: "aiff") {
                AudioServicesCreateSystemSoundID(audioUrl, &bellSound)
            }
        }

        if (speechSynth == nil) {
            speechSynth = AVSpeechSynthesizer()
        }
        
        AudioServicesPlaySystemSound(bellSound);
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.1
        utterance.preUtteranceDelay = 0.5
        speechSynth?.speakUtterance(utterance)
    }
    
    func onStart(timeRemaining: CFTimeInterval) {
        saySomething(String(format: "Starting a %d minute meeting", timeRemaining.mins))
    }
    
    func onStop() {
        saySomething("The meeting is over")
        displayTimer?.invalidate()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func onInterval(timeRemaining: CFTimeInterval) {
        let text = String(format: "There are %d minutes remaining", timeRemaining.mins)
        saySomething(text)
    }

}

