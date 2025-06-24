//
//  SDKAPIManager.m
//  BmobSDK
//
//  Created by Bmob on 16/7/4.
//  Copyright © 2016年 donson. All rights reserved.
//

#import "SDKAPIManager.h"
#import "BCommonUtils.h"
#import "SDKHostUtil.h"
#import "BmobManager.h"
#import "BEncryptUtil.h"

@implementation SDKAPIManager

static NSInteger kAPIVersion = 8;

static NSString *kCreateInterfaceKey              = @"create";
static NSString *kUpdateInterfaceKey              = @"update";
static NSString *kFindInterfaceKey                = @"find";
static NSString *kDeleteInterfaceKey              = @"delete";
static NSString *kSignupInterfaceKey              = @"signup";
static NSString *kLoginInterfaceKey               = @"login";
static NSString *kLoginOrSignUpInterfaceKey       = @"login_or_signup";
static NSString *kResetInterfaceKey               = @"reset";
static NSString *kEmailVerifyInterfaceKey         = @"email_verify";
static NSString *kUpdateUserPassowordInterfaceKey = @"update_user_password";
static NSString *kPushInterfaceKey                = @"push";
static NSString *kRequestSmsInterfaceKey          = @"request_sms";
static NSString *kRequestSmsCodeInterfaceKey      = @"request_sms_code";
static NSString *kVerifySmsCodeInterfaceKey       = @"verify_sms_code";
static NSString *kQuerySmsInterfaceKey            = @"query_sms";
static NSString *kPhoneResetInterfaceKey          = @"phone_reset";
static NSString *kCloudQueryInterfaceKey          = @"cloud_query";
static NSString *kTimestampInterfaceKey           = @"timestamp";
static NSString *kBatchInterfaceKey               = @"batch";
static NSString *kFunctionsInterfaceKey           = @"functions";
static NSString *kSchemasInterfaceKey             = @"schemas";
static NSString *kCdnInterfaceKey                 = @"cdn";
static NSString *kSaveCdnUploadInterfaceKey       = @"savecdnupload";
static NSString *kDeleteCdnUploadInterfaceKey     = @"delcdnupload";
static NSString *kDeleteCdnBatchInterfaceKey      = @"delcdnbatch";
static NSString *kTcpFileServerUrlInterfaceKey    = @"tcp_fileserver_url";
static NSString *kGetPrivateInfoInterfaceKey      = @"phone_ci";
static NSString *kPayInterface                    = @"pay";
static NSString *kPayQueryInterface               = @"pay_query";

+(instancetype)defaultAPIManager{
    static dispatch_once_t onceToken;
    static SDKAPIManager *manager = NULL;
    dispatch_once(&onceToken, ^{
        manager = [[SDKAPIManager alloc] init];
    });
    
    return manager;
}

+(NSString *)getIdParams {
    NSString *appKey = [BEncryptUtil decodeBase64String:[[NSString alloc] initWithData:[BmobManager defaultManager].apid encoding:NSUTF8StringEncoding]];
    NSUInteger len = [appKey length];
    if(len > 5){
        return [NSString stringWithFormat:@"?id=%@", [appKey substringFromIndex:len - 6]];
    }
    return @"";
}

#pragma mark - 初始化,secret默认 open2.bmob.cn
-(NSString *)iniInterface:(NSString *)domain {
        // FIXME 截取appKey的后6位，做为id参数
//    return [NSString stringWithFormat:@"%@/%ld/init%@",[self defaultServerDomain],(long)kAPIVersion, [SDKAPIManager getIdParams]];
    if(!domain)
        domain = [self defaultServerDomain];

    return [NSString stringWithFormat:@"%@/%ld/init", domain,(long)kAPIVersion];
}


-(NSString *)secretInterface{

        // NSString *appKey      = [BEncryptUtil decodeBase64String:[[NSString alloc] initWithData:[BmobManager defaultManager].apid encoding:NSUTF8StringEncoding]];
        // FIXME 截取appKey的后6位，做为id参数
//    return [NSString stringWithFormat:@"%@/%ld/secret%@",[self defaultServerDomain],(long)kAPIVersion, [SDKAPIManager getIdParams]];
    return [NSString stringWithFormat:@"%@/%ld/secret",[self defaultServerDomain],(long)kAPIVersion];
}


-(NSString *)defaultServerDomain{
    NSString *string;
    // 如果已经设置过了(设置的时机是在开发者resetDomain的时候set到userDefault缓存中的)
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"requestUrl"]) {
       string = [[NSUserDefaults standardUserDefaults]objectForKey:@"requestUrl"];
    } else {
       string = @"https://open.cctvcloud.cn";
        //string = @"http://opentest.bmob.cn";
    }
   

    //    NSString *string =  @"https://opentest.bmob.cn";
    
    return string;
}

#pragma mark - migration

-(NSDictionary *)migrationDictionary{
    return [[BmobManager defaultManager] migrationDictionary];
}

-(NSString *)interfaceFromMigrationWithKey:(NSString *)key{
    NSDictionary *migration = [self migrationDictionary];
    NSArray *domainArray    = migration[@"domain"];
    NSArray *apiArray       = migration[key];
    if (apiArray && apiArray.count > 0) {
        //NSString *domian        = domainArray[[apiArray[0]intValue]];
        // add in 20190831 domain不用domain数组的第二个 判断开发者是否传进来过 否则就用open3的
        NSString *domain = [self defaultServerDomain];
//        NSLog(@"interfaceFromMigrationWithKey domain is %@",domain);
        //NSString *action        = apiArray[1];
        NSString *action        = key;
        NSString *address       = [domain stringByAppendingString:action];
        return address;
    }else{
        return nil;
    }
    
    
}

#pragma mark - 接口地址

-(NSString *)interfaceWithKey:(NSString *)key{
    NSString *address = @"";
    NSString *privateAddress = [self interfaceFromMigrationWithKey:key];
//    NSLog(@"privateAddress is %@",privateAddress);
    if (![self migrationDictionary] || !privateAddress) {
        //address = [NSString stringWithFormat:@"%@/%ld/%@",[self defaultServerDomain],(long)kAPIVersion,key];

        // NSString *appKey      = [BEncryptUtil decodeBase64String:[[NSString alloc] initWithData:[BmobManager defaultManager].apid encoding:NSUTF8StringEncoding]];
        // FIXME 截取appKey的后6位，做为id参数

        address = [NSString stringWithFormat:@"%@/%ld/%@%@",[self defaultServerDomain],(long)kAPIVersion,key, [SDKAPIManager getIdParams]];
//        address = [NSString stringWithFormat:@"%@/%ld/%@",[self defaultServerDomain],(long)kAPIVersion,key];
    }else{
//        address = privateAddress;
//        NSLog(@"privateAddress is null");
        address = [NSString stringWithFormat:@"%@%@", privateAddress, [SDKAPIManager getIdParams]];
//        NSLog(@"privateAddress is %@",privateAddress);
    }
    

    
    return address;
}

#pragma mark - 增删改查

-(NSString *)createInterface{
    return [self interfaceWithKey:kCreateInterfaceKey];
}

-(NSString *)updateInterface{
    return [self interfaceWithKey:kUpdateInterfaceKey];
}


-(NSString *)findInterface{
    return [self interfaceWithKey:kFindInterfaceKey];
}

-(NSString *)deleteInterface{
    return [self interfaceWithKey:kDeleteInterfaceKey];
}


#pragma mark - 用户接口

-(NSString *)signupInterface{
    return [self interfaceWithKey:kSignupInterfaceKey];
}

-(NSString *)loginInterface{
    return [self interfaceWithKey:kLoginInterfaceKey];
}

-(NSString *)loginOrSignupInterface{
    return [self interfaceWithKey:kLoginOrSignUpInterfaceKey];
}

-(NSString *)resetInterface{
    return [self interfaceWithKey:kResetInterfaceKey];
}

-(NSString *)emailVerifyInterface{
    return [self interfaceWithKey:kEmailVerifyInterfaceKey];
}

-(NSString *)updateUserPasswordInterface{
    return [self interfaceWithKey:kUpdateUserPassowordInterfaceKey];
}

-(NSString *)getDevicePrivateInfo {
    return [self interfaceWithKey:kGetPrivateInfoInterfaceKey];
}

#pragma mark - 支付

-(NSString *)payInterface {
    return [self interfaceWithKey:kPayInterface];
}

-(NSString *)payQueryInterface {
    return [self interfaceWithKey:kPayQueryInterface];
}

#pragma mark - 推送

-(NSString *)pushInterface{
    return [self interfaceWithKey:kPushInterfaceKey];
}

#pragma mark - 短信
-(NSString *)requestSmsInterface{
    return [self interfaceWithKey:kRequestSmsInterfaceKey];
}

-(NSString *)requestSmsCodeInterface{
    return [self interfaceWithKey:kRequestSmsCodeInterfaceKey];
}

-(NSString *)verifySmsCodeInterface{
    return [self interfaceWithKey:kVerifySmsCodeInterfaceKey];
}

-(NSString *)querySmsInterface{
    return [self interfaceWithKey:kQuerySmsInterfaceKey];
}

-(NSString *)phoneResetInterface{
    return [self interfaceWithKey:kPhoneResetInterfaceKey];
}

#pragma mark - BQL

-(NSString *)cloudQueryInterface{
    return [self interfaceWithKey:kCloudQueryInterfaceKey];
}

#pragma mark - oterh

-(NSString *)timestampInterface{
    return [self interfaceWithKey:kTimestampInterfaceKey];
}

-(NSString *)batchInterface{
    return [self interfaceWithKey:kBatchInterfaceKey];
}

-(NSString *)functionsInterface{
    return [self interfaceWithKey:kFunctionsInterfaceKey];
}

#pragma mark - cdn

-(NSString *)cdnInterface{
    return [self interfaceWithKey:kCdnInterfaceKey];
}

-(NSString *)saveCdnUploadInterface{
    return [self interfaceWithKey:kSaveCdnUploadInterfaceKey];
}

-(NSString *)delCdnFileInterface{
    return [self interfaceWithKey:kDeleteCdnUploadInterfaceKey];
}

-(NSString *)delCdnBatchInterface{
    return [self interfaceWithKey:kDeleteCdnBatchInterfaceKey];
}


#pragma mark - data table

-(NSString *)schemasInterface{
    return [self interfaceWithKey:kSchemasInterfaceKey];
}

-(NSString *)tcpFileServerUrlInterfaceKeyInterface{
    return [self interfaceWithKey:kTcpFileServerUrlInterfaceKey];
}

@end
