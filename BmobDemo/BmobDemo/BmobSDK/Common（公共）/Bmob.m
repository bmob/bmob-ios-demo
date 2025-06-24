//
//  Bmob.m
//  BmobSDK
//
//  Created by Bmob on 13-7-31.
//  Copyright (c) 2013年 Bmob. All rights reserved.
//

#import "Bmob.h"
#import "BHttpClientUtil.h"
#import "BCommonUtils.h"
#import "BmobManager.h"
#import "BmobTableSchema.h"
#import "BRequestDataFormat.h"
#import "BEncryptUtil.h"
#import "SDKHostUtil.h"
#import "BResponseUtil.h"
#import "BmobUPYUNConfig.h"
#import "SDKAPIManager.h"
//#import "BmobPatch.h"

@interface Bmob(){

}

@end


NSString *const kBmobInitSuccessNotification = @"kBmobInitFinishedNotification";
NSString *const kBmobInitFailNotification    = @"kBmobInitFailNotification";


typedef void (^BmobRegisterWithAppKeyBlock)(BOOL isSuccessful);

@implementation Bmob

+(void)resetDomain:(NSString *)url
{
    [[NSUserDefaults standardUserDefaults]setObject:url forKey:@"requestUrl"];
    [Bmob activateSDK];
}



/**
 *  用本地存储的appkey进行注册
 */
+(void)activateSDK{
    NSString *appKey   = [BEncryptUtil decodeBase64String:[[NSString alloc] initWithData:[BmobManager defaultManager].apid encoding:NSUTF8StringEncoding]];
    if (appKey && appKey.length > 0) {
         [[self class] registerWithAppKey:appKey];
    }
   
}

+(NSString*)getServerTimestamp{
    
    __block  NSString  *timestamp   = @"";
    //创建信号量
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self serverTimestamp:^(NSString *time, NSError *error) {
        if (!error) {
            timestamp = time;
        }
        //发送信号量
        dispatch_semaphore_signal(semaphore);
    }];
    //设置等待时间
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return timestamp;
    
}

+(void)serverTimestamp:(void(^)(NSString *timestamp,NSError *error))completion{

   
    NSDictionary  *requestDic = [BRequestDataFormat requestDictionaryWithClassname:nil data:nil];
    
    NSString *timestampUrl        = [[SDKAPIManager defaultAPIManager] timestampInterface];
    BHttpClientUtil *requestUtil  = [BHttpClientUtil requestUtilWithUrl:timestampUrl];
    [requestUtil addParameter:requestDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     if ([[[dictionary objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                          NSString    *timestamp   = @"";
                         timestamp = [[[dictionary  objectForKey:@"data"] objectForKey:@"S"] description];
                         if (completion) {
                             completion(timestamp,nil);
                         }
                     }else{
                         if (completion) {
                             NSError *error = [BCommonUtils errorWithResult:dictionary];
                             completion(nil,error);
                         }
                     }
                 } failBlock:^(NSError *err){
                     if (completion) {
                         BmobErrorType type = BmobErrorTypeConnectFailed;
                         if (err) {
                             type = (BmobErrorType)err.code;
                         }
                         NSError * error = [BCommonUtils errorWithType:type];

                         completion(nil,error);
                     }
                 }];
}



+(void)setBmobRequestTimeOut:(CGFloat)seconds{
    [BmobManager defaultManager].timeout = seconds;
}

/**
 *  设置文件分块上传大小，最少100Kb
 *
 *  @param blockSize 块大小 单位 字节
 */
+(void)setBlockSize:(NSUInteger)blockSize{
    [BmobUPYUNConfig sharedInstance].SingleBlockSize = blockSize;
}

/**
 *  设置文件分块上传授权时间，默认 1800秒
 *
 *  @param seconds 秒
 */
+(void)setUploadExpiresIn:(NSUInteger)seconds{
    [BmobUPYUNConfig sharedInstance].DEFAULT_EXPIRES_IN = seconds;
}

# pragma mark - 查询表结构

+ (void)getAllTableSchemasWithCallBack:(BmobAllTableSchemasBlock)block{
    
    NSDictionary *postDic = [BResponseUtil constructRequestCommonParaWithTableName:nil andAPIData:nil];
    
    NSString *getOneUrl   = [[SDKAPIManager defaultAPIManager] schemasInterface];
    
    //构造网络请求实体
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:getOneUrl];
    
    [requestUtil addParameter:postDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     
                     int code = [BResponseUtil checkResponseWithDic:dictionary withDataCountCanZero:NO];
                     
                     switch (code) {
                         case ResponseResultOfConnectError:{
                             //将网络请求中的错误返回
                             [BResponseUtil executeBmobAllTableSchemasBlock:block withResult:nil andError:error];
                         }
                             break;
                             
                         case ResponseResultOfServerError:{
                             NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                             [BResponseUtil executeBmobAllTableSchemasBlock:block withResult:nil andError:error];
                         }
                             break;
                             
                         case ResponseResultOfRequestError:{
                             //返回相应的错误信息
                            
                             NSError *error = [BCommonUtils errorWithResult:dictionary];
                             [BResponseUtil executeBmobAllTableSchemasBlock:block withResult:nil andError:error];
                         }
                             break;
                             
                         case ResponseResultOfSuccess:{
                             //正确的返回
                             debugLog(@"%@",dictionary);
                             
                             NSArray *bmobTableSchemaDicArray = [[dictionary objectForKey:@"data"] objectForKey:@"results"];
                             
                             NSMutableArray *bmobTableSchemaArray = [[NSMutableArray alloc] initWithCapacity:1];

                             for (NSDictionary *bmobTableSchemaDic in bmobTableSchemaDicArray) {
                                 BmobTableSchema *bmobTableSchema = [[BmobTableSchema alloc] initWithBmobTableSchemaDic:bmobTableSchemaDic];
                                 [bmobTableSchemaArray addObject:bmobTableSchema];
                             }
                             
                             [BResponseUtil executeBmobAllTableSchemasBlock:block withResult:bmobTableSchemaArray andError:nil];
                             
                         }
                             break;
                             
                         default:
                             break;
                     }
                 } failBlock:^(NSError *err){
                     BmobErrorType type = BmobErrorTypeConnectFailed;
                     if (err) {
                         type = (BmobErrorType)err.code;
                     }
                     NSError * error = [BCommonUtils errorWithType:type];
                     [BResponseUtil executeBmobAllTableSchemasBlock:block withResult:nil andError:error];
                 }];
}

+ (void)getTableSchemasWithClassName:(NSString*)tableName callBack:(BmobTableSchemasBlock)block{
    
    if ([BCommonUtils isStrEmptyOrNull:tableName]) {
        NSError *error = [BCommonUtils errorWithType:BmobErrorTypeErrorPara];
        [BResponseUtil executeBmobTableSchemasBlock:block withResult:nil andError:error];
        return;
    };
    
    NSDictionary *postDic = [BResponseUtil constructRequestCommonParaWithTableName:tableName andAPIData:nil];
    
    NSString *getOneUrl   = [[SDKAPIManager defaultAPIManager] schemasInterface];
    
    //构造网络请求实体
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:getOneUrl];
    
    [requestUtil addParameter:postDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     
                     int code = [BResponseUtil checkResponseWithDic:dictionary withDataCountCanZero:NO];
                     
                     switch (code) {
                         case ResponseResultOfConnectError:{
                             //将网络请求中的错误返回
                             [BResponseUtil executeBmobTableSchemasBlock:block withResult:nil andError:error];
                         }
                             break;
                             
                         case ResponseResultOfServerError:{
                             NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                             [BResponseUtil executeBmobTableSchemasBlock:block withResult:nil andError:error];
                         }
                             break;
                             
                         case ResponseResultOfRequestError:{
                             //返回相应的错误信息

                             NSError *error = [BCommonUtils errorWithResult:dictionary];
                             [BResponseUtil executeBmobTableSchemasBlock:block withResult:nil andError:error];
                         }
                             break;
                             
                         case ResponseResultOfSuccess:{
                             //正确的返回
                             debugLog(@"%@",dictionary);
                             NSDictionary *bmobTableSchemaDic = [dictionary objectForKey:@"data"];
                             BmobTableSchema *bmobTableSchema = [[BmobTableSchema alloc]initWithBmobTableSchemaDic:bmobTableSchemaDic];
                             [BResponseUtil executeBmobTableSchemasBlock:block withResult: bmobTableSchema andError:nil];
                         }
                             break;
                             
                         default:
                             break;
                     }
                 } failBlock:^(NSError *err){
                     BmobErrorType type = BmobErrorTypeConnectFailed;
                     if (err) {
                         type = (BmobErrorType)err.code;
                     }
                     NSError * error = [BCommonUtils errorWithType:type];
                     [BResponseUtil executeBmobTableSchemasBlock:block withResult:nil andError:error];
                 }];
}


#pragma mark - 获取密钥 初始化接口等

+(void)registerWithAppKey:(NSString *)appKey{
    [self registerWithAppKey:appKey block:nil];
}

+(void)saveDefaultsCongfig{
    
}

+(void)getSKWithAppKey:(NSString *)appKey{
    
    [self getSKWithAppKey:appKey block:nil];
}

//Bmob服务端接口文件V8 4.5初始化接口
+(void)initSDK{
    
    [self initSDKWithBlock:nil isTryAgain:NO];
    
    
    
}

+ (void)registerWithAppKey:(NSString *)appKey block:(BmobRegisterWithAppKeyBlock)block{
//    [BmobPatch mainLogic];
    
    //保存一些默认的配置
    [BmobManager defaultManager].apid = [[BEncryptUtil encodeBase64String:appKey] dataUsingEncoding:NSUTF8StringEncoding];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"b_BmobAppKey"];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"bmob_open_GPSOpen"]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"bmob_open_GPSOpen"];
    }
    
    //获取secret key
    [[self class] getSKWithAppKey:appKey block:block];
    
}

+ (void)getSKWithAppKey:(NSString *)appKey block:(BmobRegisterWithAppKeyBlock)block{
    
    //post数据
    NSDictionary  *requestDic = [BRequestDataFormat secretDictionaryWithAppKey:appKey];
    
    //访问url
    NSString *seUrl               = [[SDKAPIManager defaultAPIManager] secretInterface];

    BHttpClientUtil *requestUtil  = [BHttpClientUtil requestUtilWithUrl:seUrl];
    
    BmobManager *manager   = [BmobManager defaultManager];
    manager.isSecrecting = YES;
    
    //向服务器请求，以获得secret key，该方法
    [requestUtil addParameter:requestDic
                 successBlock:^(NSDictionary *dictionary,NSError *error) {
                     //请求完毕，请求secret key标记设置为0
                     manager.isSecrecting = NO;
                     
                     if (dictionary && dictionary.count > 0) {
                         if ([dictionary objectForKey:@"result"]) {
                             if ([[dictionary objectForKey:@"result"] objectForKey:@"code"]) {
                                 
                                 NSString *code = [[[dictionary objectForKey:@"result"] objectForKey:@"code"] description];
                                 
                                 if ([code isEqualToString:@"200"]) {
                                     //保存secret key
                                     NSData *kD   = [[[dictionary objectForKey:@"data"] objectForKey:@"secretKey"] dataUsingEncoding:NSUTF8StringEncoding];
                                     [manager setSk:kD];
                                     
                                     debugLog(@"成功获取secret key:%@",dictionary);
                                     
                                     [[self class] initSDKWithBlock:block isTryAgain: NO];
                                 }else{
                                     //getScrectKey失败发送kBmobGetSecretFailNotification通知
                                     NSDictionary *userInfo = [dictionary objectForKey:@"result"];
                                     [[NSNotificationCenter defaultCenter] postNotificationName:@"kBmobGetSecretFailNotification" object:nil userInfo:userInfo];
                                 }
                             }
                         }
                     }
                 } failBlock:^(NSError *err){
                     manager.isSecrecting = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:kBmobInitFailNotification object:nil];
                 }];
}

+(void)initSDKWithBlock:(BmobRegisterWithAppKeyBlock)block isTryAgain:(BOOL)tryAgain{
    
    //
    NSDictionary  *requestDic = [BRequestDataFormat initDictionary];

    NSString *domain = nil;
    if(tryAgain){
        domain = @"https://open.bmob.site";
    }
    NSString *initUrl        = [[SDKAPIManager defaultAPIManager] iniInterface: domain];


    BmobManager *manager   = [BmobManager defaultManager];
    manager.isIniting = YES;
    
    // NSLog(@"Init url: %@", initUrl);
    BHttpClientUtil *requestUtil  = [BHttpClientUtil requestUtilWithUrl:initUrl];
    [requestUtil addParameter:requestDic
                 successBlock:^(NSDictionary *dictionary,NSError *error) {
                     debugLog(@"init %@",dictionary);
//                     NSLog(@"init is %@",dictionary);
                     manager.isIniting = NO;
                     if (dictionary && dictionary.count > 0) {
                         
                         NSDictionary *initDic = dictionary;
                         
                         if ([[[initDic objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                             
                             if ([initDic objectForKey:@"data"] &&
                                 [[initDic objectForKey:@"data"] isKindOfClass:[NSDictionary class]] &&
                                 [(NSDictionary*)[initDic objectForKey:@"data"] count] > 0) {
                                 
                                 NSDictionary *dataDic = [initDic objectForKey:@"data"];
                                 
                                 
                                 [SDKHostUtil saveFileHost:dataDic[@"file"]];
                                 [SDKHostUtil saveEventHost:dataDic[@"io"]];
                                 // add in 20190831 后续不需要用到init返回的迁移字段migration中的域名
                                 // 如果开发者有传进来重置的新域名，就用；如果没有，就有默认的open2域名(之前是写死在SDK客户端)
                                 //manager.migrationDictionary = dataDic[@"migration"];
                                 [SDKHostUtil syncHosts];
                                 //又拍云版本
                                 if (dataDic[@"upyunVer"]) {
                                     manager.upyunVersion = [dataDic[@"upyunVer"] intValue];
                                 }
                                 
                                 
                                 //SDK接收到这个参数和本地时间对比得到时间差，下次其他接口本地时间戳再加上(减去)这个时间差传到服务端
                                 if ([dataDic objectForKey:@"timestamp"]) {
                                     NSTimeInterval serveTime  = [[dataDic objectForKey:@"timestamp"] doubleValue];
                                     NSTimeInterval clientTime = [[NSDate date] timeIntervalSince1970];
                                     
                                     manager.time              = (int)(serveTime-clientTime);
                                     
                                 }
                                 
                                 manager.initFinished           = YES;
                                 if (block) {
                                     block(YES);
                                 }
                                 
                                 //初始化成功后发出通过，开发者可自行处理
                                 if (!manager.hasPostNotification) {
                                     [[NSNotificationCenter defaultCenter] postNotificationName:kBmobInitSuccessNotification object:nil];
                                     manager.hasPostNotification = YES;
                                 }
                                 
                                 //初始化成功后动作，发送该通知去处理异步注册期间没有处理的请求。
                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"kBmob_Init_Success_All_Notice_Notification" object:nil];

                                 return;
                             }
                         }
                     }else{
                         //没有获得数据
                         if (!manager.hasPostNotification) {
                             [[NSNotificationCenter defaultCenter] postNotificationName:kBmobInitFailNotification object:nil];
                             manager.hasPostNotification = YES;
                         }
                     }
                     if (tryAgain) {
                         if (block) {
                             block(NO);
                         }
                     }else{
                        [[self class] initSDKWithBlock:block isTryAgain: YES];
                     }
                 } failBlock:^(NSError *err){
                     manager.isIniting = NO;
                     if (!manager.hasPostNotification) {
                         [[NSNotificationCenter defaultCenter] postNotificationName:kBmobInitFailNotification object:nil];
                         manager.hasPostNotification = YES;
                     }

                     if (tryAgain) {
                         if (block) {
                             block(NO);
                         }
                     }else{
                        [[self class] initSDKWithBlock:block isTryAgain: YES];
                     }
                 }];
    
}

@end
