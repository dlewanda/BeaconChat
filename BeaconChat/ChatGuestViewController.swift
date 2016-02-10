//
//  ChatGuestViewController.swift
//  BeaconChat
//
//  Created by David Lewanda on 2/7/16.
//  Copyright © 2016 Dave Lewanda. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import MZFayeClient

class ChatGuestViewController: FayeClientViewController, FayeClientDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var messageServerAddress: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var chatView: UIView!

    internal var fayeClient:MZFayeClient = MZFayeClient(URL: NSURL())
    private var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        addChatViewController(chatView)
        
        region = CLBeaconRegion(proximityUUID: uuidObj, identifier: "com.dlewanda.beaconchat")
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startMonitoringForRegion(self.region)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func goBack(sender: AnyObject) {
        disconnectFromServer(disconnected, failure: failure)
    }

    func connected() {
        NSLog("Chat Guest Connected");
        statusLabel.text = "Connected"
        statusLabel.textColor = UIColor.cyanColor()
    }

    func subscribed(channel: String) {
        NSLog("Chat Guest Subscribed to \(channel)")
        statusLabel.text = "Subscribed to \(channel)"
        statusLabel.textColor = UIColor.greenColor()
    }

    func failure(error: NSError) {
        NSLog("Chat Guest error: \(error.userInfo)")
    }

    func messageReceived(message: Dictionary<NSObject, AnyObject>) {
        if let messageString = message["text"] {
            NSLog("Chat Guest received message: \(messageString)")
            postMessage(messageString as! String)
        }
    }

    func disconnected() {
        NSLog("Chat Guest disconnected from server");
    }

    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        locationManager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
    }

    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
    }

    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        NSLog("locationManager error: \(error.userInfo)")
    }

    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        manager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
        disconnectFromServer(disconnected, failure: failure)
    }

    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        if(beacons.count == 0) {
            return
        }

        if let beacon = beacons.last {
            switch self.state {
            case .DISCONNECTED:
                if self.isViewLoaded() {
                    //use the last beacon found and connect to the server no matter how close the host is - at least we know about it
                    connectToServer(messageServerAddress.text!,
                        channelName: "User\(beacon.major)Device\(beacon.minor)",
                        connected: connected,
                        subscribed: subscribed,
                        messageReceived: messageReceived,
                        failure: failure)
                }
                break;
            case .CONNECTING:
                //do nothing while in transient state
                break;
            case .DISCONNECTING:
                //do nothing while in transient state
                break;
            case .CONNECTED:
                //if connected, let the host know how close you are
                if (beacon.proximity == CLProximity.Unknown) {
                    sendMessage("I don't know how far away I am from you")
                } else if (beacon.proximity == CLProximity.Immediate) {
                    sendMessage("I'm really close to you!")
                } else if (beacon.proximity == CLProximity.Near) {
                    sendMessage("I'm near you")
                } else if (beacon.proximity == CLProximity.Far) {
                    sendMessage("I'm far away")
                }
                break;
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
