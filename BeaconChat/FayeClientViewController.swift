//
//  FayeClientViewController.swift
//  BeaconChat
//
//  Created by David Lewanda on 2/7/16.
//  Copyright © 2016 Dave Lewanda. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import MZFayeClient

//classes that subclass FayeClientViewController should implement this protocol
protocol FayeClientDelegate {
    func connected()
    func subscribed(channel: String)
    func failure(error: NSError)
    func messageReceived(message: Dictionary<NSObject, AnyObject>)
}

class FayeClientViewController: UIViewController {

    private var fayeClient: MZFayeClient

    // the UUID our iBeacons will use
    //TODO - replace with field from config_api response
    let uuidObj = NSUUID(UUIDString: "E322C5CB-FA4E-46D1-8ED9-4A1AC6B3BA58")!

    // Objects used in the creation of iBeacons
    var region = CLBeaconRegion()
    var data = NSDictionary()
    var manager = CBPeripheralManager()

    required init?(coder aDecoder: NSCoder) {
        fayeClient = MZFayeClient(URL: NSURL())
        super.init(coder: aDecoder)
    }

    func connectToServer(serverAddress: String, channelName: String,
        connected:()->Void,
        subscribed:(String)->Void,
        messageReceived:(message:Dictionary<NSObject, AnyObject>)->Void,
        failure:(error: NSError)->Void) {
            let serverUrl = NSURL.init(string: serverAddress)
            fayeClient = MZFayeClient(URL: serverUrl) //TODO: check if this will this handle DNS, and autofill http:// prefix?
            fayeClient.subscribeToChannel("/\(channelName)", success: {
                subscribed(channelName)
                }, failure: { (error) -> Void in
                    failure(error: error)
                }, receivedMessage: { (message) -> Void in
                    messageReceived(message: message)
            })

            fayeClient.connect({ () -> Void in
                connected()
                self.fayeClient.sendMessage(["text":"hello!"], toChannel: "/browser", success: { () -> Void in
                    NSLog("Message sent successfully")
                    }, failure: { (error) -> Void in
                        NSLog("Error sending message: \(error)")
                })
                }) { (error) -> Void in
                    failure(error: error)
            }
    }

    func disconnectFromServer(disconnected:()->Void, failure:(error: NSError)->Void) {
        fayeClient.disconnect({ () -> Void in
            disconnected()
            }, failure: { (error) -> Void in
            failure(error: error)
        })
    }
}
