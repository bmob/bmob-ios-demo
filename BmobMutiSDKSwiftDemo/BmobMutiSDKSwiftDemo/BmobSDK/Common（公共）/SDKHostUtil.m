//
//  SDKHostManager.m
//  BmobSDK
//
//  Created by Bmob on 16/3/15.
//  Copyright © 2016年 donson. All rights reserved.
//

#import "SDKHostUtil.h"
#import "BEncryptUtil.h"
#import "BCommonUtils.h"


@implementation SDKHostUtil


static NSString *apiKey         = @"b_bmob_ai";
static NSString *fileKey        = @"b_bmob_fi";
static NSString *ioKey          = @"b_bmob_io";
static NSString *cloudKey       = @"b_bmob_cl";
static NSString *upyunVerKey    = @"b_bmob_upyun_ver";

static NSString *upyunHostKey   = @"b_bmob_upyun_host";
static NSString *upyunSecretKey = @"b_bmob_upyun_secret";
static NSString *upyunName      = @"b_bmob_upyun_name";

static NSString * kKeyString    = @"bm0b2o16";


/**
 *  保存api 接口域名
 *
 *  @param host 域名
 */
+(void)saveAPIHost:(NSString *)host{
    [self saveEncodeStringWithHost:host key:apiKey];
}

/**
 *  保存文件 接口域名
 *
 *  @param host 域名
 */
+(void)saveFileHost:(NSString *)host{
    [self saveEncodeStringWithHost:host key:fileKey];
}


/**
 *  保存实时监控 接口域名
 *
 *  @param host 域名
 */
+(void)saveEventHost:(NSString *)host{
    [self saveEncodeStringWithHost:host key:ioKey];
}

/**
 *  保存云端代码 接口域名
 *
 *  @param host 域名
 */

+(void)saveCloudHost:(NSString *)host{
    [self saveEncodeStringWithHost:host key:cloudKey];
}

/**
 *  保存又拍云版本信息
 *
 *  @param version 版本号
 */
+(void)saveUPYunVersion:(NSString *)version{
    [self saveEncodeStringWithHost:version key:upyunVerKey];
}

+(void)saveEncodeStringWithHost:(NSString *)host key:(NSString *)key{
    NSString *base64String = [BEncryptUtil encodeBase64String:host];
    [[NSUserDefaults standardUserDefaults] setObject:base64String forKey:key];

}

+(void)saveUPYunHost:(NSString *)Host{
    [self saveEncodeStringWithHost:Host key:upyunHostKey];
}



+(void)saveUPYunKey:(NSString *)key{
    [self saveEncodeStringWithHost:key key:upyunSecretKey];
}

+(void)saveUPYunName:(NSString *)name{
    [self saveEncodeStringWithHost:name key:upyunName];
}


+(void)syncHosts{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)saveMigration:(NSDictionary *)migration{
    NSString *path = [[BCommonUtils cachePath] stringByAppendingPathComponent:kHostsSavedLocalPath];
    if (!migration || migration.count == 0) {

        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            debugLog(@"remove error %@",error);
        }

        return;
    }else{
        [migration writeToFile:path atomically:YES];
    }


}

+(NSString *)upyunHost{
    return [self decodeStringWithKey:upyunHostKey];
}

+(NSString *)upyunKey{
    NSString *encodeKey = [self decodeStringWithKey:upyunSecretKey];
    return encodeKey;
}

+(NSString *)upyunName{
    return  [self decodeStringWithKey:upyunName];
}

+(NSString *)apiHost{

    NSString *hostString = [self decodeStringWithKey:apiKey];

    NSString *serverAddress = nil;

    if (hostString && hostString.length > 0) {
        NSString *api       = nil;
        if ([hostString isEqualToString:@"https://opentest.bmob.cn"]) {
            api = @"https://open.cctvcloud.cn";
            serverAddress = api;
        }else if ([hostString isEqualToString:@"http://p.bmob.cn"]){
            api = @"https://open.cctvcloud.cn";
            serverAddress =api;
        }else{
            serverAddress =api;
        }
    }else{
        serverAddress =[NSString stringWithFormat:@"%@",@"https://open.cctvcloud.cn"];
    }

    return serverAddress;
}

+(NSString *)fileHost{

    NSString *hostString = [self decodeStringWithKey:fileKey];
    NSString *serverAddress = nil;
    if (hostString && hostString.length > 0) {
        serverAddress     = [NSString stringWithFormat:@"%@",hostString];
    }else{
        serverAddress =[NSString stringWithFormat:@"%@",@"https://file.bmob.cn"];
    }

    return serverAddress;
}


+(NSArray *)ioAddressAndPort{
    NSString *hostString = [self decodeStringWithKey:ioKey];

    if (hostString && hostString.length > 0) {
        NSArray *addArr     = [hostString componentsSeparatedByString:@":"];
        //端口
        NSString *port      = [addArr lastObject];
        NSString *ioAddress = [addArr firstObject];
        //地址
        ioAddress           = [hostString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        ioAddress           = [ioAddress stringByReplacingOccurrencesOfString:@"https://" withString:@""];
        ioAddress           = [ioAddress stringByReplacingOccurrencesOfString:@":" withString:@""];
        ioAddress           = [ioAddress stringByReplacingOccurrencesOfString:port withString:@""];
        NSArray *array =@[ioAddress,port];
        return array;
    }else{
        NSArray *array =@[@"io.codenow.cn",@"3010"];
        return array;
    }

}

+(NSString *)upyunVersion{
    NSString *upyunVersion = [self decodeStringWithKey:upyunVerKey];
    return upyunVersion;
}

+(NSString *)decodeStringWithKey:(NSString *)key{
    NSUserDefaults *standerDefaults = [NSUserDefaults standardUserDefaults];
    if (![standerDefaults objectForKey:key]) {
        return nil;
    }

    NSString *host = [BEncryptUtil decodeBase64String:[standerDefaults objectForKey:key]];
    return host;

}

@end
