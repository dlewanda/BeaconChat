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

enum FayeClientState
{
    case DISCONNECTED
    case CONNECTING
    case CONNECTED
    case DISCONNECTING
}

//classes that subclass FayeClientViewController should implement this protocol
protocol FayeClientDelegate {
    func connected()
    func subscribed(channel: String)
    func failure(error: NSError)
    func messageReceived(message: Dictionary<NSObject, AnyObject>)
}

class FayeClientViewController: UIViewController {

    internal var state: FayeClientState = FayeClientState.DISCONNECTED
    internal var channelName:String = ""

    private var fayeClient: MZFayeClient

    var chatViewController = ChatViewController()

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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let tapGesture = UITapGestureRecognizer(target: self, action: "tap:")
        view.addGestureRecognizer(tapGesture)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }

    func keyboardWillShow(notification: NSNotification) {
        adjustForKeyboard(notification, appearing: true)
    }

    func keyboardWillHide(notification: NSNotification) {
        adjustForKeyboard(notification, appearing: false)
    }

    func adjustForKeyboard(notification:NSNotification, appearing: Bool) {

        let userInfo = notification.userInfo
        let animationDuration = (userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSValue) as! Double
        let animationCurve = userInfo?[UIKeyboardAnimationCurveUserInfoKey]?.integerValue
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            UIView.animateWithDuration(animationDuration, delay: 0, options: animationOptionsWithCurve(animationCurve!), animations: { () -> Void in

                self.view.frame.origin.y += keyboardSize.height * (appearing ? -1 : 1)
                }, completion: { (finished: Bool) in
            })
        }
    }

    func animationOptionsWithCurve(curve: Int) -> UIViewAnimationOptions {
        return UIViewAnimationOptions(rawValue: UInt(curve << 16))
    }

    func tap(gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    func addChatViewController(chatView: UIView) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        chatViewController = storyboard.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
        chatViewController.fayeClientVC = self
        self.addChildViewController(chatViewController)
        chatViewController.view.frame = chatView.bounds
        chatView.addSubview(chatViewController.view)
        chatViewController.didMoveToParentViewController(self)
    }

    func connectToServer(serverAddress: String, channelName: String,
        connected:()->Void,
        subscribed:(String)->Void,
        messageReceived:(message:Dictionary<NSObject, AnyObject>)->Void,
        failure:(error: NSError)->Void) {
            state = .CONNECTING
            let serverUrl = NSURL.init(string: serverAddress)
            self.channelName = "/\(channelName)"
            fayeClient = MZFayeClient(URL: serverUrl) //TODO: check if this will this handle DNS, and autofill http:// prefix?
            fayeClient.subscribeToChannel(self.channelName, success: {
                subscribed(channelName)
                }, failure: { (error) -> Void in
                    failure(error: error)
                }, receivedMessage: { (message) -> Void in
                    messageReceived(message: message)
            })

            fayeClient.connect({ () -> Void in
                self.state = .CONNECTED
                self.chatViewController.setConnected(true)
                connected()
                self.sendMessage("Hello")
                }) { (error) -> Void in
                    failure(error: error)
            }
    }

    func disconnectFromServer(disconnected:()->Void, failure:(error: NSError)->Void) {
        if state == .CONNECTED || state == .CONNECTING {
            state = .DISCONNECTING
            chatViewController.setConnected(false)
            fayeClient.disconnect({ () -> Void in
                self.state = .DISCONNECTED
                disconnected()
                }, failure: { (error) -> Void in
                    failure(error: error)
            })
        }
    }

    func sendMessage(message: String) {
        self.fayeClient.sendMessage(["text":message], toChannel: self.channelName, success: { () -> Void in
            NSLog("Message sent successfully")
            }, failure: { (error) -> Void in
                NSLog("Error sending message: \(error)")
        })
    }

    func postMessage(message: String) {
        self.chatViewController.messageReceived(message)
    }

}
