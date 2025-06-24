//
//  BmobSMS.m
//  BmobSDK
//
//  Created by limao on 15/6/15.
//  Copyright (c) 2015年 donson. All rights reserved.
//

#import "BmobSMS.h"
#import "BCommonUtils.h"
#import "BmobConfig.h"
#import "BHttpClientUtil.h"
#import "BResponseUtil.h"
#import "SDKAPIManager.h"
//#import "BmobPrivateInfoUploader.h"

@implementation BmobSMS

+ (void)requestSMSInbackgroundWithPhoneNumber:(NSString*)number
                                      Content:(NSString*)content
                                  andSendTime:(NSString*)sendTime
                                  resultBlock:(BmobIntegerResultBlock)block{
//    [BmobPrivateInfoUploader privateInfoUploadWithCellPhone:number];

    //异常处理
    if (!number || [number isEqualToString:@""] || !content || [content isEqualToString:@""]) {
        NSError *error = [BCommonUtils errorWithType:BmobErrorTypeErrorPara];
        [BResponseUtil executeIntegerResultBlock:block withMsgId:-1 andError:error];
        return;
    }
    
    //构造请求post字典
   
    // 判断日期
    NSDictionary *dataDic;
    if (!sendTime) {
        dataDic = @{@"mobilePhoneNumber":number, @"content":content};
    } else {
        dataDic = @{@"mobilePhoneNumber":number, @"content":content, @"sendTime":sendTime};
    }
 
    NSDictionary *postDic = [BResponseUtil constructRequestCommonParaWithTableName:nil andAPIData:dataDic];
    NSString *getOneUrl   = [[SDKAPIManager defaultAPIManager] requestSmsInterface];
    
    //构造网络请求实体
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:getOneUrl];
    
    [requestUtil addParameter:postDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     
                     int code = [BResponseUtil checkResponseWithDic:dictionary withDataCountCanZero:NO];
                     
                     switch (code) {
                         case ResponseResultOfConnectError:{
                             //将网络请求中的错误返回
                             [BResponseUtil executeIntegerResultBlock:block withMsgId:-1 andError:error];
                         }
                             break;
                             
                         case ResponseResultOfServerError:{
                             NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                             [BResponseUtil executeIntegerResultBlock:block withMsgId:-1 andError:error];
                         }
                             break;
                             
                         case ResponseResultOfRequestError:{
                             //返回相应的错误信息1560300192
                             NSError *error = [BCommonUtils errorWithResult:dictionary];
                             [BResponseUtil executeIntegerResultBlock:block withMsgId:-1 andError:error];
                         }
                             break;
                             
                         case ResponseResultOfSuccess:{
                             //正确的返回
                             NSDictionary *resultDataDic = [dictionary objectForKey:@"data"];
                             int msgId = [[resultDataDic objectForKey:@"smsId"] intValue];
                             debugLog(@"%@",dictionary);
                             [BResponseUtil executeIntegerResultBlock:block withMsgId:msgId andError:nil];
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

                     [BResponseUtil executeIntegerResultBlock:block withMsgId:-1 andError:error];

                 }];

}

+ (void)requestSMSCodeInBackgroundWithPhoneNumber:(NSString*)phoneNumber
                                      andTemplate:(NSString*)templateStr
                                      resultBlock:(BmobIntegerResultBlock)block{
//    [BmobPrivateInfoUploader privateInfoUploadWithCellPhone:phoneNumber];
    //异常处理
    if (!phoneNumber || [phoneNumber isEqualToString:@""]) {
        NSError *error = [BCommonUtils errorWithType:BmobErrorTypeErrorPara];
        [BResponseUtil executeIntegerResultBlock:block withMsgId:-1 andError:error];
        return;
    }
    
    if (!templateStr){
        templateStr = @"";
    }
    
    //构造请求post字典
    NSDictionary *dataDic = @{@"mobilePhoneNumber":phoneNumber,@"template":templateStr};
    NSDictionary *postDic = [BResponseUtil constructRequestCommonParaWithTableName:nil
                                                                    andAPIData:dataDic];
    NSString *getOneUrl   = [[SDKAPIManager defaultAPIManager] requestSmsCodeInterface];
    
    //构造网络请求实体
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:getOneUrl];
    
    [requestUtil addParameter:postDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     
                     int code = [BResponseUtil checkResponseWithDic:dictionary withDataCountCanZero:NO];
                     
                     switch (code) {
                         case ResponseResultOfConnectError:{
                             //将网络请求中的错误返回
                             [BResponseUtil executeIntegerResultBlock:block withMsgId:-1 andError:error];
                         }
                             break;
                             
                         case ResponseResultOfServerError:{
                             NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                             [BResponseUtil executeIntegerResultBlock:block withMsgId:-1 andError:error];
                         }
                             break;
                             
                         case ResponseResultOfRequestError:{
                             //返回相应的错误信息
                             NSError *error = [BCommonUtils errorWithResult:dictionary];
                             [BResponseUtil executeIntegerResultBlock:block withMsgId:-1 andError:error];
                         }
                             break;
                             
                         case ResponseResultOfSuccess:{
                             //正确的返回
                             NSDictionary *resultDataDic = [dictionary objectForKey:@"data"];
                             int msgId = [[resultDataDic objectForKey:@"smsId"] intValue];
                             debugLog(@"%@",dictionary);
                             [BResponseUtil executeIntegerResultBlock:block withMsgId:msgId andError:nil];
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

                    [BResponseUtil executeIntegerResultBlock:block withMsgId:-1 andError:error];


                 }];
}

+ (void)verifySMSCodeInBackgroundWithPhoneNumber:(NSString*)phoneNumber andSMSCode:(NSString*)code resultBlock:(BmobBooleanResultBlock)block{
    //异常处理
    if (!phoneNumber || [phoneNumber isEqualToString:@""] || !code || [code isEqualToString:@""]) {
        NSError *error = [BCommonUtils errorWithType:BmobErrorTypeErrorPara];
        [BResponseUtil executeBooleanResultBlock:block withResult:NO andError:error];
        return;
    }

    //构造请求post字典
    NSDictionary *dataDic = @{@"mobilePhoneNumber":phoneNumber,@"smsCode":code};
    NSDictionary *postDic = [BResponseUtil constructRequestCommonParaWithTableName:nil andAPIData:dataDic];
    debugLog(@"message request: %@",postDic);
    NSString *getOneUrl            = [[SDKAPIManager defaultAPIManager] verifySmsCodeInterface];
    
    //构造网络请求实体
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:getOneUrl];
    
    [requestUtil addParameter:postDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     
                     int code = [BResponseUtil checkResponseWithDic:dictionary withDataCountCanZero:NO];
                     
                     switch (code) {
                         case ResponseResultOfConnectError:{
                             //将网络请求中的错误返回
                             [BResponseUtil executeBooleanResultBlock:block withResult:NO andError:error];
                         }
                             break;
                             
                         case ResponseResultOfServerError:{
                             NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                             [BResponseUtil executeBooleanResultBlock:block withResult:NO andError:error];
                         }
                             break;
                             
                         case ResponseResultOfRequestError:{
                             //返回相应的错误信息
                             NSError *error = [BCommonUtils errorWithResult:dictionary];
                             [BResponseUtil executeBooleanResultBlock:block withResult:NO andError:error];
                         }
                             break;
                             
                         case ResponseResultOfSuccess:{
                             //正确的返回
                             debugLog(@"%@",dictionary);
                             [BResponseUtil executeBooleanResultBlock:block withResult:YES andError:nil];
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

                     [BResponseUtil executeBooleanResultBlock:block withResult:NO andError:error];


                 }];
}

+ (void)querySMSCodeStateInBackgroundWithSMSId:(int)smsId resultBlock:(BmobQuerySMSCodeStateResultBlock)block{
    
    //构造请求post字典
    NSDictionary *dataDic = @{@"smsId": [NSNumber numberWithInt: smsId]};
    NSDictionary *postDic = [BResponseUtil constructRequestCommonParaWithTableName:nil andAPIData:dataDic];
    NSString *getOneUrl   = [[SDKAPIManager defaultAPIManager] querySmsInterface];
    
    //构造网络请求实体
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:getOneUrl];
    
    [requestUtil addParameter:postDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     
                     int code = [BResponseUtil checkResponseWithDic:dictionary withDataCountCanZero:NO];
                     
                     switch (code) {
                         case ResponseResultOfConnectError:{
                             //将网络请求中的错误返回
                             [BResponseUtil executeQuerySMSCodeStateResultBlock:block withResult:nil andError:error];
                         }
                             break;
                             
                         case ResponseResultOfServerError:{
                             NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                             [BResponseUtil executeQuerySMSCodeStateResultBlock:block withResult:nil andError:error];
                         }
                             break;
                             
                         case ResponseResultOfRequestError:{
                             //返回相应的错误信息
                             NSError *error = [BCommonUtils errorWithResult:dictionary];
                             [BResponseUtil executeQuerySMSCodeStateResultBlock:block withResult:nil andError:error];
                         }
                             break;
                             
                         case ResponseResultOfSuccess:{
                             //正确的返回
                             debugLog(@"%@",dictionary);
                             [BResponseUtil executeQuerySMSCodeStateResultBlock:block withResult:[dictionary objectForKey:@"data"] andError:nil];
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

                     [BResponseUtil executeQuerySMSCodeStateResultBlock:block withResult:nil andError:error];
                 }];
}

@end
