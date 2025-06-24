//
//  BmobPush.m
//  BmobSDK
//
//  Created by Bmob on 14-4-26.
//  Copyright (c) 2014年 Bmob. All rights reserved.
//

#import "BmobPush.h"
#import "BmobQuery.h"
#import "BCommonUtils.h"
#import "BHttpClientUtil.h"
#import <UIKit/UIKit.h>
#import "BRequestDataFormat.h"
#import "SDKAPIManager.h"

@interface BmobPush(){
    NSMutableArray          *_mutableChannels;
    NSMutableDictionary     *_whereMutableDic;
    NSMutableDictionary     *_dataMutableDic;
}



@end

@implementation BmobPush



-(id)init{
    self = [super init];
    if (self) {
        _whereMutableDic     = [[NSMutableDictionary alloc] init];
        _mutableChannels     = [[NSMutableArray alloc] init];
        _dataMutableDic      = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

+(BmobPush *)push{
    BmobPush   *bmobPush = [[[self class] alloc] init];
    
    return bmobPush;
}

-(void)setQuery:(BmobQuery*)query{
    NSDictionary *tmpDic = [self queryDictionary:query];
    
    if (tmpDic) {
        [_whereMutableDic setDictionary:tmpDic];
    }
}


-(NSDictionary*)queryDictionary:(BmobQuery*)query{
    if (query) {
        
        return [query valueForKey:@"queryDic"];
        
    }
    return nil;
}

- (void)setChannels:(NSArray *)channels{
    if (channels) {
        [_mutableChannels setArray:channels];
    }
}
- (void)setChannel:(NSString *)channel{
    if (!channel || [channel isEqualToString:@""]) {
        return;
    }
    [_mutableChannels removeAllObjects];
    [_mutableChannels addObject:channel];
}

- (void)setMessage:(NSString *)message{
    if (!message || [message isEqualToString:@""]) {
        return;
    }
    NSDictionary  *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:message,@"alert", nil];
    [_dataMutableDic setObject:tmpDic forKey:@"data"];
}
- (void)setData:(NSDictionary *)data{
    if ([data count] > 0) {
        [_dataMutableDic setObject:data forKey:@"data"];
    }
}
- (void)expireAtDate:(NSDate *)date{
    if (!date) {
        return;
    }
    NSString  *expiredDateString = [BCommonUtils stringOfDate:date];
    [_dataMutableDic setObject:expiredDateString forKey:@"expiration_time"];
}
- (void)expireAfterTimeInterval:(NSTimeInterval)timeInterval{
    [_dataMutableDic setObject:[NSNumber numberWithDouble:timeInterval] forKey:@"expiration_interval"];
}

-(void)pushDate:(NSDate *)date{
    if (!date) {
        return;
    }
    NSString    *pushDateString = [BCommonUtils stringOfDate:date];
    [_dataMutableDic setObject:pushDateString forKey:@"push_time"];
}

- (BOOL)sendPush:(NSError **)error{

    return YES;
}

- (void)sendPushInBackground{
    [self sendPushInBackgroundWithBlock:nil callbackOrNot:NO];
}

- (void)sendPushInBackgroundWithBlock:(BmobBooleanResultBlock)block{
    [self sendPushInBackgroundWithBlock:block callbackOrNot:YES];
}

-(void)sendPushInBackgroundWithBlock:(BmobBooleanResultBlock)block callbackOrNot:(BOOL)needCallBack{
    
    if ([_whereMutableDic count] > 0) {
        [_dataMutableDic setObject:_whereMutableDic forKey:@"where"];
    }
    if ([_mutableChannels count] > 0) {
        [_dataMutableDic setObject:_mutableChannels forKey:@"channels"];
    }

    NSDictionary  *requestDic = [BRequestDataFormat requestDictionaryWithData:_dataMutableDic];
    
    NSString *pushUrl = [[SDKAPIManager defaultAPIManager] pushInterface];
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:pushUrl];
    [requestUtil addParameter:requestDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     NSDictionary    *pushDic =dictionary;
                     if (needCallBack) {
                         if (pushDic && pushDic.count > 0) {
                             if ([[[pushDic objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                                 if (block) {
                                     block(YES,nil);
                                 }
                             }
                             else{
                                 if (block) {
                                     NSError *error = [BCommonUtils errorWithResult:pushDic];
                                     block(NO,error);
                                 }
                                 
                             }
                         }
                         else{
                             if (block) {
                                 NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                 block(NO,error);
                             }
                            
                         }
                     }
                 } failBlock:^(NSError *err){
                     if (needCallBack) {
                         if (block) {
                             BmobErrorType type = BmobErrorTypeConnectFailed;
                             if (err) {
                                 type = (BmobErrorType)err.code;
                             }
                             NSError * error = [BCommonUtils errorWithType:type];
                             block(NO,error);
                         }
                     }
                 }];
    
}

+ (void)handlePush:(NSDictionary *)userInfo{
    
    if ([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]) {
        NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
        NSString*  appName    = [infoDic objectForKey:@"CFBundleDisplayName"];
        NSString*  notificatoContent = [[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] description];
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:appName
                                                            message:notificatoContent
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        
    }
    
}


+(NSDictionary*)queryDictionary:(BmobQuery*)query{
    if (query) {
        return [query valueForKey:@"queryDic"];
    }
    return nil;
}

+ (void)sendPushMessageToChannelInBackground:(NSString *)channel withMessage:(NSString *)message{
    if(!message || [message isEqualToString:@""]) {
        return;
    }
     NSDictionary *messageDic = [NSDictionary dictionaryWithObject:message forKey:@"alert"];
    [self sendPushMessageToChannelInBackground:channel
                                     withQuery:nil
                                      withdata:messageDic
                                         block:nil
                                 callbackOrNot:NO];
}

+ (void)sendPushMessageToChannelInBackground:(NSString *)channel  withMessage:(NSString *)message block:(BmobBooleanResultBlock)block{

    if(!message || [message isEqualToString:@""]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullPushContent];
                block(NO,error);
            }
        });
        
        
    }else{
        NSDictionary *messageDic = [NSDictionary dictionaryWithObject:message forKey:@"alert"];
        [self sendPushMessageToChannelInBackground:channel
                                         withQuery:nil
                                          withdata:messageDic
                                             block:block
                                     callbackOrNot:YES];
    }
    
}

+ (void)sendPushMessageToQueryInBackground:(BmobQuery *)query withMessage:(NSString *)message{
    if (!message || [message isEqualToString:@""]) {
        return;
    }
    
    NSDictionary *messageDic = [NSDictionary dictionaryWithObject:message forKey:@"alert"];
    [self sendPushMessageToChannelInBackground:nil
                                     withQuery:query
                                      withdata:messageDic
                                         block:nil
                                 callbackOrNot:NO];
}

+ (void)sendPushMessageToQueryInBackground:(BmobQuery *)query
                               withMessage:(NSString *)message
                                     block:(BmobBooleanResultBlock)block{
    if (!message || [message isEqualToString:@""]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullPushContent];
                block(NO,error);
            }
        });
        
        
    }else{
        NSDictionary *messageDic = [NSDictionary dictionaryWithObject:message forKey:@"alert"];
        [self sendPushMessageToChannelInBackground:nil
                                         withQuery:query
                                          withdata:messageDic
                                             block:block
                                     callbackOrNot:YES];
    }
}


+ (void)sendPushDataToChannelInBackground:(NSString *)channel
                                 withData:(NSDictionary *)data{
    if (!data) {
    }else{
        [self sendPushMessageToChannelInBackground:channel
                                         withQuery:nil
                                          withdata:data
                                             block:nil
                                     callbackOrNot:NO];
    }
}

+ (void)sendPushDataToChannelInBackground:(NSString *)channel
                                 withData:(NSDictionary *)data
                                    block:(BmobBooleanResultBlock)block{
    if (!data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullPushContent];
                block(NO,error);
            }

        });
        
    }else{
        [self sendPushMessageToChannelInBackground:channel
                                         withQuery:nil
                                          withdata:data
                                             block:block
                                     callbackOrNot:YES];
    }
}

+ (void)sendPushDataToQueryInBackground:(BmobQuery *)query
                               withData:(NSDictionary *)data{
    if (!data) {
        
    }else{
        [self sendPushMessageToChannelInBackground:nil
                                         withQuery:query
                                          withdata:data
                                             block:nil
                                     callbackOrNot:NO];
    }
}

+ (void)sendPushDataToQueryInBackground:(BmobQuery *)query
                               withData:(NSDictionary *)data
                                  block:(BmobBooleanResultBlock)block{
    if (!data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullPushContent];
                block(NO,error);
            }
        });
        
        
    }else{
        [self sendPushMessageToChannelInBackground:nil
                                         withQuery:query
                                          withdata:data
                                             block:block
                                     callbackOrNot:YES];
    }
}

//通用实例方法，channel为频道，query为约束条件，data为push的内容，block为回调，needCallback为是否需要回调
+ (void)sendPushMessageToChannelInBackground:(NSString*)channel
                                 withQuery:(BmobQuery *)query
                                     withdata:(NSDictionary *)data
                                     block:(BmobBooleanResultBlock)block
                             callbackOrNot:(BOOL)needCallBack{
    
    
    
    //最终的data
    NSMutableDictionary *tmpDataDic = [NSMutableDictionary dictionary];
    //where 限制条件
    if (query) {
        NSDictionary *tmpWhereDic = [self queryDictionary:query];
        if ([tmpWhereDic count] > 0) {
            [tmpDataDic setObject:tmpWhereDic forKey:@"where"];
        }
    }
    if ([data count] > 0) {
        [tmpDataDic setObject:data forKey:@"data"];
    }
    if (channel) {
        if ([channel length] > 0) {
            [tmpDataDic setObject:[NSArray arrayWithObject:channel] forKey:@"channels"];
        }
    }

    
    NSDictionary *requestDic = [BRequestDataFormat requestDictionaryWithData:tmpDataDic];
    
    NSString *pushUrl = [[SDKAPIManager defaultAPIManager] pushInterface];
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:pushUrl];
    [requestUtil addParameter:requestDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     NSDictionary    *pushDic =dictionary;
                     if (needCallBack) {
                         if (pushDic && pushDic.count > 0) {
                             if ([[[pushDic objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                                 if (block) {
                                     block(YES,nil);
                                 }
                                 
                             }
                             else{
                                 if (block) {
                                     NSError *error = [BCommonUtils errorWithResult:pushDic];
                                     block(NO,error);
                                 }
                                 
                             }
                         }
                         else{
                             if (block) {
                                 NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                 block(NO,error);
                             }
                             
                         }
                     }
                 } failBlock:^(NSError *err){
                     if (needCallBack) {
                         if (block) {
                             BmobErrorType type = BmobErrorTypeConnectFailed;
                             if (err) {
                                 type = (BmobErrorType)err.code;
                             }
                             NSError * error = [BCommonUtils errorWithType:type];
                             block(NO,error);
                         }
                         
                     }
                 }];
}

-(void)dealloc{
    
    _whereMutableDic     = nil;
    _mutableChannels     = nil;
    _dataMutableDic      = nil;
    
}

@end
