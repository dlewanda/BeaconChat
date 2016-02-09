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
    @IBOutlet weak var majorIdField: UITextField!
    @IBOutlet weak var minorIdField: UITextField!
    @IBOutlet weak var transmitButton: UIButton!
    @IBOutlet weak var beaconStatusLabel: UILabel!

    private var transmitting = false
    private var majorId:CLBeaconMajorValue = 10 //TODO - replace with configurable value
    private var minorId:CLBeaconMinorValue = 28 //TODO - replace with configurable value

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

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
        self.region = CLBeaconRegion(proximityUUID:uuidObj, major: majorId, minor: minorId, identifier: "com.dlewanda.beaconchat")
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
        self.transmitButton.setTitle("Transmit", forState: UIControlState.Normal)
        self.transmitButton.sizeToFit()
        transmitting = false
    }

    // MARK: IBActions
    @IBAction func goBack(sender: AnyObject) {
        disconnectFromServer(disconnected, failure: failure)
    }

    @IBAction func toggleTransmitting(sender: AnyObject) {
        if !transmitting {
            majorId = UInt16(majorIdField.text!)! as CLBeaconMajorValue
            minorId = UInt16(minorIdField.text!)! as CLBeaconMinorValue
            connectToServer(messageServerAddress.text!,
                channelName: "User\(majorId)Device\(minorId)",
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
            self.transmitButton.setTitle("Stop Transmitting", forState: UIControlState.Normal)
            self.transmitButton.sizeToFit()
            self.beaconStatusLabel.text = "Transmitting!"
            self.beaconStatusLabel.textColor = UIColor.greenColor()
        } else if(peripheral.state == CBPeripheralManagerState.PoweredOff) {
            turnOffBeacon()
        }
    }
}

