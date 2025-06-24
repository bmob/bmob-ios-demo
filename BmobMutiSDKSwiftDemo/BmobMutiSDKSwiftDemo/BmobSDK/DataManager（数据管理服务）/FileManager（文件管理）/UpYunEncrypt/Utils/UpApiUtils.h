//
//  UpApiUtils.h
//  UpYunSDKDemo
//
//  Created by DING FENG on 2/13/17.
//  Copyright © 2017 upyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpApiUtils : NSObject


//文档：http://docs.upyun.com/api/authorization/

///生成上传策略和上传签名
+ (NSString *)getPolicyWithParameters:(NSDictionary *)parameter;
+ (NSString *)getSignatureWithPassword:(NSString *)password
                            parameters:(NSArray *)parameter;



+ (NSDictionary *)getDictFromPolicyString:(NSString *)policy;

/// 新版签名 参数 https://help.upyun.com/knowledge-base/object_storage_authorization/#e694bee59ca8-http-header-e4b8ad
+ (NSString *)getValueInPolicyDic:(NSDictionary *)policyDic OfKey:(NSString *)key;

///hash 方法
+ (NSString *)getMD5HashFromData:(NSData *)data;
+ (NSString *)getMD5HashOfFileAtPath:(NSString *)path;
+ (NSString *)base64EncodeFromString:(NSString *)string;
+ (NSString *)base64DecodeFromString:(NSString *)base64String;
+ (NSString *)getHmacSha1HashWithKey:(NSString *)key
                              string:(NSString *)string;

+ (NSString*)mimeTypeOfFileAtPath:(NSString *) path;
+ (NSString*)lengthOfFileAtPath:(NSString *) path;

///  dic to query tring
+ (NSString*)queryStringFrom:(NSDictionary *)parameters;

/// 获取当前 GMT 时间字符串
+ (NSString *)getNowDateStr;

@end

