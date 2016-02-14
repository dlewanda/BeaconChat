# BeaconChat
Mobile app for chatting with those close to you.

Written in Swift targeting iOS 9.0+ to learn about Swift and UIStackViews

## Overview
This iOS app, with the help of a messaging server that it can connect to, can serve as a host or guest for a chat application where the chat room name is generated based on the iBeacon identifiers (major and minor number) of the host. The host subscribes to a channel which it then broadcasts the unique identifiers for as an iBeacon transmitter. The guest listens for the beacon and joins the chat room when it detects it the first time. If the beacon goes out of range, the client disconnects.

### Chat Host
In the current iteration, the Chat Host can specify a messaging server address (as a fully qualified URL) and a major and minor number to transmit for the beacon. When the _**Transmit**_ button is tapped, the app will attempt to connect to the specified message server and then subscribe to the channel it wishes to host. If that connection and subscription occurs succesfully, the host turns on it's beacon and starts transmitting.

### Chat Guest
Once the user selects to be a chat guest the application starts listening for beacons with the matching UUID. If a beacon is found, the application will attempt to connect to the messaging server and then subscribe to the appropriate channel. For now, the chat client must manually specify the same messaging server as the host to which it wants to connect. If it detects one, it attempts to subscribe to the channel as identified by the detected beacon. If multiple beacons are detected, it will connect to the last one found (for now). It will then announce it's proxmity to the host, and continue to range. If the proximity changes, it will announce it's proximity again.

**NOTE:** Apple only allows iOS to listen for beacons with a specific UUID via the CoreLocation/CoreBluetooth Beacon implementation, as opposed to OS X which can range for all beacons no matter what UUID.

## TODO:
* Only allow the host to create a channel
* Authenticate users
* Decouple configuration from application
* Add structure to messages to
  * identify users
  * pass along timestamps?
* Better error notification
* Performance Optimization
* UX Improvements

