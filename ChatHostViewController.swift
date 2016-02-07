//
//  ChatHostViewController.swift
//  BeaconChat
//
//  Created by David Lewanda on 2/6/16.
//  Copyright © 2016 Dave Lewanda. All rights reserved.
//

import UIKit
import MZFayeClient

class ChatHostViewController: FayeClientViewController, FayeClientDelegate {

    @IBOutlet weak var messageServerAddress: UITextField!
    @IBOutlet weak var transmitButton: UIButton!

    private var fayeClient:MZFayeClient = MZFayeClient(URL: NSURL())
    private var transmitting = false;

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
        self.transmitting = true
        self.transmitButton.titleLabel?.text = "Stop Transmitting"
    }

    func subscribed(channel: String) {
        NSLog("Chat Host Subscribed to \(channel)")
    }

    func failure(error: NSError) {
        NSLog("Chat Host error: \(error.userInfo)")
    }

    func messageReceived(message: Dictionary<NSObject, AnyObject>) {
        if let messageString = message["text"] {
            NSLog("Chat Host received message: \(messageString)")
        }
    }

    @IBAction func goBack(sender: AnyObject) {
        disconnectFromServer()
    }
    
    @IBAction func toggleTransmitting(sender: AnyObject) {
        if !transmitting {
            connectToServer()
        } else {
            disconnectFromServer()
        }
    }

    func connectToServer() {
        let serverUrl = NSURL.init(string: messageServerAddress.text!)
        fayeClient = MZFayeClient(URL: serverUrl) //TODO: check if this will this handle DNS, and autofill http:// prefix?
        fayeClient.subscribeToChannel("/browser", success: {
            NSLog("Success")
            }, failure: { (error) -> Void in
                NSLog("Failure: \(error.userInfo)")
            }, receivedMessage: { (message) -> Void in
                NSLog("Received message: \(message)")
        })

        fayeClient.connect({ () -> Void in
            self.fayeClient.sendMessage(["text":"hello!"], toChannel: "/browser", success: { () -> Void in
                NSLog("Message sent successfully")
                }, failure: { (error) -> Void in
                    NSLog("Error sending message: \(error)")
            })
            }) { (error) -> Void in
                NSLog("Error connectiong \(error.userInfo)")
        }
    }

    func disconnectFromServer() {
        fayeClient.disconnect({ () -> Void in
            self.transmitting = false;
            self.transmitButton.titleLabel?.text = "Transmit"
            //TODO: make sure messaging server kills the channel
            }, failure: { (error) -> Void in
                NSLog("Failed to disconnect from server!")
        })
    }

}

