//
//  BmobBatch.m
//  BmobSDK
//
//  Created by Bmob on 14-4-21.
//  Copyright (c) 2014年 Bmob. All rights reserved.
//

#import "BmobObjectsBatch.h"
#import "BCommonUtils.h"
#import "BHttpClientUtil.h"
#import "BmobGeoPoint.h"
#import "BmobFile.h"
#import "BmobObject.h"
#import "BmobUser.h"
#import "BRequestDataFormat.h"
#import "SDKAPIManager.h"

@interface BmobObjectsBatch (){
    NSMutableArray *    _objectsArray;
}
@end



@implementation BmobObjectsBatch

-(id)init{
    self = [super init];
    if (self) {
        _objectsArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)saveBmobObjectWithClassName:(NSString *)className parameters:(NSDictionary*)para{
    if (!className || [className isEqualToString:@""]) {
        return;
    }
    if ([para count] == 0) {
        return;
    }
    
    NSMutableDictionary *saveDic = [NSMutableDictionary dictionary];
    
    [saveDic setObject:@"POST" forKey:@"method"];
    [saveDic setObject:[NSString stringWithFormat:@"/1/classes/%@",className] forKey:@"path"];
    [saveDic setObject:[self turnDictionaryFromDataDictionary:para ] forKey:@"body"];
    [_objectsArray addObject:saveDic];
    
}

-(void)updateBmobObjectWithClassName:(NSString*)className objectId:(NSString*)objectId parameters:(NSDictionary*)para{
    if (!className || [className isEqualToString:@""]) {
        return;
    }
    if (!objectId || [objectId isEqualToString:@""]) {
        return;
    }
    if ([para count] == 0) {
        return;
    }
    
    NSMutableDictionary *updateDic = [NSMutableDictionary dictionary];
    
    [updateDic setObject:@"PUT" forKey:@"method"];
    [updateDic setObject:[NSString stringWithFormat:@"/1/classes/%@/%@",className,objectId] forKey:@"path"];
    NSString *token = [BCommonUtils sessionToken];
    if(token){
        
        [updateDic setObject:token forKey:@"token"];
    }
    
    
    [updateDic setObject:[self turnDictionaryFromDataDictionary:para ] forKey:@"body"];
    [_objectsArray addObject:updateDic];
}

-(void)deleteBmobObjectWithClassName:(NSString *)className objectId:(NSString*)objectId{
    if (!className || [className isEqualToString:@""]) {
        return;
    }
    if (!objectId || [objectId isEqualToString:@""]) {
        return;
    }
    
    NSMutableDictionary *deleteDic = [NSMutableDictionary dictionary];
    [deleteDic setObject:@"DELETE" forKey:@"method"];
    [deleteDic setObject:[NSString stringWithFormat:@"/1/classes/%@/%@",className,objectId] forKey:@"path"];
    NSString *token = [BCommonUtils sessionToken];
    if(token){
        [deleteDic setObject:token forKey:@"token"];
    }
    
    [_objectsArray addObject:deleteDic];
}

-(void)batchObjectsInBackgroundWithResultBlock:(void(^)(BOOL isSuccessful,NSError *error))block{
    if (!_objectsArray || _objectsArray.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullArray];
                block(NO,error);
            }
        });
        
        
    }else if ([_objectsArray count] > 50) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeArraySizeLarge];
                block(NO,error);
            }
        });
        
        
    }else{
        
        NSDictionary    *dataDic           = [NSDictionary dictionaryWithObjectsAndKeys:_objectsArray,@"requests", nil];
        NSDictionary *requestDic = [BRequestDataFormat requestDictionaryWithClassname:nil data:dataDic];
        
        NSString *batchUrl       = [[SDKAPIManager defaultAPIManager] batchInterface];
        
        BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:batchUrl];
        
        [requestUtil addParameter:requestDic
                     successBlock:^(NSDictionary *dictionary, NSError *error) {
                         NSDictionary    *batchDic =dictionary;
                         if (batchDic && batchDic.count > 0) {
                             if ([[[batchDic objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                                 if (block) {
                                     block(YES,nil);
                                 }
                             } else{
                                 if (block) {
                                     NSError *error = [BCommonUtils errorWithResult:batchDic];
                                     block(NO,error);
                                 }
                             }
                         } else{
                             if (block) {
                                 NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                 block(NO,error);
                             }
                         }
                     } failBlock:^(NSError *err){
                         if (block) {
                             BmobErrorType type = BmobErrorTypeConnectFailed;
                             if (err) {
                                 type = (BmobErrorType)err.code;
                             }
                             NSError * error = [BCommonUtils errorWithType:type];
                             block(NO,error);
                         }
                     }];
    }
}


/**
 *  批量修改数据
 *
 *  @param block 返回操作的的结果和信息
 */

-(void)batchObjectsInBackground:(void(^)(NSArray *results,NSError *error))block{
    
    if (!_objectsArray || _objectsArray.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullArray];
                block(nil,error);
            }
        });
        
        
    }else if ([_objectsArray count] > 50) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeArraySizeLarge];
                block(nil,error);
            }
        });
        
        
    }else{
        
        NSDictionary    *dataDic           = [NSDictionary dictionaryWithObjectsAndKeys:_objectsArray,@"requests", nil];
        NSDictionary *requestDic = [BRequestDataFormat requestDictionaryWithClassname:nil data:dataDic];
        
        NSString *batchUrl                 = [[SDKAPIManager defaultAPIManager] batchInterface];
        
        
        BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:batchUrl];
        
        [requestUtil addParameter:requestDic
                     successBlock:^(NSDictionary *dictionary, NSError *error) {
                         NSDictionary    *batchDic =dictionary;
                         if (batchDic && batchDic.count > 0) {
                             if ([[[batchDic objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                                 NSArray *array = batchDic[@"data"];
                                 if (block) {
                                     block(array,nil);
                                 }
                             } else{
                                 if (block) {
                                     NSError *error = [BCommonUtils errorWithResult:batchDic];
                                     block(nil,error);
                                 }
                             }
                         } else{
                             if (block) {
                                 NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                 block(nil,error);
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



-(void)dealloc{
    
    _objectsArray = nil;
    
}



-(NSDictionary *)turnDictionaryFromDataDictionary:(NSDictionary *)referenceDictionary{
    NSMutableDictionary *dic = [NSMutableDictionary   dictionary];
    for (NSString *aKey in [referenceDictionary allKeys]) {
        
        id obj = [referenceDictionary objectForKey:aKey];
        if (!obj || [[obj class] isKindOfClass:[NSNull class]] ) {
            return nil;
        }
        if (!aKey || [aKey isEqualToString:@""]) {
            return nil;
        }
        
        if ([obj isKindOfClass:[NSArray class]]) {
            dic[aKey] = obj;
        }else if ([obj isKindOfClass:[NSDate class]]){
            NSDictionary *tmpDic = @{@"__type":@"Date",@"iso":[BCommonUtils stringOfDate:obj ]};
            
            dic[aKey] = tmpDic;
        }else if([obj isKindOfClass:[NSDictionary class]]){
            dic[aKey] = obj;
            //        [self.bmobDataDic setObject:obj forKey:aKey];
        }else if([obj isKindOfClass:[BmobGeoPoint class]]){
            BmobGeoPoint *tmpBgPoint = (BmobGeoPoint*)obj;
            NSDictionary *tmpDic = @{@"__type":@"GeoPoint",@"latitude":[NSNumber numberWithDouble:tmpBgPoint.latitude],@"longitude":[NSNumber numberWithDouble:tmpBgPoint.longitude]};
            dic[aKey] = tmpDic;
            
        }else if([obj isKindOfClass:[BmobFile class]]){
            BmobFile *tmpBFile = (BmobFile*)obj;
            NSString *fileUrl = [tmpBFile.url stringByReplacingOccurrencesOfString:@"https://file.bmob.cn/" withString:@""];
            
            NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"File",@"__type",tmpBFile.group,@"group",fileUrl,@"url",tmpBFile.name,@"filename", nil];
            //        [self.bmobDataDic setObject:tmpDic forKey:aKey];
            dic[aKey] = tmpDic;
        }else if ([obj isKindOfClass:[BmobObject class]] || [obj isKindOfClass:[BmobUser class]]){
            BmobObject *tmpObj = (BmobObject *)obj;
            NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer",@"__type",tmpObj.className,@"className",tmpObj.objectId,@"objectId", nil];
            //        [self.bmobDataDic setObject:tmpDic forKey:aKey];
            dic[aKey] = tmpDic;
        }else{
            dic[aKey] = obj;
        }
    }
    
    
    return dic;
}




@end
