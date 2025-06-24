//
//  b_BmobUtils.m
//  BmobSDK
//
//  Created by Bmob on 13-8-1.
//  Copyright (c) 2013年 Bmob. All rights reserved.
//

#import "BCommonUtils.h"
#import <Foundation/Foundation.h>
#import "BmobOpenUDID.h"
#import "SDKHostUtil.h"
#import <CoreData/CoreData.h>
#import <objc/runtime.h>
#import "BRequestDataFormat.h"
#import "BEncryptUtil.h"

#import "BmobObject.h"

@implementation BCommonUtils




+(NSString*) uuid {

    //[NSUUID UUID].UUIDString

//    CFUUIDRef puuid = CFUUIDCreate( nil );
//    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
//    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
//    CFRelease(puuid);
//    CFRelease(uuidString);
    
    NSString * result = [NSUUID UUID].UUIDString;
    result = [result stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return result ;
}

+(NSString*)filePath{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirecotry=[paths firstObject];
    return documentDirecotry;
}

/**
 *  cache 文件夹地址
 *
 *  @return cache 文件夹地址
 */
+(NSString *)cachePath{
    NSArray *tmpArray =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return[tmpArray firstObject];
}



+(NSString*)stringOfJson:(id)obj{
    
    if ([NSJSONSerialization isValidJSONObject:obj]) {
        //
        NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:nil];
        NSString* jsonString =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString ;
    }
    
    return nil;
}


//字符串转NSDate类型
+(NSDate*)dateOfString:(NSString *)dataString{
    if (!dataString) {
        return nil;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierISO8601];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    NSDate    *dD = [formatter dateFromString:dataString];
    
    return dD;
}

//NSDate类型转字符串
+(NSString*)stringOfDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierISO8601];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    NSString    *dD = [formatter stringFromDate:date];
    
    return dD;
}

+ (NSString *)hexStringFromData:(NSData *)data{
    NSData *myD = data;//[string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++){
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

/**
 *  判断
 *
 *  @param obj <#obj description#>
 *
 *  @return <#return value description#>
 */
+ (BOOL)isNotNilOrNull:(id)obj{
    if (!obj || [obj isKindOfClass:[NSNull class]]) {
        return NO;
    }
    
    return YES;
}



//#warning 注意切换至外网

//#define IntraNet YES
#define IntraNet NO

#pragma mark address
+(NSString *)fileHost{
    NSString *hostString = [SDKHostUtil fileHost];
    return hostString;
}

+(NSArray *)ioAddressAndPort{
    return [SDKHostUtil ioAddressAndPort];
}

+(NSString *)sessionToken{
    NSString *token = nil;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kBmobSessionToken]) {
        NSString *sessionToken = [[NSUserDefaults standardUserDefaults] objectForKey:kBmobSessionToken];
        token                  = sessionToken;
    }else if ([[NSUserDefaults standardUserDefaults] objectForKey:kBmobSessionTokenPre]) {
        NSString *sessionToken = [[NSUserDefaults standardUserDefaults] objectForKey:kBmobSessionTokenPre];
        token                  = sessionToken;
    }
    
    
    return token;
}

#pragma mark request util method
+(NSDictionary*)exRequestDictionary{
    NSMutableDictionary *exDic = [NSMutableDictionary dictionaryWithCapacity:1];

    exDic[@"latitude"] = @0;
    exDic[@"longitude"] = @0;
    
    if ([BmobOpenUDID value]) {
        exDic[@"uuid"] = [BmobOpenUDID value];

    }
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    if (infoDic) {
        NSString *pageName = infoDic [@"CFBundleIdentifier"];
        exDic[@"package"] = pageName;
    }
    return exDic;
}

+(NSDictionary*)clientDic{
    NSString *version = [UIDevice currentDevice].systemVersion;
    NSDictionary *dic = @{@"caller": @"iOS",@"ex":[[self class] exRequestDictionary],@"version":version};
    return dic;
}

+(NSError*)errorWithType:(BmobErrorType)tag{
    NSError *error = nil;
    NSInteger code = (NSInteger)tag;
    NSString *errorString = @"";
    switch (tag) {
        case BmobErrorTypeUnauthorized:{
            errorString = @"unauthorized";
        }
            break;
        case BmobErrorTypeForbidden:{
            errorString = @"forbidden ";
        }
            break;
        case BmobErrorTypePageNotFound:{
            errorString = @"page not found";
        }
            break;
        case BmobErrorTypeNullPassword:{
           errorString = @"empty password!" ;
        }
            break;
            
        case BmobErrorTypeNullUsername:{
            errorString = @"empty username!" ;
        }
            break;
            
        case BmobErrorTypeConnectFailed:{
            errorString = @"connect failed!" ;
        }
            break;
            
        case BmobErrorTypeNullObjectId:{
            errorString = @"empty objectId";
        }
            break;
            
        case BmobErrorTypeNullObject:{
            errorString = @"none object";
        }
            break;
        case BmobErrorTypeQueryCachedExpired:{
            errorString = @"expired";
        }
            break;
            
        case BmobErrorTypeCloudFunctionFailed:{
            errorString = @"cloud function failed";
        }
            break;
            
        case BmobErrorTypeNullFilename:{
            errorString = @"empty filename or have not suffix";
        }
            break;
            
        case BmobErrorTypeNullFileUrl:{
            errorString = @"none file";
            
        }
            break;
        case BmobErrorTypeUnknownError:{
            errorString = @"unknow error";
        }
            break;
            
        case BmobErrorTypeNullFileData:{
            errorString = @"none filendata";
        }
            break;
            
        case BmobErrorTypeNullUpdateContent:{
            errorString = @"empty update content";
        }
            break;
            
        case BmobErrorTypeNullFunctionName:{
            errorString = @"empty  function name";
        }
            break;
            
        case BmobErrorTypeArraySizeLarge:{
            errorString = @"array is too big";
        }
            break;
            
        case BmobErrorTypeNullArray:{
            errorString = @"empty  array";
        }
            break;
            
        case BmobErrorTypeNullPushContent:{
            errorString = @"empty push content";
        }
            break;
            
        case BmobErrorTypeFileSizeLimited:{
            errorString = @"fle size beyond the limit";
        }
            break;
            
        case BmobErrorTypeLackOfInfomation:{
            errorString = @"lack of required infomation";
        }
            break;
            
        case BmobErrorTypeErrorType:{
            errorString = @"error type";
        }
            break;
            
        case BmobErrorTypeInitNotFinish:{
            errorString =@"init is not finish,please wait a moment";
        }
            break;
            
        case BmobErrorTypeInitFailed:{
            errorString = @"init failed";
        }
            break;
            
        case BmobErrorTypeErrorFormat:{
            errorString = @"format error";
        }
            break;
            
        case BmobErrorTypeNullClassName:{
            errorString = @"empty class name";
        }
            break;
            
        case BmobErrorTypeErrorPara:{
            errorString = @"empty string  or equal \"\"";
        }
            break;
            
        case BmobErrorTypeInvalidMobilePhoneNumber:{
            errorString = @"Invalid mobile phone number, the format can't be empty or null";
        }
            break;
            
        case BmobErrorTypeInvalidSMSCode:{
            errorString = @"Invalid sms code, the format can't be empty or null";
        }
            break;
            
        case BmobErrorTypeFileNotExist:{
            errorString = @"file not exist";
        }
            break;
        case BmobErrorTypeNullEmail:{
            errorString = @"empty email";
        }
            break;
        default:{
            errorString = @"connect failed";
        }
            break;
    }
    
    error = [NSError errorWithDomain:kErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:errorString}];
    
    
    return error;
}

+(NSError*)errorWithResult:(NSDictionary *)dic{
    NSInteger code         = [dic[@"result"] [@"code"] intValue];
    NSString *message      = dic[@"result"] [@"message"] ;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
    NSError *error         = [NSError errorWithDomain:kErrorDomain code:code userInfo:userInfo];
    return error;
}







+(BOOL) isStrEmptyOrNull:(NSString *) str {
    debugLog(@"%@",str);
    if (!str) {
        // null object
        debugLog(@"null...");
        return YES;
    } else {
        
        NSString *trimedString = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([trimedString length] == 0) {
            debugLog(@"\"\"...");
            // empty string
            return YES;
        } else {
              debugLog(@"here3...");
            // is neither empty nor null
            return NO;
        }
    }
}

+(BOOL) isMobilePhoneNumberLegal:(NSString*)phoneNumber{
    return [[self class] isStrEmptyOrNull:phoneNumber];
}

+(BOOL) isSMSCodeLegal:(NSString*)code{
    return [[self class] isStrEmptyOrNull:code];
}


+(BOOL)isNumber:(NSString *)number{
    
    NSString *regex = @"^[0-9]*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predicate evaluateWithObject:number];
    return isValid;
}

+(NSString *)urlEncodeWithInput:(NSString *)input{
    NSString *string = [input stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@"!*'\"();@&+$,%#[]%"] invertedSet]];
    return string;
}

# pragma mark - 获取子类属性方法
/**
 *  获取类的属性
 *
 *  @return 类的属性名称数组数组
 */
+ (NSArray *)classPropsFor:(Class)c
{
    if (c == NULL) {
        return nil;
    }
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    unsigned int outCount = 0;
    //获得一个类的所有属性的一个数组
    objc_property_t *properties = class_copyPropertyList(c, &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const  char *propName = property_getName(property);
        if(propName) {
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            [results addObject:propertyName];
        }
    }
    free(properties);
    return results;
}

/**
 *  获取包含其父类在内的所有的属性
 *
 *  @param c            要获取属性的类
 *  @param isBmobObject 是否只取到BmobObject(不含BmobObject)，false则取到foundation类库中的某个类
 *
 *  @return 返回属性数组
 */
+(NSMutableArray *)allPropertiesWithClass:(Class)c isBmobObject:(BOOL)isBmobObject{
    NSMutableArray *properties = [NSMutableArray array];
    [[self class] getPropertiesWithClass:c mutableArray:properties isBmobObject:isBmobObject];
    return properties;
}

/**
 *  获取一个类包括其子类所有的属性名称
 *
 *  @param class        类名
 *  @param array        属性名称存放的数组
 *  @param isBmobObject 是否只取到BmobObject（不含BmobObject）
 */
+(void)getPropertiesWithClass:(Class)class mutableArray:(NSMutableArray *)array isBmobObject:(BOOL)isBmobObject{
    
    if (isBmobObject) {
        if ([[self class] isClassFromBmobObject:class]) {
            return;
        }
    } else if ([[self class] isClassFromFoundation:class]) {
        return ;
    }
    
    NSMutableArray *pArray =[NSMutableArray arrayWithArray:[[self class] classPropsFor: class]] ;
    Class sclass1 = class_getSuperclass( class);
    [array addObjectsFromArray:pArray];
    
    [self getPropertiesWithClass:sclass1 mutableArray:array isBmobObject:isBmobObject];
}

/**
 *  判断某个类是否继承于BmobObject
 *
 *  @param c <#c description#>
 *
 *  @return <#return value description#>
 */
+ (BOOL)isClassFromBmobObject:(Class)c{
    NSSet *foundationClasses = [NSSet setWithObjects:
                                [BmobObject class],
                                nil];
    return [foundationClasses containsObject:c];
}

/**
 *  判断某个类是否继承于Foundation框架中的某个类
 *
 *  @param c <#c description#>
 *
 *  @return <#return value description#>
 */
+ (BOOL)isClassFromFoundation:(Class)c
{
    NSSet *foundationClasses = [NSSet setWithObjects:
                                [NSObject class],
                                [NSURL class],
                                [NSDate class],
                                [NSNumber class],
                                [NSDecimalNumber class],
                                [NSData class],
                                [NSMutableData class],
                                [NSArray class],
                                [NSMutableArray class],
                                [NSDictionary class],
                                [NSMutableDictionary class],
                               // [NSManagedObject class],
                                [NSString class],
                                [NSMutableString class], nil];
    return [foundationClasses containsObject:c];
}



@end
