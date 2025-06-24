//
//  BRequestDataUtil.m
//  BmobSDK
//
//  Created by Bmob on 16/2/20.
//  Copyright © 2016年 bmob. All rights reserved.
//

#import "BRequestDataFormat.h"
#import "BCommonUtils.h"

@implementation BRequestDataFormat

+(NSDictionary *)secretDictionaryWithAppKey:(NSString *)appKey{
    NSMutableDictionary  *requestDic = [NSMutableDictionary dictionaryWithCapacity:1];
    requestDic[@"client"]            = [BCommonUtils clientDic];
    requestDic[@"appKey"]            = appKey;
    requestDic[@"v"]                 = kBmobSDKVersion;
    return requestDic;
}

+(NSDictionary *)initDictionary{
    NSMutableDictionary  *requestDic = [NSMutableDictionary dictionaryWithCapacity:1];
    requestDic[@"client"]            = [BCommonUtils clientDic];
    requestDic[@"v"]                 = kBmobSDKVersion;
    return requestDic;
}

+(NSDictionary *)requestDictionaryWithData:(NSDictionary *)data{
    NSMutableDictionary  *requestDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [requestDic setObject:[BCommonUtils clientDic] forKey:@"client"];
    [requestDic setObject:kBmobSDKVersion forKey:@"v"];
    
    if (data ) {
        [requestDic setObject:data forKey:@"data"];
    }else{
        [requestDic setObject:[NSNull null] forKey:@"data"];
    }
    
    return requestDic;
}

+(NSDictionary *)requestDictionaryWithClassname:(NSString *)classname data:(NSDictionary *)data {

    NSMutableDictionary  *requestDic = [NSMutableDictionary dictionaryWithDictionary:[self requestDictionaryWithData:data]];
   
    if (classname) {
        [requestDic setObject:classname forKey:@"c"];
    }else{
        [requestDic setObject:[NSNull null] forKey:@"c"];
    }
    
    return requestDic;

}


+(NSDictionary *)requestDictionaryWithClassname:(NSString *)classname data:(NSDictionary *)data extraPara:(NSDictionary *)para{
    NSMutableDictionary  *requestDic = [NSMutableDictionary dictionaryWithDictionary:[self requestDictionaryWithClassname:classname data:data]];

    if (para != nil) {
        for (NSString *key in [para allKeys]) {
            [requestDic setObject:[para objectForKey:key] forKey:key];
        }
    }
    
    return requestDic;
}


+(NSDictionary *)requestDictionaryWithClassname:(NSString *)classname data:(NSDictionary *)data objectId:(NSString *)objectId{
    
    NSMutableDictionary  *requestDic = [NSMutableDictionary dictionaryWithDictionary:[self requestDictionaryWithClassname:classname data:data]];
    
    if (objectId) {
        [requestDic setObject:objectId forKey:@"objectId"];
    }
//    else{
//        [requestDic setObject:[NSNull null] forKey:@"objectId"];
//    }

    return requestDic;
    
}

@end
