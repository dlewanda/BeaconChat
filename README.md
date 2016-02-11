# BeaconChat
Mobile app for chatting with those close to you

## Overview
This iOS app, with the help of a messaging server that it can connect to, can serve as a host or guest for a chat application where the chat room name is generated based on the iBeacon identifiers (major and minor number) of the host. The host subscribes to a channel which it then broadcasts the unique identifiers for as an iBeacon transmitter. The guest listens for the beacon and joins the chat room when it detects it the first time. If the beacon goes out of range, the client disconnects.
