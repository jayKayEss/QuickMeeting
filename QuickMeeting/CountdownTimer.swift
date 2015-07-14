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
    func onStop(timeRemaining: CFTimeInterval)
    func onInterval(timeRemaining: CFTimeInterval)

}

extension CFTimeInterval {

    var mins: Int {
        return Int(ceil(self) / 60)
    }
    
    var secs: Int {
        return Int(ceil(self) % 60)
    }
    
    var description: String {
        if self > 0 {
            return String(format: "We have %d minutes left", self.mins)
        } else {
            return "The meeting is over"
        }
    }
    
}

class CountdownTimer: NSObject {
   
    var duration: CFTimeInterval = 0
    var interval: CFTimeInterval = 0
    var delegate: CountdownTimerDelegate?

    var startTime: NSDate?
    var endTime: NSDate?
    
    var timeRemaining: CFTimeInterval {
        if let end = endTime {
            return ceil(end.timeIntervalSinceNow)
        }
        
        return 0
    }
    
    var isValid: Bool {
        return endTime != nil
    }
    
    var isTimeRemaining: Bool {
        if let end = endTime {
            return NSDate().compare(end) == .OrderedAscending
        }

        return false
    }
    
    override init() {
        super.init()

        NSLog("### ADDING OBSERVER")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLocalNotification:", name: "QMLocalNotificationReceived", object:nil)
    }
    
    deinit {
        NSLog("### REMOVING OBSERVER")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func start(duration:CFTimeInterval, interval:CFTimeInterval, delegate:CountdownTimerDelegate) {
        assert(duration > 0, "Duration must be greater than 0")
        assert(interval > 0, "Interval must be greater than 0")

        self.duration = duration
        self.interval = interval
        self.delegate = delegate
        startTime = NSDate()
        endTime = NSDate(timeInterval: duration, sinceDate: startTime!)
        NSLog("End time %@", endTime!)

        NSLog("STRT Time remaining: %f", timeRemaining)
        delegate.onStart(timeRemaining)
        
        var notificationTime = startTime!.copy() as! NSDate
        do {
            notificationTime = NSDate(timeInterval: interval, sinceDate: notificationTime)
            NSLog("Notification time %@", notificationTime)
            let minsRemaining = endTime!.timeIntervalSinceDate(notificationTime)

            var notification = UILocalNotification()
            notification.timeZone = NSTimeZone.defaultTimeZone()
            notification.fireDate = notificationTime
            notification.alertBody = minsRemaining.description
            notification.soundName = "bell.aiff"
        
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        } while (notificationTime.compare(endTime!) == .OrderedAscending)
        
    }
    
    func handleLocalNotification(options: NSDictionary?) {
        NSLog("NOTIFICATION RECEIVED %d", timeRemaining)
        if (isValid) {
            if isTimeRemaining {
                delegate?.onInterval(timeRemaining)
            } else {
                delegate?.onStop(timeRemaining)
                stop()
            }
        }
    }
    
    func stop() {
        NSLog("CNCL Timer remaining: %f", timeRemaining)
        endTime = nil
        startTime = nil
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
}
