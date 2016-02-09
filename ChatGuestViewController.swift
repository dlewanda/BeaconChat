//
//  ChatGuestViewController.swift
//  BeaconChat
//
//  Created by David Lewanda on 2/7/16.
//  Copyright © 2016 Dave Lewanda. All rights reserved.
//

import UIKit
import MZFayeClient

class ChatGuestViewController: FayeClientViewController, FayeClientDelegate {

    @IBOutlet weak var messageServerAddress: UITextField!

    internal var fayeClient:MZFayeClient = MZFayeClient(URL: NSURL())

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //TODO: scan for beacons, and move the following call inside the handler when device is beacon is detected
        connectToServer(messageServerAddress.text!, channelName: "browser", connected: connected, subscribed: subscribed, messageReceived: messageReceived, failure: failure)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func goBack(sender: AnyObject) {
        disconnectFromServer()
    }

    func connected() {
        NSLog("Chat Guest Connected");
    }

    func subscribed(channel: String) {
        NSLog("Chat Guest Subscribed to \(channel)")
    }

    func failure(error: NSError) {
        NSLog("Chat Guest error: \(error.userInfo)")
    }

    func messageReceived(message: Dictionary<NSObject, AnyObject>) {
        if let messageString = message["text"] {
            NSLog("Chat Guest received message: \(messageString)")
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
