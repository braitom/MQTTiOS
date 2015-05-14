//
//  ViewController.swift
//  MqttiOS
//
//  Created by kaigi on 2015/05/14.
//  Copyright (c) 2015年 braitom. All rights reserved.
//

import UIKit
import CoreMotion
import Moscapsule

class ViewController: UIViewController {

    @IBOutlet weak var pressureLabel: UILabel!
    
    let altimeter = CMAltimeter()
    var mqttClient: MQTTClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createMqttConnection()
        getPressure()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshButton(sender: UIButton) {
        altimeter.stopRelativeAltitudeUpdates()
        getPressure()
    }
    
    override func viewDidDisappear(animated: Bool) {
        mqttClient.disconnect()
    }
    
    func getPressure() {
        self.pressureLabel.text = "----"
        altimeter.startRelativeAltitudeUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler:
            {data, error in
                if error == nil {
                    let pressure = String(stringInterpolationSegment: data.pressure)
                    self.pressureLabel.text = pressure
                    
                    let now = NSDate()
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.timeStyle = .MediumStyle
                    dateFormatter.dateStyle = .MediumStyle
                    let currentTime = dateFormatter.stringFromDate(now)
                    
                    self.mqttClient.publishString("\(currentTime): \(pressure)", topic: "test/iOS", qos: 0, retain: false)
                }
        })

    }
    
    func createMqttConnection() {
        let mqttConfig = MQTTConfig(clientId: "mqttSample", host: "10.12.0.244", port: 1883, keepAlive: 60)
        
        mqttConfig.onPublishCallback = { messageId in
            NSLog("published (mid=\(messageId))")
        }
        
        self.mqttClient = MQTT.newConnection(mqttConfig)
   }
}
