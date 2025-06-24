//
//  BResponseUtil.m
//  BmobSDK
//
//  Created by Bmob on 16/3/16.
//  Copyright © 2016年 donson. All rights reserved.
//

#import "BResponseUtil.h"
#import "BRequestDataFormat.h"
@implementation BResponseUtil


/**
 *  构造post数据
 *
 *  @param tableName <#tableName description#>
 *  @param dataDic   <#dataDic description#>
 *
 *  @return <#return value description#>
 */
+ (NSDictionary *)constructRequestCommonParaWithTableName:(NSString*)tableName andAPIData:(NSDictionary*)dataDic{
    
    return [self constructRequestCommonParaWithTableName:tableName andAPIData:dataDic extraRequestDicValue:nil];
}

+ (NSDictionary *)constructRequestCommonParaWithTableName:(NSString*)tableName andAPIData:(NSDictionary*)dataDic extraRequestDicValue:(NSDictionary *)extraRequestDicValue{
    //请求数据
    
    NSDictionary *requestDic = [BRequestDataFormat requestDictionaryWithClassname:tableName data:dataDic extraPara:extraRequestDicValue];
    
    debugLog(@"requestDic:%@",requestDic);
    return requestDic;
}

/**
 *  <#Description#>
 *
 *  @param responseResultDic  <#responseResultDic description#>
 *  @param isDataCountCanZero 明确正确返回，即status code 为200时data是否能为空
 *
 *  @return <#return value description#>
 */
+ (ResponseResult)checkResponseWithDic:(NSDictionary *)responseResultDic withDataCountCanZero:(BOOL)isDataCountCanZero{
    //判断是否有返回结果
    if (!responseResultDic || [responseResultDic count] <= 0)  {
        return ResponseResultOfConnectError;
    }
    
    
    NSDictionary *dataDic = responseResultDic [@"data"];
    NSDictionary *resultDic = responseResultDic [@"result"];
    
    if (!dataDic || !resultDic || resultDic.count <= 0) {
        return ResponseResultOfServerError;
    }
    
    
    //判断服务器返回结果代码
    int resultCode = [resultDic [@"code"] intValue];
    if (resultCode == 200) {
        //判断服务器返回来的两个字典是否为空，因为有些接口的data可为空，而有些接口不可为空，当不可为空时，若服务器传回来的数据为空，则说明是服务器错误，在使用服务器新接口时先明确该接口的data是否可以为空
        if (!isDataCountCanZero && dataDic.count == 0) {
            return ResponseResultOfServerError;
        }
        
        return ResponseResultOfSuccess;
    } else {
        return ResponseResultOfRequestError;
    }
}

+(NSError*)constructResponseErrorMessage:(NSDictionary *)responseDic{
    NSInteger code = [responseDic [@"result"] [@"code"] intValue];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:responseDic [@"result"] [@"message"] forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:kErrorDomain code:code userInfo:userInfo];
    return error;
}

# pragma mark 各类block的执行
/**
 *  block不为空时，执行block
 */
+(void)executeIntegerResultBlock:(BmobIntegerResultBlock)block withMsgId:(int)msgId andError:(NSError *)error{
    if (block) {
        block(msgId,error);
    }
}

/**
 *  block不为空时，执行block
 */
+(void)executeBooleanResultBlock:(BmobBooleanResultBlock)block withResult:(Boolean)isSuccessful andError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block(isSuccessful,error);
        }
    });
    
}

+(void)executeUserResultBlock:(BmobUserResultBlock)block withResult:(BmobUser*)user andError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block(user,error);
        }
    });
    
}

+(void)executeQuerySMSCodeStateResultBlock:(BmobQuerySMSCodeStateResultBlock)block withResult:(NSDictionary*)dic andError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block(dic,error);
        }
    });
    
}

+(void)executeBmobTableSchemasBlock:(BmobTableSchemasBlock)block withResult:(BmobTableSchema*)bmobTableScheme andError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block(bmobTableScheme,error);
        }
    });
    
}

+(void)executeBmobAllTableSchemasBlock:(BmobAllTableSchemasBlock)block withResult:(NSArray*)tableSchemasArray andError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block(tableSchemasArray,error);
        }
    });
    
}

@end
