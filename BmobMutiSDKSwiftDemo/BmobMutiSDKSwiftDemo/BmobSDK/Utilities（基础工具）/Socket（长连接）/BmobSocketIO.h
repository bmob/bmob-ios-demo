//
//  SocketIO.h
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


@class BmobSocketIO;
@class BmobSocketIOPacket;

typedef void(^SocketIOCallback)(id argsData);

extern NSString* const bmobkSocketIOError;

typedef enum {
    SocketIOServerRespondedWithInvalidConnectionData = -1,
    SocketIOServerRespondedWithDisconnect = -2,
    SocketIOHeartbeatTimeout = -3,
    SocketIOWebSocketClosed = -4,
    SocketIOTransportsNotSupported = -5,
    SocketIOHandshakeFailed = -6,
    SocketIODataCouldNotBeSend = -7,
    SocketIOUnauthorized = -8
} SocketIOErrorCodes;


@protocol BmobSocketIODelegate <NSObject>
@optional
- (void) socketIODidConnect:(BmobSocketIO *)socket;
- (void) socketIODidDisconnect:(BmobSocketIO *)socket disconnectedWithError:(NSError *)error;
- (void) socketIO:(BmobSocketIO *)socket didReceiveMessage:(BmobSocketIOPacket *)packet;
- (void) socketIO:(BmobSocketIO *)socket didReceiveJSON:(BmobSocketIOPacket *)packet;
- (void) socketIO:(BmobSocketIO *)socket didReceiveEvent:(BmobSocketIOPacket *)packet;
- (void) socketIO:(BmobSocketIO *)socket didSendMessage:(BmobSocketIOPacket *)packet;
- (void) socketIO:(BmobSocketIO *)socket onError:(NSError *)error;
@end

//201712-8去掉NSURLConnectionDelegate
@interface BmobSocketIO : NSObject <NSURLSessionDataDelegate,NSURLSessionDelegate,NSURLSessionTaskDelegate, BmobSocketIOTransportDelegate>
{
    NSString *_host;
    NSInteger _port;
    NSString *_sid;
    NSString *_endpoint;
    NSDictionary *_params;
    
    __weak id<BmobSocketIODelegate> _delegate;
    
    NSObject <BmobSocketIOTransport> *_transport;
    
    BOOL _isConnected;
    BOOL _isConnecting;
    BOOL _useSecure;
    
    NSArray *_cookies;
    
//    NSURLConnection *_handshake;
    NSURLSession *_handshake;
    NSURLSessionTask *_handshakeTask;
    
    // heartbeat
    NSTimeInterval _heartbeatTimeout;
    dispatch_source_t _timeout;
    
    NSMutableArray *_queue;
    
    // acknowledge
    NSMutableDictionary *_acks;
    NSInteger _ackCount;
    
    // http request
    NSMutableData *_httpRequestData;
    
    // get all arguments from ack? (https://github.com/pkyeck/socket.IO-objc/pull/85)
    BOOL _returnAllDataFromAck;
}

@property (nonatomic, readonly) NSString *host;
@property (nonatomic, readonly) NSInteger port;
@property (nonatomic, readonly) NSString *sid;
@property (nonatomic, readonly) NSTimeInterval heartbeatTimeout;
@property (nonatomic) BOOL useSecure;
@property (nonatomic,strong) NSArray *cookies;
@property (nonatomic, readonly) BOOL isConnected, isConnecting;
@property (nonatomic, weak) id<BmobSocketIODelegate> delegate;
@property (nonatomic) BOOL returnAllDataFromAck;

- (id) initWithDelegate:(id<BmobSocketIODelegate>)delegate;
- (void) connectToHost:(NSString *)host onPort:(NSInteger)port;
- (void) connectToHost:(NSString *)host onPort:(NSInteger)port withParams:(NSDictionary *)params;
- (void) connectToHost:(NSString *)host onPort:(NSInteger)port withParams:(NSDictionary *)params withNamespace:(NSString *)endpoint;
- (void) connectToHost:(NSString *)host onPort:(NSInteger)port withParams:(NSDictionary *)params withNamespace:(NSString *)endpoint withConnectionTimeout: (NSTimeInterval) connectionTimeout;

- (void) disconnect;
- (void) disconnectForced;

- (void) sendMessage:(NSString *)data;
- (void) sendMessage:(NSString *)data withAcknowledge:(SocketIOCallback)function;
- (void) sendJSON:(NSDictionary *)data;
- (void) sendJSON:(NSDictionary *)data withAcknowledge:(SocketIOCallback)function;
- (void) sendEvent:(NSString *)eventName withData:(id)data;
- (void) sendEvent:(NSString *)eventName withData:(id)data andAcknowledge:(SocketIOCallback)function;
- (void) sendAcknowledgement:(NSString*)pId withArgs:(NSArray *)data;

- (void) setResourceName:(NSString *)name;

@end
