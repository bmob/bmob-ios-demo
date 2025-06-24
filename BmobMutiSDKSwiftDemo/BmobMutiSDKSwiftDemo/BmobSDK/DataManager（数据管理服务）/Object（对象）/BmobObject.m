//
//  BmobObject.m
//  BmobSDK
//
//  Created by Bmob on 13-8-1.
//  Copyright (c) 2013年 Bmob. All rights reserved.
//

#import "BmobObject.h"
#import "BCommonUtils.h"
#import "BmobGeoPoint.h"
#import "BmobFile.h"
#import "BHttpClientUtil.h"
#import "BmobUser.h"
#import "BmobRelation.h"
#import "BmobACL.h"
#import "BmobRole.h"
#import "BmobInstallation.h"
#import "BRequestDataFormat.h"
#import "SDKAPIManager.h"


@class BmobRole;
@class BmobInstallation;

@interface BmobObject(){

}

@property(nonatomic,strong)NSMutableDictionary      *dataDic;

@property (copy, nonatomic) NSDictionary *requestDataDictionary;

@end



@implementation BmobObject

@synthesize dataDic = _dataDic;
@synthesize objectId    = _objectId;
@synthesize createdAt   = _createdAt;
@synthesize updatedAt   = _updatedAt;
@synthesize className   = _className;


-(id)init{
    self = [super init];
    if (self ) {
    }
    
    return self;
}

-(id)initWithClassName:(NSString*)className{
    self = [super init];
    if (self) {
        
        _className   = [className copy];
        
    }
    
    return self;
}



+(instancetype)objectWithClassName:(NSString *)className{
    
    BmobObject *bmobObjectInstance = [[[self class] alloc] initWithClassName:className];
    return bmobObjectInstance ;
}

+(instancetype)objectWithoutDataWithClassName:(NSString *)className objectId:(NSString *)objectId{
    BmobObject *bmobObject = [[[self class] alloc] initWithClassName:className];
    bmobObject.objectId = objectId;
    return bmobObject ;
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"className"]) {
            self.className = [dictionary objectForKey:@"className"];
        }
        
        NSMutableArray *properties = [BCommonUtils allPropertiesWithClass:[self class] isBmobObject:NO];
        //为所有属性赋值
        for (NSString *property in properties){
            if (![property isEqualToString:@"updatedAt"] && ![property isEqualToString:@"createdAt"] && ![property isEqualToString:@"ACL"]) {
                if ([dictionary objectForKey:property] ) {
                    [self setValue:[dictionary objectForKey:property] forKey:property];
                }
            }
            
        }
        if ([dictionary  objectForKey:@"createdAt"] &&!self.createdAt) {
            NSDate *createAt  = [BCommonUtils dateOfString:[NSString stringWithFormat:@"%@",[dictionary  objectForKey:@"createdAt"]]];
            self.createdAt    = createAt;
        }
        if ([dictionary  objectForKey:@"updatedAt"] && !self.updatedAt) {
            NSDate *updateAt  = [BCommonUtils dateOfString:[NSString stringWithFormat:@"%@",[dictionary  objectForKey:@"updatedAt"]]];
            self.updatedAt    = updateAt;
        }
        if (dictionary[@"ACL"] && !self.ACL) {
            self.ACL = [BmobACL ACL];
            [self.ACL setValue:dictionary[@"ACL"] forKey:@"aclDictionary"];
        }
        [self.dataDic setDictionary:dictionary];
        
    }
    return self;
}

-(NSMutableDictionary*)dataDic{
    
    if (!_dataDic) {
        _dataDic = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    
    return _dataDic;
    
}



//将值入放入字典中
-(void)setObject:(id)obj forKey:(NSString*)aKey;{
    if (!_dataDic || _dataDic.count == 0 ) {
        _dataDic = [[NSMutableDictionary alloc] init];
    }
    
    if (!obj || [[obj class] isKindOfClass:[NSNull class]] ) {
        return;
    }
    
    if (!aKey || [aKey isEqualToString:@""]) {
        return;
    }
    
    //Array、NSDictionary、NSNumber、NSString
    if ([obj isKindOfClass:[NSArray class]] ||
        [obj isKindOfClass:[NSDictionary class]]||
        [obj isKindOfClass:[NSNumber class]] ||
        [obj isKindOfClass:[NSString class]]) {
        [self.dataDic setObject:obj forKey:aKey];
        
        //Date
    }else if ([obj isKindOfClass:[NSDate class]]){
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Date",@"__type",[BCommonUtils stringOfDate:obj ],@"iso", nil];
        [self.dataDic setObject:tmpDic forKey:aKey];
        
    }else if([obj isKindOfClass:[BmobGeoPoint class]]){
        BmobGeoPoint *tmpBgPoint = (BmobGeoPoint*)obj;
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"GeoPoint",@"__type",[NSNumber numberWithDouble:tmpBgPoint.latitude],@"latitude",[NSNumber numberWithDouble:tmpBgPoint.longitude],@"longitude", nil];
        [self.dataDic setObject:tmpDic forKey:aKey];
        
    }else if([obj isKindOfClass:[BmobFile class]]){
        BmobFile *tmpBFile = (BmobFile*)obj;
        NSString *fileUrl = tmpBFile.url;

        NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"File",@"__type",fileUrl,@"url",tmpBFile.name,@"filename", nil];
        [self.dataDic setObject:tmpDic forKey:aKey];
        
    }else if ([obj isKindOfClass:[BmobObject class]] || [obj isKindOfClass:[BmobInstallation class]]){
        BmobObject *tmpObj = (BmobObject *)obj;
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer",@"__type",tmpObj.className,@"className",tmpObj.objectId,@"objectId", nil];
        [self.dataDic setObject:tmpDic forKey:aKey];
    }
}


-(void)addRelation:(BmobRelation *)relation forKey:(id)key{
    
    if (!relation || [[relation class] isKindOfClass:[NSNull class]] ) {
        return;
    }
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    BOOL isAdd                = [[relation valueForKey:@"isAddObject"] boolValue];
    NSArray *array            = [relation valueForKey:@"relationArray"];
    if (isAdd) {
        if (array) {
            NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"AddRelation",@"__op",array,@"objects", nil];
            [self.dataDic setObject:tmpDic forKey:key];
        }
    }else{
        if (array) {
            NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"RemoveRelation",@"__op",array,@"objects", nil];
            [self.dataDic setObject:tmpDic forKey:key];
        }
    }
}




-(void)saveAllWithDictionary:(NSDictionary*)dic{
    if ([dic count] == 0) {
        return;
    }
    else{
        for (NSString *aKey in [dic allKeys]) {
            id obj = [dic objectForKey:aKey];
            [self setObject:obj forKey:aKey];
        }
    }
    
}

-(id)objectForKey:(id)aKey{
    
    /**
     *  返回的是字典，如果字典里面包含特殊对象，需要将其转换成特殊对象返回给用户，这类对象有BmobObject,BmobUser,BmobGeoPoint,BmobFile,NSDate,BmobInstallation
     */
    if ([[self.dataDic objectForKey:aKey] isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *tmpDic = [self.dataDic objectForKey:aKey];
        NSString *typeStr = [(NSString*)[tmpDic objectForKey:@"__type"] description];
        if (typeStr) {
            if ([typeStr isEqualToString:@"GeoPoint"]) {
                
                BmobGeoPoint   *bmobGeoPoint = [[BmobGeoPoint alloc] init];
                bmobGeoPoint.latitude = [[tmpDic objectForKey:@"latitude"] doubleValue];
                bmobGeoPoint.longitude = [[tmpDic objectForKey:@"longitude"] doubleValue];
                
                return bmobGeoPoint;
                
            }else if ([typeStr isEqualToString:@"File"]) {
                
                BmobFile   *bfile = [[BmobFile alloc] init];
                bfile.group =[tmpDic objectForKey:@"group"];
                
                NSString *url = [tmpDic objectForKey:@"url"];
                if ([url rangeOfString:@"http://"].location != NSNotFound || [url rangeOfString:@"https://"].location != NSNotFound) {
                    //如果是upyun 的直接换成https
                    if ([url rangeOfString:@"http://bmob-cdn"].location != NSNotFound && [url rangeOfString:@"upaiyun.com"].location != NSNotFound) {
                        url = [url stringByReplacingOccurrencesOfString:@"http://bmob-cdn" withString:@"https://bmob-cdn"];
                    }
                    
                    bfile.url   = url;
                    
                    
                }else{
                    bfile.url   = [NSString stringWithFormat:@"%@/%@",[BCommonUtils fileHost], url ];
                }
                
                bfile.name =[tmpDic objectForKey:@"filename"];
                
                return bfile;
                
            }else if ([typeStr isEqualToString:@"Date"]) {
                
                NSDate *createAt = [BCommonUtils dateOfString:[NSString stringWithFormat:@"%@",[tmpDic objectForKey:@"iso"]]];
                return createAt;
                
            }else if ([typeStr isEqualToString:@"Pointer"]) {
                
                BmobObject  *obj = [[self class] objectWithoutDataWithClassName:[tmpDic objectForKey:@"className"] objectId:[tmpDic objectForKey:@"objectId"]];
                return obj;
                
            }else if ([typeStr isEqualToString:@"Object"]){
                return  [self objectConvertFromDictionary:tmpDic];
            }
        }else{
            return tmpDic;
        }
    }
    
    
    return  [self.dataDic objectForKey:aKey];
}

-(id)objectConvertFromDictionary:(NSDictionary *)tmpDic{
    
    BmobObject *obj = nil;
    NSString *className = (NSString*)[tmpDic objectForKey:@"className"];
    
    if ([className isEqualToString:@"_User"]) {
        BmobUser *bUser = [[BmobUser alloc] initWithDictionary:tmpDic];
        return bUser;
        
    }else if([className isEqualToString:@"_Role"]){
        
        BmobRole *bRole = [[BmobRole alloc] initWithDictionary:tmpDic];
        return bRole;
        
    }else if ([className isEqualToString:@"_Installation"]){
        

        BmobInstallation *bInstallatoin = [[BmobInstallation alloc] initWithDictionary:tmpDic];
        return bInstallatoin;
        
    }else{
        BmobObject *bObject = [[[self class] alloc] initWithDictionary:tmpDic];
        return bObject;
    }
    
    return obj;
}

-(void)deleteForKey:(id)key{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    
    NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Delete",@"__op", nil];
    [self.dataDic setObject:tmpDic forKey:key];
}

//自增自减
- (void)incrementKey:(NSString *)key{
    [self incrementKey:key byAmount:1];
}


- (void)incrementKey:(NSString *)key byNumber:(NSNumber *)number{
    if (!key || [key isEqualToString:@""] || !number) {
        return;
    }
    NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Increment",@"__op",number,@"amount", nil];
    [self.dataDic setObject:tmpDic forKey:key];
}

- (void)incrementKey:(NSString *)key byAmount:(NSInteger )amount{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Increment",@"__op",[NSNumber numberWithInteger:amount],@"amount", nil];
    [self.dataDic setObject:tmpDic forKey:key];
}

- (void)decrementKey:(NSString *)key{
    [self incrementKey:key byAmount:-1];
}

- (void)decrementKey:(NSString *)key byNumber:(NSNumber *)number{
    if (!key || [key isEqualToString:@""] || !number) {
        return;
    }
    NSNumber *number1 = [NSNumber numberWithDouble:-[number doubleValue]];
    NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Increment",@"__op",number1,@"amount", nil];
    [self.dataDic setObject:tmpDic forKey:key];
}

- (void)decrementKey:(NSString *)key byAmount:(NSInteger )amount{
    [self incrementKey:key byAmount:-amount];
}

#pragma mark do something with dictionary

//查询后得到数据赋值给 self.dataDic
-(void)getDictionaryAfterQuery:(NSDictionary *)dictionary{
    
    
    if (dictionary) {
        [self.dataDic setDictionary:dictionary];
    }
    
    
}


-(void)emptyDataDic{
    [self.dataDic removeAllObjects];
}

-(NSDictionary*)requestDataDictionary{
    
    _requestDataDictionary = [[NSDictionary alloc] init];
    NSDictionary *tmpAclDic = [self.ACL valueForKey:@"aclDictionary"];
    if (tmpAclDic && [tmpAclDic count] > 0) {
        [self.dataDic setObject:tmpAclDic forKey:@"ACL"];
    }
    _requestDataDictionary = [self.dataDic copy];

    return _requestDataDictionary;
}

#pragma mark  array add and remove

- (void)addObjectsFromArray:(NSArray *)objects forKey:(NSString *)key{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    if (!objects) {
        return;
    }
    
    NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Add",@"__op",objects,@"objects", nil];
    [self.dataDic setObject:tmpDic forKey:key];
}

- (void)addUniqueObjectsFromArray:(NSArray *)objects forKey:(NSString *)key{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    if (!objects) {
        return;
    }
    
    NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"AddUnique",@"__op",objects,@"objects", nil];
    [self.dataDic setObject:tmpDic forKey:key];
}

- (void)removeObjectsInArray:(NSArray *)objects forKey:(NSString *)key{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    if (!objects) {
        return;
    }
    
    NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Remove",@"__op",objects,@"objects", nil];
    [self.dataDic setObject:tmpDic forKey:key];
}



#pragma mark firsttime operate
//保存
-(void)saveInBackground{
    
    if ([self.dataDic count] == 0) {
        return;
    }
    
    [self saveInBackgroundWithResultBlock:nil callbackOrNot:NO];
}

-(void)saveInBackgroundWithResultBlock:(BmobBooleanResultBlock)block{
    [self saveInBackgroundWithResultBlock:block callbackOrNot:YES];
}

-(void)saveInBackgroundWithResultBlock:(BmobBooleanResultBlock)block callbackOrNot:(BOOL)needCallBack{
    NSMutableDictionary  *requestDic = [NSMutableDictionary dictionaryWithCapacity:1];
    @try {
        NSDictionary *dataDic = [self requestDataDictionary];
        [requestDic setDictionary:[BRequestDataFormat requestDictionaryWithClassname:self.className data:dataDic]];
        NSString *token = [BCommonUtils sessionToken];
        if (token) {
            
            requestDic[@"sessionToken"]  = token;
        }
    }
    @catch (NSException *exception) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
            if (needCallBack) {
                if (block) {
                    block(NO,error);
                }
            }
        });
        
        return;
    }
    @finally {
        
    }
    
    
    NSString *createUrl = [[SDKAPIManager defaultAPIManager] createInterface];
//    NSLog(@"111 createUrl is %@",createUrl);
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:createUrl];
    __weak typeof(BHttpClientUtil *) weakRequest = requestUtil;
    
    [weakRequest addParameter:requestDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     
                     NSDictionary    *createDic =dictionary;
                     if (createDic &&  createDic.count > 0) {
                         if ([[[createDic objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                             if ([BCommonUtils isNotNilOrNull:[createDic  objectForKey:@"data"]]) {
                                 self.objectId = [(NSString*)[[createDic  objectForKey:@"data"] objectForKey:@"objectId"] description];
                                 self.createdAt = [BCommonUtils dateOfString:[(NSString*)[[createDic  objectForKey:@"data"] objectForKey:@"createdAt"] description]];
                                 self.updatedAt = [BCommonUtils dateOfString:[(NSString*)[[createDic  objectForKey:@"data"] objectForKey:@"createdAt"] description]];
                             }
                         }
                     }
                     if (needCallBack) {
                         if (createDic) {
                             if ([[[createDic objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                                 
                                 if (block) {
                                     block(YES,nil);
                                 }
                             }
                             else{
                                 NSError *error = [BCommonUtils errorWithResult:createDic];
                                 if (block) {
                                     block(NO,error);
                                 }
                             }
                         }
                         else{
                             if (block) {
                                 NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                 block(NO,error);
                             }
                         }
                     }
                 } failBlock:^(NSError *err){
                     
                     if (needCallBack) {
                         if (block) {
                             BmobErrorType type = BmobErrorTypeConnectFailed;
                             if (err) {
                                 type = (BmobErrorType)err.code;
                             }
                             NSError * error = [BCommonUtils errorWithType:type];
                             block(NO,error);
                         }
                     }
                 }];
}


-(void)updateInBackground{
    
    if (!self.objectId) {
        return;
    }
    [self updateInBackgroundWithResultBlock:nil callback:NO];
}


-(void)updateInBackgroundWithResultBlock:(BmobBooleanResultBlock)block{
    if (!self.objectId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullObjectId];
                block(NO,error);
            }
        });
        
        
    }else{
        [self updateInBackgroundWithResultBlock:block callback:YES];
    }
    
}


-(void)updateInBackgroundWithResultBlock:(BmobBooleanResultBlock)block callback:(BOOL)needCallBack{
    
    NSMutableDictionary  *requestDic = [NSMutableDictionary dictionaryWithCapacity:1];
    
    @try {
        NSDictionary *dataDic            = [self requestDataDictionary];
        NSMutableDictionary *mutableDataDic = [NSMutableDictionary dictionaryWithDictionary:dataDic];
        if (dataDic) {
            
            
            if ([mutableDataDic objectForKey:@"objectId"]) {
                [mutableDataDic removeObjectForKey:@"objectId"];
            }
            
            if ([mutableDataDic objectForKey:@"updatedAt"]) {
                [mutableDataDic removeObjectForKey:@"updatedAt"];
            }
            
            if ([mutableDataDic objectForKey:@"createdAt"]) {
                [mutableDataDic removeObjectForKey:@"createdAt"];
            }
            
            if ([mutableDataDic objectForKey:@"className"]) {
                [mutableDataDic removeObjectForKey:@"className"];
            }
            
            
            
            NSDictionary *mutableDataDicCopy = [mutableDataDic copy];
            [mutableDataDicCopy enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    if ([[obj objectForKey:@"__type"] isEqualToString:@"Relation"]) {
                        [mutableDataDic removeObjectForKey:key];
                    }
                }
            }];
            
            
        }
        
        [requestDic setDictionary:[BRequestDataFormat requestDictionaryWithClassname:self.className data:mutableDataDic objectId:self.objectId]];
        NSString *token = [BCommonUtils sessionToken];
        if (token) {
           
            requestDic[@"sessionToken"]  = token;
        }
    }
    @catch (NSException *exception) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
            if (needCallBack) {
                if (block) {
                    block(NO,error);
                }
            }
        });
        
        return;
    }
    @finally {
        
    }
    
    
    

    NSString *updateUrl = [[SDKAPIManager defaultAPIManager] updateInterface];
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:updateUrl];
    __weak typeof(BHttpClientUtil *) weakRequest = requestUtil;
    
    [weakRequest addParameter:requestDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     
                     NSDictionary    *updateDic =dictionary;
                     if (needCallBack) {
                         if (updateDic &&  updateDic.count > 0) {
                             //更新成功
                             if ([[[updateDic objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                                 if (block) {
                                     block(YES,nil);
                                 }
                             }else{
                                 if (block) {
                                     NSError *error = [BCommonUtils errorWithResult:updateDic];
                                     block(NO,error);
                                 }
                                 
                             }
                         }else{
                             if (block) {
                                 NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                 block(NO,error);
                             }
                             
                         }
                     }
                     if (updateDic  &&  updateDic.count > 0) {
                         //更新成功
                         if ([[[updateDic objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                             self.updatedAt = [BCommonUtils dateOfString:[(NSString*)[[updateDic  objectForKey:@"data"] objectForKey:@"updatedAt"] description]];
                         }
                     }
                 } failBlock:^(NSError *err){
                     
                     if (needCallBack) {
                         if (block) {
                             BmobErrorType type = BmobErrorTypeConnectFailed;
                             if (err) {
                                 type = (BmobErrorType)err.code;
                             }
                             NSError * error = [BCommonUtils errorWithType:type];
                             block(NO,error);
                         }
                         
                     }
                 }];
    
}


-(void)deleteInBackground{
    if (!self.objectId) {
        return;
    }
    [self deleteInBackgroundWithBlock:nil callback:NO];
}


-(void)deleteInBackgroundWithBlock:(BmobBooleanResultBlock)block{
    if (!self.objectId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullObjectId];
                block(NO,error);
            }
        });
        
        
    } else{
        [self deleteInBackgroundWithBlock:block callback:YES];
    }
}

-(void)deleteInBackgroundWithBlock:(BmobBooleanResultBlock)block callback:(BOOL)needCallback{
    if (self.dataDic) {
        [self.dataDic removeAllObjects];
    }
    
    if (!self.className || self.className.length == 0) {
        if (needCallback) {
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullClassName];
                block(NO,error);
            }
        }
        return;
    }
    
    
    NSMutableDictionary  *requestDic = [NSMutableDictionary dictionaryWithDictionary:[BRequestDataFormat requestDictionaryWithClassname:self.className data:nil objectId:self.objectId]];
    NSString *token = [BCommonUtils sessionToken];
    if (token) {
        
        requestDic[@"sessionToken"]  = token;
    }
    

    NSString *deleteUrl = [[SDKAPIManager defaultAPIManager] deleteInterface];
    
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:deleteUrl];
    [requestUtil addParameter:requestDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     NSDictionary    *deleteDic =dictionary;
                     if (needCallback) {
                         if (deleteDic && deleteDic.count > 0) {
                             //删除成功
                             if ([[[deleteDic objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                                 if (block) {
                                     block(YES,nil);
                                 }
                             }else {
                                 if (block) {
                                     NSError *error = [BCommonUtils errorWithResult:deleteDic];
                                     block(NO,error);
                                 }
                             }
                         }else {
                             if (block) {
                                 NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                 block(NO,error);
                             }
                             
                         }
                     }
                 } failBlock:^(NSError *err){
                     if (needCallback) {
                         if (block) {
                             BmobErrorType type = BmobErrorTypeConnectFailed;
                             if (err) {
                                 type = (BmobErrorType)err.code;
                             }
                             NSError * error = [BCommonUtils errorWithType:type];
                             block(NO,error);
                         }
                     }
                 }];
}

-(NSString *)description{
    NSMutableString *bmobObjectDescription = [[NSMutableString alloc] initWithCapacity:1];
    NSString *className = [NSString stringWithFormat:@"\nclassName = %@;\n",self.className];
    NSString *objectId = [NSString stringWithFormat:@"objectId = %@;\n",self.objectId];
    
    NSLocale* cn = [NSLocale currentLocale];
    NSString *createdAt = [NSString stringWithFormat:@"createdAt = %@;\n",[self.createdAt descriptionWithLocale:cn]];
    NSString *updatedAt = [NSString stringWithFormat:@"updatedAt = %@;\n",[self.updatedAt descriptionWithLocale:cn]];
    NSString *date = [NSString stringWithFormat:@"data = %@;",self.dataDic];
    
    [bmobObjectDescription appendString:className];
    [bmobObjectDescription appendString:objectId];
    [bmobObjectDescription appendString:createdAt];
    [bmobObjectDescription appendString:updatedAt];
    [bmobObjectDescription appendString:date];
    return bmobObjectDescription;
}

- (BOOL)isEqual:(BmobObject*)object{
    if (!object || !object.className || !object.dataDic) {
        return NO;
    }
    
    if ([self.className isEqualToString:object.className] && [self.dataDic isEqual:object.dataDic]) {
        return YES;
    } else {
        return NO;
    }
}


#pragma mark delloc
-(void)dealloc{
    if (_dataDic) {
        
        _dataDic = nil;
    }
    _objectId = nil;
    _createdAt = nil;
    _updatedAt = nil;
    if (_className) {
        
        _className = nil;
    }
    
}

@end
