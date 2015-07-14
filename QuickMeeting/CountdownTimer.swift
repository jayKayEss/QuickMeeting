//
//  CountdownTimer.swift
//  QuickMeeting
//
//  Created by Justin Sheckler on 7/13/15.
//  Copyright (c) 2015 Justin Sheckler. All rights reserved.
//

import UIKit

protocol CountdownTimerDelegate {
    
    func onStart(timeRemaining: CFTimeInterval)
    func onStop()
    func onInterval(timeRemaining: CFTimeInterval)

}

extension CFTimeInterval {

    var mins: UInt8 {
        return UInt8(ceil(self) / 60)
    }
    
    var secs: UInt8 {
        return UInt8(ceil(self) % 60)
    }
    
}

class CountdownTimer: NSObject {
   
    static let Timer = CountdownTimer()
    
    var duration: CFTimeInterval = 0
    var interval: CFTimeInterval = 0
    var delegate: CountdownTimerDelegate?
    
    var mainTimer: NSTimer?
    var intervalTimer: NSTimer?
    var endTime: NSDate?
    
    var isRunning: Bool = false

    var timeRemaining: CFTimeInterval {
        if let end = endTime {
            return ceil(end.timeIntervalSinceNow)
        }
        
        return 0
    }
    
    func start(duration:CFTimeInterval, interval:CFTimeInterval, delegate:CountdownTimerDelegate) {
        self.duration = duration
        self.interval = interval
        self.delegate = delegate
        self.isRunning = false
        endTime = NSDate(timeIntervalSinceNow: duration)
        
        assert(duration > 0, "Duration must be greater than 0")
        assert(interval > 0, "Interval must be greater than 0")
        
        isRunning = true
        
        NSLog("STRT Time remaining: %f", timeRemaining)
        delegate.onStart(timeRemaining)
        
        mainTimer = NSTimer.scheduledTimerWithTimeInterval(CFTimeInterval(duration),
            target: self, selector: "onStop:", userInfo: nil, repeats: false)
        
        intervalTimer = NSTimer.scheduledTimerWithTimeInterval(CFTimeInterval(interval),
            target: self, selector: "onInterval:", userInfo: nil, repeats: true)
    }

    func stop() {
        mainTimer?.invalidate()
        intervalTimer?.invalidate()
        
        isRunning = false
        NSLog("CNCL Timer remaining: %f", timeRemaining)
    }
    
    func onStop(timer:NSTimer) {
        intervalTimer?.invalidate()
        NSLog("STOP Time remaining: %f", timeRemaining)
        delegate?.onStop()
    }
    
    func onInterval(timer:NSTimer) {
        NSLog("INTV Time remaining: %f", timeRemaining)
        delegate?.onInterval(timeRemaining)
    }
    
}
