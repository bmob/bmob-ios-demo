//
//  BmobEvent.m
//  BmobSDK
//
//  Created by Bmob on 14-7-4.
//  Copyright (c) 2014年 Bmob. All rights reserved.
//

#import "BmobEvent.h"
#import "BmobSocketIO.h"
#import "BmobSocketIOPacket.h"
#import "BHttpClientUtil.h"
#import "BCommonUtils.h"
#import "BEncryptUtil.h"
#import "BmobManager.h"

@interface BmobEvent ()<BmobSocketIODelegate>{
    BmobSocketIO   *_bmobSocketIO;
    
}

@end

@implementation BmobEvent

@synthesize delegate = _delegate;


#define EventAppKey     @"appKey"
#define EventTableName  @"tableName"
#define EventObjectId   @"objectId"

- (instancetype)init
{
    self = [super init];
    if (self) {
        _bmobSocketIO = [[BmobSocketIO alloc] initWithDelegate:self];
    }
    return self;
}



+(instancetype)defaultBmobEvent{
    static BmobEvent *event = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        event = [[[self class] alloc] init];
    });
    
    return event;
}


-(void)start{
    if (!_bmobSocketIO.isConnected && !_bmobSocketIO.isConnecting) {
        
        NSArray *addressArray = [BCommonUtils ioAddressAndPort];
        
        [_bmobSocketIO connectToHost:[addressArray firstObject] onPort:[[addressArray lastObject] intValue]];
    }
}

-(void)stop{
    [_bmobSocketIO disconnectForced];
}

-(BOOL)isConnected{
    return _bmobSocketIO.isConnected;
}



#pragma mark 订阅

-(void)listenTableChange:(BmobActionType)actionType tableName:(NSString *)tableName{
    
    if (!tableName || [tableName length] == 0) {
        return;
    }
    if (actionType == BmobActionTypeUpdateTable) {
        NSString *dataString = [self eventDicWithType:BmobActionTypeUpdateTable tableName:tableName objectId:@""];
        [_bmobSocketIO sendEvent:@"client_sub" withData:dataString ];
    }else if(actionType == BmobActionTypeDeleteTable){
        NSString *dataString = [self eventDicWithType:BmobActionTypeDeleteTable tableName:tableName objectId:@""];
        [_bmobSocketIO sendEvent:@"client_sub" withData:dataString];
    }
    
    
}

-(void)listenRowChange:(BmobActionType)actionType tableName:(NSString *)tableName objectId:(NSString *)objectId{
    
    if (!tableName || [tableName length] == 0) {
        return;
    }
    if (!objectId || [objectId length] == 0) {
        return;
    }
    if (actionType == BmobActionTypeUpdateRow) {
        NSString *dataString = [self eventDicWithType:BmobActionTypeUpdateRow tableName:tableName objectId:objectId];
        [_bmobSocketIO sendEvent:@"client_sub" withData:dataString];
    }else if(actionType == BmobActionTypeDeleteRow){
        NSString *dataString = [self eventDicWithType:BmobActionTypeDeleteRow tableName:tableName objectId:objectId];

        [_bmobSocketIO sendEvent:@"client_sub" withData:dataString];
    }
    
    
}

#pragma mark 取消订阅

-(void)cancelListenTableChange:(BmobActionType)actionType tableName:(NSString *)tableName{
    if (!tableName || [tableName length] == 0) {
        return;
    }
    if (actionType == BmobActionTypeUpdateTable) {
        NSString *dataString = [self unSubEventDicWithType:BmobActionTypeUpdateTable tableName:tableName objectId:@""];
        [_bmobSocketIO sendEvent:@"client_unsub" withData:dataString];
    }else if(actionType == BmobActionTypeDeleteTable){
        NSString *dataString = [self unSubEventDicWithType:BmobActionTypeDeleteTable tableName:tableName objectId:@""];
        [_bmobSocketIO sendEvent:@"client_unsub" withData:dataString];
    }
}

-(void)cancelListenRowChange:(BmobActionType)actionType tableName:(NSString *)tableName objectId:(NSString *)objectId{
    if (!tableName || [tableName length] == 0) {
        return;
    }
    if (!objectId || [objectId length] == 0) {
        return;
    }
    if (actionType == BmobActionTypeUpdateRow) {
        NSString *dataString = [self unSubEventDicWithType:BmobActionTypeUpdateRow tableName:tableName objectId:objectId];
        [_bmobSocketIO sendEvent:@"client_unsub" withData:dataString];
        
    }else if(actionType == BmobActionTypeDeleteRow){
        NSString *dataString = [self unSubEventDicWithType:BmobActionTypeDeleteRow tableName:tableName objectId:objectId];
        [_bmobSocketIO sendEvent:@"client_unsub" withData:dataString];
    }
}


#pragma mark - mark 

-(NSString *)eventDicWithType:(BmobActionType)type tableName:(NSString *)tableName objectId:(NSString *)objectId{
    NSDictionary *tmpDic = nil;
    NSString *appKey = [BEncryptUtil decodeBase64String:[[NSString alloc] initWithData:[BmobManager defaultManager].apid encoding:NSUTF8StringEncoding]];
    switch (type) {
        case BmobActionTypeUpdateTable:{
            tmpDic = @{EventAppKey: appKey,EventTableName:tableName,EventObjectId:objectId,@"action":@"updateTable"};
        }
            break;
        case BmobActionTypeDeleteTable:{
            tmpDic = @{EventAppKey: appKey,EventTableName:tableName,EventObjectId:objectId,@"action":@"deleteTable"};
        }
            break;
        case BmobActionTypeUpdateRow:{
            tmpDic = @{EventAppKey: appKey,EventTableName:tableName,EventObjectId:objectId,@"action":@"updateRow"};
        }
            break;
        case BmobActionTypeDeleteRow:{
            tmpDic = @{EventAppKey: appKey,EventTableName:tableName,EventObjectId:objectId,@"action":@"deleteRow"};
        }
            break;
        default:
            break;
    }
    
    NSString *string = [BCommonUtils stringOfJson:tmpDic ];
    return string;
}

-(NSString *)unSubEventDicWithType:(BmobActionType)type tableName:(NSString *)tableName objectId:(NSString *)objectId{
    
    NSDictionary *tmpDic = nil;
    NSString *appKey = [BEncryptUtil decodeBase64String:[[NSString alloc] initWithData:[BmobManager defaultManager].apid encoding:NSUTF8StringEncoding]];
    switch (type) {
        case BmobActionTypeUpdateTable:{
            tmpDic = @{EventAppKey: appKey,EventTableName:tableName,EventObjectId:objectId,@"action":@"unsub_updateTable"};
        }
            break;
        case BmobActionTypeDeleteTable:{
            tmpDic = @{EventAppKey: appKey,EventTableName:tableName,EventObjectId:objectId,@"action":@"unsub_deleteTable"};
        }
            break;
        case BmobActionTypeUpdateRow:{
            tmpDic = @{EventAppKey: appKey,EventTableName:tableName,EventObjectId:objectId,@"action":@"unsub_updateRow"};
        }
            break;
        case BmobActionTypeDeleteRow:{
            tmpDic = @{EventAppKey: appKey,EventTableName:tableName,EventObjectId:objectId,@"action":@"unsub_deleteRow"};
        }
            break;
        default:
            break;
    }
    NSString *string = [BCommonUtils stringOfJson:tmpDic ];
    return string;
}

#pragma mark 

-(void)socketIODidConnect:(BmobSocketIO *)socket{
    if (_delegate && [_delegate respondsToSelector:@selector(bmobEventDidConnect:)]) {
        [_delegate bmobEventDidConnect:self];
    }
}


-(void)socketIO:(BmobSocketIO *)socket didReceiveEvent:(BmobSocketIOPacket *)packet{
    
    
    
    if ([packet.dataAsJSON  objectForKey:@"name"] && [packet.name isEqualToString:@"client_send_data"]) {
        if (_delegate && [_delegate respondsToSelector:@selector(bmobEventCanStartListen:)]) {
            [_delegate bmobEventCanStartListen:self];
        }
    }
    if ([packet.dataAsJSON objectForKey:@"name"] && [[packet.dataAsJSON objectForKey:@"name"] isEqualToString:@"server_pub"]) {
        if (_delegate && [_delegate respondsToSelector:@selector(bmobEvent:didReceiveMessage:)]) {
            [_delegate bmobEvent:self didReceiveMessage:[ packet.args firstObject]];
        }
    }
}

-(void)socketIO:(BmobSocketIO *)socket didSendMessage:(BmobSocketIOPacket *)packet{
   
}

-(void)socketIO:(BmobSocketIO *)socket onError:(NSError *)error{
    if (_delegate && [_delegate respondsToSelector:@selector(bmobEvent:error:)]) {
        [_delegate bmobEvent:self error:error];
    }
}

- (void) socketIODidDisconnect:(BmobSocketIO *)socket disconnectedWithError:(NSError *)error{
    if (_delegate && [_delegate respondsToSelector:@selector(bmobEventDidDisConnect:error:)]) {
        [_delegate bmobEventDidDisConnect:self error:error];
    }
}
@end


