//
//  ChatHostViewController.swift
//  BeaconChat
//
//  Created by David Lewanda on 2/6/16.
//  Copyright © 2016 Dave Lewanda. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import MZFayeClient

class ChatHostViewController: FayeClientViewController, FayeClientDelegate, CBPeripheralManagerDelegate {

    @IBOutlet weak var messageServerAddress: UITextField!
    @IBOutlet weak var transmitButton: UIButton!
    @IBOutlet weak var beaconStatusLabel: UILabel!

    private var transmitting = false
    private let majorId:CLBeaconMajorValue = 10 //TODO - replace with configurable value
    private let minorId:CLBeaconMinorValue = 28 //TODO - replace with configurable value

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.region = CLBeaconRegion(proximityUUID:uuidObj, major: majorId, minor: minorId, identifier: "com.dlewanda.beaconchat")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func connected() {
        NSLog("Chat Host Connected");
    }

    func subscribed(channel: String) {
        NSLog("Chat Host Subscribed to \(channel)")
        data = self.region.peripheralDataWithMeasuredPower(nil)
        manager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }

    func failure(error: NSError) {
        NSLog("Chat Host error: \(error.userInfo)")
    }

    func messageReceived(message: Dictionary<NSObject, AnyObject>) {
        if let messageString = message["text"] {
            NSLog("Chat Host received message: \(messageString)")
        }
    }

    func disconnected() {
        NSLog("Chat Host disconnected from server");
        turnOffBeacon()
    }

    func turnOffBeacon() {
        NSLog("powered off")
        self.manager.stopAdvertising()
        self.beaconStatusLabel.text = "Beacon Off"
        self.beaconStatusLabel.textColor = UIColor.redColor()
        transmitting = false
    }

    @IBAction func goBack(sender: AnyObject) {
        disconnectFromServer(disconnected, failure: failure)
    }

    @IBAction func toggleTransmitting(sender: AnyObject) {
        if !transmitting {
            connectToServer(messageServerAddress.text!,
                channelName: "browser",
                connected: connected,
                subscribed: subscribed,
                messageReceived: messageReceived,
                failure: failure)
        } else {
            disconnectFromServer(disconnected, failure: failure)
        }
    }
    
    // MARK: CBPeripheralManagerDelegate
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if(peripheral.state == CBPeripheralManagerState.PoweredOn) {
            NSLog("powered on")
            self.manager.startAdvertising(data as? [String : AnyObject])
            self.transmitting = true
            self.transmitButton.titleLabel?.text = "Stop Transmitting"
            self.transmitButton.sizeToFit()
            self.beaconStatusLabel.text = "Transmitting!"
            self.beaconStatusLabel.textColor = UIColor.greenColor()
        } else if(peripheral.state == CBPeripheralManagerState.PoweredOff) {
            turnOffBeacon()
        }
    }
}

