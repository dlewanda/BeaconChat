//
//  ChatViewController.swift
//  BeaconChat
//
//  Created by David Lewanda on 2/9/16.
//  Copyright © 2016 Dave Lewanda. All rights reserved.
//

import UIKit
import SlackTextViewController

struct Message {
    var timestamp: String = ""
    var text: String = ""
}

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    let MAX_SIZE: Int = 10000

    @IBOutlet weak var chatLogTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!


    var fayeClientVC: FayeClientViewController? = nil

    var messages: Array<Message> = []
    var nextIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        chatLogTableView.delegate = self
        chatLogTableView.dataSource = self

        messageTextField.delegate = self

        // Do any additional setup after loading the view.
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendMessage(sender: AnyObject) {
        sendMessage()
    }

    func sendMessage() {
        if let fayeClientVC = fayeClientVC {
            fayeClientVC.sendMessage(messageTextField.text!)
            messageTextField.text = ""
        }
    }

    func messageReceived(msgText: String) {
        var message = Message()
        message.text = msgText

        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        message.timestamp = formatter.stringFromDate(date)

        if messages.count < MAX_SIZE {
            messages.insert(message, atIndex: nextIndex)
        } else {
            messages[nextIndex] = message
        }

        nextIndex = (nextIndex + 1) % MAX_SIZE
        chatLogTableView.reloadData()
        //scroll table to end after reload
        let lastIndexPath = NSIndexPath(forRow: chatLogTableView.numberOfRowsInSection(0) - 1, inSection: chatLogTableView.numberOfSections - 1)
        chatLogTableView.scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }

    func setConnected(connected: Bool) {
        messageTextField.enabled = connected
        sendButton.enabled = connected
    }

    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = self.messages[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell")! as UITableViewCell
        cell.textLabel?.text = "\(message.timestamp): \(message.text)"
        cell.backgroundColor = ((indexPath.row % 2) == 1) ? UIColor.whiteColor() : UIColor.lightGrayColor()
        return cell
    }

    // MARK: UITableViewDataSource

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: UITextViewDelegate
    /**
    * Called when 'return' key pressed. return NO to ignore.
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //messageTextField.resignFirstResponder()
        sendMessage()
        return true
    }

}
