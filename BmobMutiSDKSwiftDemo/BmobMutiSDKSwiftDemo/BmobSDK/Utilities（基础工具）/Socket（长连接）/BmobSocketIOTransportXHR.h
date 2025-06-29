//
//  SocketIOTransportXHR.h
//  v0.5.1
//
//  based on
//  socketio-cocoa https://github.com/fpotter/socketio-cocoa
//  by Fred Potter <fpotter@pieceable.com>
//
//  using
//  https://github.com/square/SocketRocket
//
//  reusing some parts of
//  /socket.io/socket.io.js
//
//  Created by Philipp Kyeck http://beta-interactive.de
//
//  With help from
//    https://github.com/pkyeck/socket.IO-objc/blob/master/CONTRIBUTORS.md
//

#import <Foundation/Foundation.h>

#import "BmobSocketIOTransport.h"

@interface BmobSocketIOTransportXHR : NSObject <BmobSocketIOTransport, NSURLSessionDataDelegate,NSURLSessionDelegate,NSURLSessionTaskDelegate>
{
    NSString *_url;
    NSMutableData *_data;
    NSMutableDictionary *_polls;
    BOOL _isClosed;
}

@property (nonatomic, weak) id <BmobSocketIOTransportDelegate> delegate;
@property (nonatomic) BOOL isClosed;

@end
