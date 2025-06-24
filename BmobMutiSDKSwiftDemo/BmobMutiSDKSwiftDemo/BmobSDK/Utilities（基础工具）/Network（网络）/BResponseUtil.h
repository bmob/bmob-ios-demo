//
//  BResponseUtil.h
//  BmobSDK
//
//  Created by Bmob on 16/3/16.
//  Copyright © 2016年 donson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BmobConfig.h"

typedef enum{
    ResponseResultOfConnectError, //连接服务器时出现错误
    ResponseResultOfServerError, //服务器返回data结果里面为空，为服务器的错误，出现该错误时需要与后台进行联调查看
    ResponseResultOfRequestError, //向服务器进行请求，服务器返回来的结果码显示错误，一般是请求参数有问题
    ResponseResultOfSuccess       //返回结果是正确的，该情况下将data结果返回给用户
}ResponseResult;

@interface BResponseUtil : NSObject


+ (NSDictionary *)constructRequestCommonParaWithTableName:(NSString*)tableName andAPIData:(NSDictionary*)dataDic;

+ (NSDictionary *)constructRequestCommonParaWithTableName:(NSString*)tableName andAPIData:(NSDictionary*)dataDic extraRequestDicValue:(NSDictionary *)extraRequestDicValue;

+ (ResponseResult)checkResponseWithDic:(NSDictionary *)responseResultDic withDataCountCanZero:(BOOL)isDataCountCanZero;

+(NSError*)constructResponseErrorMessage:(NSDictionary *)responseDic;

# pragma mark 各类block的执行
+(void)executeIntegerResultBlock:(BmobIntegerResultBlock)block withMsgId:(int)msgId andError:(NSError *)error;

+(void)executeBooleanResultBlock:(BmobBooleanResultBlock)block withResult:(Boolean)isSuccessful andError:(NSError *)error;

+(void)executeUserResultBlock:(BmobUserResultBlock)block withResult:(BmobUser*)user andError:(NSError*)error;

+(void)executeQuerySMSCodeStateResultBlock:(BmobQuerySMSCodeStateResultBlock)block withResult:(NSDictionary*)dic andError:(NSError *)error;

+(void)executeBmobTableSchemasBlock:(BmobTableSchemasBlock)block withResult:(BmobTableSchema*)bmobTableScheme andError:(NSError *)error;

+(void)executeBmobAllTableSchemasBlock:(BmobAllTableSchemasBlock)block withResult:(NSArray*)dic andError:(NSError *)error;

@end
