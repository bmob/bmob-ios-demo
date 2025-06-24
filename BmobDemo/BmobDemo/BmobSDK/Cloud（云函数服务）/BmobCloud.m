//
//  BmobCloud.m
//  BmobSDK
//
//  Created by Bmob on 13-12-31.
//  Copyright (c) 2013年 Bmob. All rights reserved.
//

#import "BmobCloud.h"
#import "BCommonUtils.h"
#import "BHttpClientUtil.h"
#import "SDKAPIManager.h"
#import "BRequestDataFormat.h"
@interface BmobCloud(){
    
}
@end


@implementation BmobCloud

+(id)callFunction:(NSString *)function withParameters:(NSDictionary *)parameters{
    return [[self class] callFunction:function withParameters:parameters error:nil];
}

+(id)callFunction:(NSString *)function withParameters:(NSDictionary *)parameters error:(NSError **)error{
    __block id result = nil;
    //创建信号量

    dispatch_semaphore_t semaphore =  dispatch_semaphore_create(0);

    [[self class] callFunctionInBackground:function withParameters:parameters block:^(id object, NSError *error1) {
        if (!error1) {
            result = object;
            if (error) {
                *error = nil;
            }
            
        }else{
            if (error) {
                *error = error1;
            }
            
        }
        //发送信号量
        dispatch_semaphore_signal(semaphore);
    }];

    //设置等待时间Z
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
   
    return result;
}





+ (void)callFunctionInBackground:(NSString *)function withParameters:(NSDictionary *)parameters block:(BmobIdResultBlock)block{
    
    if (!function || [function length] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullFunctionName];
                block(nil,error);
            }

        });
        
    }
    else{
        NSMutableDictionary *reqMutableDic = [NSMutableDictionary dictionary];
        if (parameters && [parameters count] > 0) {
            [reqMutableDic setDictionary:parameters];
        }
        [reqMutableDic setObject:function forKey:@"_e"];
        NSDictionary *pDic = [BRequestDataFormat requestDictionaryWithData:reqMutableDic];
        
        debugLog(@"云端代码访问post数据：%@",pDic);
        
        NSString  *cloudUpUrl        = [[SDKAPIManager defaultAPIManager] functionsInterface];
        BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:cloudUpUrl];
        [requestUtil addParameter:pDic
                     successBlock:^(NSDictionary *dictionary, NSError *error) {
                          debugLog(@"云端代码访问返回结果：%@",dictionary);
                         if (dictionary && dictionary.count > 0) {
                             if ([[[[dictionary objectForKey:@"result"] objectForKey:@"code"] description]  isEqualToString:@"200"]) {
                                 if (block) {
                                     block([[dictionary objectForKey:@"data"] objectForKey:@"results"],nil);
                                 }
                             }else{
                                 if (block) {
                                     if ([BCommonUtils isNotNilOrNull:[dictionary objectForKey:@"result"]]) {
                                         
                                         NSError *error1 = [BCommonUtils errorWithResult:dictionary];
                                         
                                         block(nil,error1);
                                         
                                     }else{
                                         NSError *error1 = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                         block(nil,error1);
                                     }
                                 }
                             }
                         }
                     } failBlock:^(NSError *err){
                         if (block) {
                             BmobErrorType type = BmobErrorTypeConnectFailed;
                             if (err) {
                                 type = (BmobErrorType)err.code;
                             }
                             NSError * error = [BCommonUtils errorWithType:type];
                             block(nil,error);
                         }
                     }];
    }
}

@end
