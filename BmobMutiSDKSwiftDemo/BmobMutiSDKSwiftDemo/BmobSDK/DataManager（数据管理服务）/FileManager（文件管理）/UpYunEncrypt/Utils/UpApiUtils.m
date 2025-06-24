//
//  UpApiUtils.m
//  UpYunSDKDemo
//
//  Created by DING FENG on 2/13/17.
//  Copyright © 2017 upyun. All rights reserved.
//

#import "UpApiUtils.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

#define UPYUN_FILE_MD5_CHUNK_SIZE (1024*64)

@implementation UpApiUtils


+ (NSString *)getPolicyWithParameters:(NSDictionary *)parameter {
    /*Policy生成步骤：
      第 1 步：将请求参数键值对转换为 JSON 字符串；
      第 2 步：将第 1 步所得到的字符串进行 Base64 Encode 处理，得到 policy。
     */
    
    NSString *policy;
    NSDictionary *info = parameter;
    NSString *jsonString;
    if ([NSJSONSerialization isValidJSONObject:info]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        
        jsonString = [[NSString alloc] initWithData:jsonData
                                           encoding:NSUTF8StringEncoding];
        if (!error && jsonString) {
            policy = [UpApiUtils base64EncodeFromString:jsonString];
        }
        
    }
    
    if (!policy) {
        policy = @"";//一个无效policy
    }
    return policy;
}

+ (NSDictionary *)getDictFromPolicyString:(NSString *)policyString {
    
    NSString *jsonString = [UpApiUtils base64DecodeFromString:policyString];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:kNilOptions
                                                           error:&error];

    if (!error && json) {
        return  json;
        
    } else {
        NSLog(@"error %@", error);
    }
    return  nil;
}

+ (NSString *)getValueInPolicyDic:(NSDictionary *)policyDic OfKey:(NSString *)key {

    for (NSString *dicKey in policyDic.allKeys) {
        if ([key compare:dicKey options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            return [policyDic objectForKey:dicKey];
        }
    }

    NSLog(@"错误----未找到 %@ 对应的值", key);
    return @"";
}


+ (NSString *)getSignatureWithPassword:(NSString *)password
                            parameters:(NSArray *)parameter {
    /*Signature 计算方式
     <Signature> = Base64 (HMAC-SHA1 (<Password>,
     <Method>&
     <URI>&
     <Date>&
     <Content-MD5>
     ))
     */
    
    NSString *parameterString = [parameter componentsJoinedByString:@"&"];
    
    
    NSString *passwordHash = password;
//    NSString *passwordHash = [UpApiUtils getMD5HashFromData:[NSData dataWithBytes:password.UTF8String
//                                                                           length:password.length]];
    
    NSString *signature = [UpApiUtils getHmacSha1HashWithKey:passwordHash
                                                      string:parameterString];
    
    if (!signature) {
        signature = @"";//一个无效signature
    }
    return signature;//signature 已经是 Base64 编码
}


+ (NSString*)getMD5HashFromData:(NSData *)data {
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1],
            result[2], result[3],
            result[4], result[5],
            result[6], result[7],
            result[8], result[9],
            result[10], result[11],
            result[12], result[13],
            result[14], result[15]];
}


+ (NSString *)getMD5HashOfFileAtPath:(NSString *)path {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if (handle == nil) {
        NSLog(@"ERROR GETTING FILE SHA256: file didn't exist");
        return nil;
    }

    CC_SHA256_CTX sha256;
    CC_SHA256_Init(&sha256);

    BOOL done = NO;
    while (!done) {
        @autoreleasepool {
            NSData *fileData = [handle readDataOfLength:UPYUN_FILE_MD5_CHUNK_SIZE];
            CC_SHA256_Update(&sha256, [fileData bytes], (CC_LONG)[fileData length]);
            if ([fileData length] == 0) done = YES;
        }
    }

    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256_Final(digest, &sha256);

    NSMutableString *s = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [s appendFormat:@"%02x", digest[i]];
    }

    return s;
}


+ (NSString *)base64EncodeFromString:(NSString *)string {
    NSData *stingData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *base64Data = [stingData base64EncodedDataWithOptions:0];
    NSString *base64String = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    if (!base64String) {
        NSLog(@"===  %@ %@", string, base64Data);
    }
    return base64String;
}

+ (NSString *)base64DecodeFromString:(NSString *)base64String {
    NSData *stringData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    NSString *string = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    
    return string;
}

+ (NSString *)getHmacSha1HashWithKey:(NSString *)key string:(NSString *)string {
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [string cStringUsingEncoding:NSUTF8StringEncoding];
    char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    NSData *hashData = [HMAC base64EncodedDataWithOptions:0];
    NSString *hashString = [[NSString alloc] initWithData:hashData encoding:NSUTF8StringEncoding];
    
    
    return hashString;
}

//http://stackoverflow.com/questions/1363813/how-can-you-read-a-files-mime-type-in-objective-c
+ (NSString*)mimeTypeOfFileAtPath: (NSString *) path {
    NSString* res = nil;
    // NSURL will read the entire file and may exceed available memory if the file is large enough. Therefore, we will write the first fiew bytes of the file to a head-stub for NSURL to get the MIMEType from.
    NSFileHandle *readFileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *fileHead = [readFileHandle readDataOfLength:100]; // we probably only need 2 bytes. we'll get the first 100 instead.
    NSString *tempPath = [NSHomeDirectory() stringByAppendingPathComponent: @"tmp/fileHead.tmp"];
    [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil]; // delete any existing version of fileHead.tmp
    if ([fileHead writeToFile:tempPath atomically:YES])
    {
        NSURL* fileUrl = [NSURL fileURLWithPath:path];
        NSURLRequest* fileUrlRequest = [[NSURLRequest alloc] initWithURL:fileUrl
                                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                         timeoutInterval:.1];
        
        NSError* error = nil;
        NSURLResponse* response = nil;
        [NSURLConnection sendSynchronousRequest:fileUrlRequest returningResponse:&response error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
        res = [response MIMEType];
    }
    if(res)
        return res;
    return @"application/octet-stream";
}

+ (NSString*)lengthOfFileAtPath:(NSString *) path {
    NSError *attributesError = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path
                                                                                    error:&attributesError];
    return  [NSString stringWithFormat:@"%@", [fileAttributes objectForKey:@"NSFileSize"]];
}

///  dic to query tring
+ (NSString*)queryStringFrom:(NSDictionary *)parameters {
    
    
    NSString *result = nil;
    NSMutableString *postParameters = [[NSMutableString alloc] init];
    for (NSString *key in parameters.allKeys) {
        NSString *keyValue = [NSString stringWithFormat:@"&%@=%@",key, [parameters objectForKey:key]];
        [postParameters appendString:keyValue];
    }
    if (postParameters.length > 1) {
        result = [postParameters substringFromIndex:1];
    }
    return result;

}

/// 获取当前 GMT 时间字符串
+ (NSString *)getNowDateStr {

    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"EEE, dd MMM y HH:mm:ss zzz"];
    NSString *date = [dateFormatter stringFromDate:now];

    return date;
}


@end
