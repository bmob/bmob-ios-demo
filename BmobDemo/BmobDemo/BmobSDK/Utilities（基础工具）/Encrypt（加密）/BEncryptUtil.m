//
//  BEncryptUtil.m
//  BmobSDK
//
//  Created by Bmob on 16/2/24.
//  Copyright © 2016年 donson. All rights reserved.
//

#import "BEncryptUtil.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation BEncryptUtil

#pragma mark - base64
+ (NSString*)encodeBase64String:(NSString * )input {
    
    NSData *data = [[input dataUsingEncoding:NSUTF8StringEncoding] base64EncodedDataWithOptions:0];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    return base64String;
}

+ (NSString*)decodeBase64String:(NSString * )input {
    NSData *data = [[input stringByReplacingOccurrencesOfString:@"%2B" withString:@"+"] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    data = [[NSData alloc] initWithBase64EncodedData:data options:0];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

+ (NSString*)encodeBase64Data:(NSData *)data {
    //    data = [BmobBase64 encodeData:data];
    NSData *encodeData = [data base64EncodedDataWithOptions:0];
    NSString *base64String = [[NSString alloc] initWithData:encodeData encoding:NSUTF8StringEncoding];
    return base64String;
}

+ (NSData *)encodeData:(NSData *)data{
     NSData *encodeData = [data base64EncodedDataWithOptions:0];
    return encodeData;
}

+ (NSString*)decodeBase64Data:(NSData *)data {
    data =  [[NSData alloc] initWithBase64EncodedData:data options:0];
    //[BmobBase64 decodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

+(NSString*)md5WithString:(NSString*)string
{
    const char *original_str = [string UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(original_str, (CC_LONG)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02X", result[i]];
    }
    return [hash lowercaseString];
}

+(NSString*)lowerMd5WithString:(NSString *)string{
    const char *original_str = [string UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(original_str, (CC_LONG)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", result[i]];
    }
    return [hash lowercaseString];
}


+(NSString *)lowerMd5WithData:(NSData*)data{
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x", result[i]];
    }
    return ret;
}

#pragma mark - aes
+(NSData*)aEncryptedData:(NSData *)data  keyData:(NSData *)key ivData:(NSData *)iv{
    return AES128Operation(kCCEncrypt, data, key, iv);
}

+(NSData*)aDecryptedData:(NSData *)data  keyData:(NSData *)key ivData:(NSData *)iv{
    return AES128Operation(kCCDecrypt, data, key, iv);
}


static NSData * AES128Operation(CCOperation operation,NSData *data ,NSData *key ,NSData *iv){
    //    char ivPtr[kCCBlockSizeAES128 + 1];
    //    bzero(ivPtr, sizeof(ivPtr));
    //    if (iv) {
    //        [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    //    }
    
    NSUInteger dataLength = [data length];
    size_t bufferSize     = dataLength + kCCBlockSizeAES128;
    void *buffer          = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding ,
                                          [key bytes],
                                          kCCBlockSizeAES128,
                                          [iv bytes],
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    NSData *AESData = nil;
    if (cryptStatus == kCCSuccess) {
        AESData = [NSData dataWithBytes:buffer length:numBytesEncrypted];//[NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    buffer = NULL;
    return AESData;
}

#pragma mark - app sign
/**
 *  返回app sign，即bundleID
 *
 *  @return 返回bundleID
 */
+(NSString *)aS{

    NSBundle *bundle      = [NSBundle mainBundle];
    NSDictionary *infoDic = bundle.infoDictionary;
    NSString *bundleID    = infoDic[(NSString *)kCFBundleIdentifierKey];
    int appModel = 0;
    if (PSPDFIsDevelopmentBuild()) {
        appModel = 0;
    }else{
        appModel = 1;
    }
    NSString *signString = [NSString stringWithFormat:@"%@/%d",bundleID,appModel];
    return signString;
}


static BOOL PSPDFIsDevelopmentBuild(void) {
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    static BOOL isDevelopment = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // There is no provisioning profile in AppStore Apps.
        NSData *data = [NSData dataWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"embedded" ofType:@"mobileprovision"]];
        
        if (data) {
            const char *bytes = [data bytes];
            NSMutableString *profile = [[NSMutableString alloc] initWithCapacity:data.length];
            for (NSUInteger i = 0; i < data.length; i++) {
                [profile appendFormat:@"%c", bytes[i]];
            }
            // Look for debug value, if detected we're a development build.
            NSString *cleared = [[profile componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] componentsJoinedByString:@""];
            isDevelopment = [cleared rangeOfString:@"<key>get-task-allow</key><true/>"].length > 0;
        }
    });
    return isDevelopment;
#endif
}

+ (NSData *)hmac_sha1:(NSString *)key text:(NSString *)text{

    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];

    char cHMAC[CC_SHA1_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];

    return HMAC;
}

@end
