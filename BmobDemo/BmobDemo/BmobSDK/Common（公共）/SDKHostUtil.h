//
//  SDKHostManager.h
//  BmobSDK
//
//  Created by Bmob on 16/3/15.
//  Copyright © 2016年 donson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDKHostUtil : NSObject


+(void)saveAPIHost:(NSString *)host;

+(void)saveFileHost:(NSString *)host;

+(void)saveEventHost:(NSString *)host;

+(void)saveCloudHost:(NSString *)host;

+(void)saveUPYunVersion:(NSString *)version;

+(void)syncHosts;

+(void)saveUPYunHost:(NSString *)Host;

+(void)saveUPYunKey:(NSString *)key;

+(void)saveUPYunName:(NSString *)name;

+(void)saveMigration:(NSDictionary *)migration;

+(NSString *)apiHost;

+(NSString *)fileHost;

+(NSString *)upyunVersion;

+(NSArray *)ioAddressAndPort;

+(NSString *)upyunHost;

+(NSString *)upyunKey;

+(NSString *)upyunName;

@end
