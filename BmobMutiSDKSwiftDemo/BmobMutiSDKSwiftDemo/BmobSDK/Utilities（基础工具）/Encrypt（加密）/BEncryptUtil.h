//
//  BEncryptUtil.h
//  BmobSDK
//
//  Created by Bmob on 16/2/24.
//  Copyright © 2016年 donson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BEncryptUtil : NSObject

#pragma mark - base64
+ (NSString*)encodeBase64String:(NSString *)input;
+ (NSString*)decodeBase64String:(NSString *)input;
+ (NSString*)encodeBase64Data:(NSData *)data;
+ (NSData *)encodeData:(NSData *)data;
+ (NSString*)decodeBase64Data:(NSData *)data;

+(NSString*)md5WithString:(NSString*)string;

+(NSString *)lowerMd5WithData:(NSData*)data;

+(NSString*)lowerMd5WithString:(NSString *)string;


+(NSData*)aEncryptedData:(NSData *)data  keyData:(NSData *)key ivData:(NSData *)iv;
+(NSData*)aDecryptedData:(NSData *)data  keyData:(NSData *)key ivData:(NSData *)iv;
+(NSString *)aS;


+ (NSData *)hmac_sha1:(NSString *)key text:(NSString *)text;


@end
