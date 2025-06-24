//
//  BRequestDataUtil.h
//  BmobSDK
//
//  Created by Bmob on 16/2/20.
//  Copyright © 2016年 bmob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRequestDataFormat : NSObject

+(NSDictionary *)secretDictionaryWithAppKey:(NSString *)appKey;

+(NSDictionary *)initDictionary;

+(NSDictionary *)requestDictionaryWithData:(NSDictionary *)data ;

+(NSDictionary *)requestDictionaryWithClassname:(NSString *)classname data:(NSDictionary *)data ;

+(NSDictionary *)requestDictionaryWithClassname:(NSString *)classname data:(NSDictionary *)data extraPara:(NSDictionary *)para;

+(NSDictionary *)requestDictionaryWithClassname:(NSString *)classname data:(NSDictionary *)data objectId:(NSString *)objectId;

@end
