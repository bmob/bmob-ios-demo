//
//  SocketIOTransportWebsocket.m
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

#import "BmobSocketIOTransportWebsocket.h"
#import "BmobSocketIO.h"

#define DEBUG_LOGS 0

#if DEBUG_LOGS
#define DEBUGLOG(...) NSLog(__VA_ARGS__)
#else
#define DEBUGLOG(...)
#endif

static NSString* kInsecureSocketURL = @"ws://%@/socket.io/1/websocket/%@";
static NSString* kSecureSocketURL = @"wss://%@/socket.io/1/websocket/%@";
static NSString* kInsecureSocketPortURL = @"ws://%@:%d/socket.io/1/websocket/%@";
static NSString* kSecureSocketPortURL = @"wss://%@:%d/socket.io/1/websocket/%@";

@implementation BmobSocketIOTransportWebsocket

@synthesize delegate;

- (id) initWithDelegate:(id<BmobSocketIOTransportDelegate>)delegate_
{
    self = [super init];
    if (self) {
        self.delegate = delegate_;
    }
    return self;
}

- (BOOL) isReady
{
    return _webSocket.readyState == SR_OPEN;
}

- (void) open
{
    NSString *urlStr;
    NSString *format;
    if (delegate.port) {
        format = delegate.useSecure ? kSecureSocketPortURL : kInsecureSocketPortURL;
        urlStr = [NSString stringWithFormat:format, delegate.host, delegate.port, delegate.sid];
    }
    else {
        format = delegate.useSecure ? kSecureSocketURL : kInsecureSocketURL;
        urlStr = [NSString stringWithFormat:format, delegate.host, delegate.sid];
    }
    NSURL *url = [NSURL URLWithString:urlStr];
    
    _webSocket = nil;
    
    _webSocket = [[BmobSRWebSocket alloc] initWithURL:url];
    _webSocket.delegate = self;
    DEBUGLOG(@"Opening %@", url);
    [_webSocket open];
}

- (void) dealloc
{
    [_webSocket setDelegate:nil];
}

- (void) close
{
    [_webSocket close];
}

- (void) send:(NSString*)request
{
    [_webSocket send:request];
}



# pragma mark -
# pragma mark WebSocket Delegate Methods

- (void) webSocket:(BmobSRWebSocket *)webSocket didReceiveMessage:(id)message
{
    if([delegate respondsToSelector:@selector(onData:)]) {
        [delegate onData:message];
    }
}

- (void) webSocketDidOpen:(BmobSRWebSocket *)webSocket
{
    DEBUGLOG(@"Socket opened.");
}

- (void) webSocket:(BmobSRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    DEBUGLOG(@"Socket failed with error ... %@", [error localizedDescription]);
    // Assuming this resulted in a disconnect
    if([delegate respondsToSelector:@selector(onDisconnect:)]) {
        [delegate onDisconnect:error];
    }
}

- (void) webSocket:(BmobSRWebSocket *)webSocket
  didCloseWithCode:(NSInteger)code
            reason:(NSString *)reason
          wasClean:(BOOL)wasClean
{
    DEBUGLOG(@"Socket closed. %@", reason);
    if([delegate respondsToSelector:@selector(onDisconnect:)]) {
        [delegate onDisconnect:[NSError errorWithDomain:bmobkSocketIOError
                                                   code:SocketIOWebSocketClosed
                                               userInfo:nil]];
    }
}

@end
