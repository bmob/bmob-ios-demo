//
//  b_BmobUtils.h
//  BmobSDK
//
//  Created by Bmob on 13-8-1.
//  Copyright (c) 2013年 Bmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BmobReachability.h"
#import "BHttpClientUtil.h"
#import "BmobErrorList.h"


@interface BCommonUtils : NSObject




+(NSString*) uuid;
+(NSString*)filePath;

/**
 *  cache 文件夹地址
 *
 *  @return cache 文件夹地址
 */
+(NSString *)cachePath;



/**
 *  文件域名地址
 *
 *  @return 文件域名地址
 */
+(NSString *)fileHost;

/**
 *  实时监控 地址
 *
 *  @return 实时监控 地址
 */
+(NSArray *)ioAddressAndPort;

/**
 *  登录的sessionToken
 *
 *  @return 登录的sessionToken
 */
+(NSString *)sessionToken;


+(NSString*)stringOfJson:(id)obj;
+(NSDate *)dateOfString:(NSString*)dataString;
+(NSString*)stringOfDate:(NSDate *)date;
+(NSDictionary*)exRequestDictionary;
+(NSDictionary*)clientDic;

/**
 *  根据错误类型构造error
 *
 *  @param tag 错误的类型
 *
 *  @return NSError对象
 */
+(NSError*)errorWithType:(BmobErrorType)tag;

/**
 *  根据请求返回的结果信息构造NSError对象
 *
 *  @param dic 信息
 *
 *  @return NSError对象
 */
+(NSError*)errorWithResult:(NSDictionary *)dic;

/**
 *  把data转成16进制字符串
 *
 *  @param data 要转化的内容
 *
 *  @return 转化成功的内容
 */
+ (NSString *)hexStringFromData:(NSData *)data;

+ (BOOL)isNotNilOrNull:(id)obj;




/**
 *  检查字符串是否为空，以下两种情况视为空：
 *  1.字符串所有字符为空格
 *  2.值为nil
 *
 *  @param str 检查的字符串
 *
 *  @return 符合检查条件返回YES，否则返回NO
 */
+(BOOL) isStrEmptyOrNull:(NSString *) str;

/**
 *  检查手机号码格式是否正确，检查项如下：
 *  1.是否为空
 *
 *  @param phoneNumber <#phoneNumber description#>
 *
 *  @return <#return value description#>
 */
+(BOOL) isMobilePhoneNumberLegal:(NSString*)phoneNumber;

/**
 *  检查SMS code是否为空，检查项如下：
 *  1.是否为空
 *
 *  @param code <#code description#>
 *
 *  @return <#return value description#>
 */
+(BOOL) isSMSCodeLegal:(NSString*)code;


+(BOOL) isNumber:(NSString *)number;

/**
 *  获取包含其父类在内的所有的属性
 *
 *  @param c            要获取属性的类
 *  @param isBmobObject 是否只取到BmobObject(不含BmobObject)，false则取到foundation类库中的某个类
 *
 *  @return 返回属性数组
 */
+(NSMutableArray *)allPropertiesWithClass:(Class)c isBmobObject:(BOOL)isBmobObject;

+(NSString *)urlEncodeWithInput:(NSString *)input;
@end
