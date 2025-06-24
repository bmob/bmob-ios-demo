//
//  BmobQuery.m
//  BmobSDK
//
//  Created by Bmob on 13-8-1.
//  Copyright (c) 2013年 Bmob. All rights reserved.
//

#import "BmobQuery.h"
//#import "ASIFormDataRequest.h"
//#import "JSONKit.h"
#import "BCommonUtils.h"
//#import "SFHFKeychainUtils.h"
#import "BHttpClientUtil.h"

#import "BmobUser.h"
#import "BmobInstallation.h"
#import "BmobRole.h"
#import "BRequestDataFormat.h"
#import "BEncryptUtil.h"
#import "BResponseUtil.h"
#import "SDKAPIManager.h"


@interface BmobQuery(){
@private
    NSMutableString             *_queryClassName; //查询表名
    NSMutableDictionary         *_queryDic; //where字典，这里命名不太恰当
    NSString                    *_queryObjectId; //查询记录ID
    BOOL                        _isSuccessful;
    BOOL                        _isGroupcount; //统计时是否加入
    
    BmobObjectArrayResultBlock _bmobObjectArrayBlock;
    NSMutableArray              *_orderArray;//排序的数组
    NSMutableArray              *_keysArray;//包含的键的数组
    NSMutableArray              *_requestArray;
    NSMutableArray              *_sumArray; //求和的列名
    NSMutableArray              *_averageArray;  //求平均数的列名
    NSMutableArray              *_maxArray; //求最大值的列名
    NSMutableArray              *_minArray; //求最小值的列名
    NSMutableArray              *_groupbyArray; //需要分组的列名
    NSMutableDictionary         *_havingDic; //过滤条件字典
    NSMutableString             *_bqlString; //bql语句
    NSMutableArray              *_placeholderArray; //占位符

    
}

@property (nonatomic,strong)NSMutableDictionary* queryDic;
@property (nonatomic,strong)NSMutableDictionary* havingDic;
@property (nonatomic,strong)NSMutableString *queryClassName;
@property (copy, nonatomic)NSString *includeKey;    //专门用于查询关联关系字段
@property (strong, nonatomic) NSMutableArray *queryArray; //复杂查询条件数组
//@property (copy, nonatomic)NSMutableString *bql;
//@property (nonatomic,retain)NSMutableArray *placeholderArray;
@end

@implementation BmobQuery
@synthesize limit          = _limit;
@synthesize skip           = _skip;
@synthesize cachePolicy    = _cachePolicy;
@synthesize queryDic       = _queryDic;
@synthesize queryClassName = _queryClassName;
@synthesize includeKey     = _includeKey;
@synthesize havingDic      = _havingDic;
//@synthesize bql            = _bqlString;
//@synthesize placeholderArray = _placeholderArray;



-(id)initWithClassName:(NSString *)className{
    
    self = [super init];
    if (self) {
        _queryClassName = [[NSMutableString alloc] init];
        [_queryClassName setString: className];
        _queryDic       = [[NSMutableDictionary alloc] init];
        _cachePolicy    = kBmobCachePolicyIgnoreCache;
        _maxCacheAge    = 5*60*60;
        _orderArray     = [[NSMutableArray alloc] init];
        _keysArray      = [[NSMutableArray alloc] init];
        _sumArray       = [[NSMutableArray alloc] init];
        _averageArray   = [[NSMutableArray alloc] init];
        _maxArray       = [[NSMutableArray alloc] init];
        _minArray       = [[NSMutableArray alloc] init];
        _groupbyArray   = [[NSMutableArray alloc] init];
        _isGroupcount     = FALSE;
        _havingDic      = [[NSMutableDictionary alloc] init];
        _requestArray   = [[NSMutableArray alloc] init];
        _bqlString      = [[NSMutableString alloc] init];
        _placeholderArray = [[NSMutableArray alloc] init];
        _queryArray = [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    return self;
}

-(id)init{
    self = [super init];
    if (self) {
        _queryClassName = [[NSMutableString alloc] init];
        _queryDic       = [[NSMutableDictionary alloc] init];
        _cachePolicy    = kBmobCachePolicyIgnoreCache;
        _maxCacheAge    = 5*60*60;
        _orderArray     = [[NSMutableArray alloc] init];
        _keysArray      = [[NSMutableArray alloc] init];
        _sumArray       = [[NSMutableArray alloc] init];
        _averageArray   = [[NSMutableArray alloc] init];
        _maxArray       = [[NSMutableArray alloc] init];
        _minArray       = [[NSMutableArray alloc] init];
        _groupbyArray   = [[NSMutableArray alloc] init];
        _isGroupcount     = FALSE;
        _havingDic      = [[NSMutableDictionary alloc] init];
        _requestArray   = [[NSMutableArray alloc] init];
        _bqlString      = [[NSMutableString alloc] init];
        _placeholderArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}


+(BmobQuery*)queryForUser{
    BmobQuery   *bmobQueryInstance = [[[self class] alloc] initWithClassName:@"_User"];
    return bmobQueryInstance ;
}

+(BmobQuery*)queryWithClassName:(NSString *)className{
    BmobQuery   *bmobQueryInstance = [[[self class] alloc] initWithClassName:className];
    return bmobQueryInstance;//[bmobQueryInstance autorelease];
    
}

-(NSDictionary*)queryDataDic{
    return self.queryDic;
}

#pragma mark sort

-(void)selectKeys:(NSArray*)keys{
    if(!keys){
        return;
    }
    [_keysArray setArray:keys];
}

- (void)orderByAscending:(NSString *)key  {
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    [_orderArray addObject:key];
}

- (void)orderByDescending:(NSString *)key {
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    [_orderArray addObject:[NSString stringWithFormat:@"-%@",key]];
}

- (void)includeKey:(NSString *)key{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    self.includeKey = key;
    //    [self.queryDic setObject:key forKey:@"include"];
}

#pragma mark 统计相关查询
-(void)sumKeys:(NSArray*)keys{
    if (!keys){
        return;
    }
    [_sumArray setArray:keys];
}

-(void)averageKeys:(NSArray*)keys{
    if (!keys) {
        return;
    }
    [_averageArray setArray:keys];
}

-(void)maxKeys:(NSArray*)keys{
    if (!keys) {
        return;
    }
    [_maxArray setArray:keys];
}

-(void)minKeys:(NSArray*)keys{
    if (!keys) {
        return;
    }
    [_minArray setArray:keys];
}

-(void)groupbyKeys:(NSArray*)keys{
    if (!keys) {
        return;
    }
    [_groupbyArray setArray:keys];
}

#pragma mark - 筛选条件

- (void)whereKey:(NSString *)key equalTo:(id)object{
    //检测key合法性
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    
    //检查对象合法性
    if (!object) {
        return;
    }
    
    //判断对象类型
    if ([object isKindOfClass:[BmobObject class]]) {
        BmobObject *obj = (BmobObject *)object;
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer",@"__type",obj.className,@"className",obj.objectId,@"objectId", nil];
        [self.queryDic setObject:tmpDic forKey:key];
    }else if([object isKindOfClass:[NSDate class]]){
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Date",@"__type",[BCommonUtils stringOfDate:object ],@"iso", nil];
        [self.queryDic setObject:tmpDic forKey:key];
    }else{
        [self.queryDic setObject:object forKey:key];
    }
}

-(void)whereKey:(NSString *)key containsAll:(NSArray*)array{
    if (!array || array.count == 0) {
        return;
    }
    
    NSDictionary *dic = @{@"$all":array};
    [self whereKey:key equalTo:dic];
}


- (void)whereKey:(NSString *)key notEqualTo:(id)object{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    if (!object) {
        return;
    }
    if ([object isKindOfClass:[BmobObject class]]) {
        BmobObject *obj = (BmobObject *)object;
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer",@"__type",obj.className,@"className",obj.objectId,@"objectId", nil];
        [self.queryDic setObject:[NSDictionary dictionaryWithObjectsAndKeys:tmpDic,@"$ne", nil] forKey:key];
    }else if([object isKindOfClass:[NSDate class]]){
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Date",@"__type",[BCommonUtils stringOfDate:object ],@"iso", nil];
        [self.queryDic setObject:[NSDictionary dictionaryWithObjectsAndKeys:tmpDic,@"$ne", nil] forKey:key];
    }else{
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:object,@"$ne", nil];
        [self.queryDic setObject:tmpDic forKey:key];
    }
}

- (void)whereKey:(NSString *)key greaterThan:(id)object{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    if (!object) {
        return;
    }
    if ([object isKindOfClass:[NSDate class]]) {
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Date",@"__type",[BCommonUtils stringOfDate:object ],@"iso", nil];
        [self.queryDic setObject:[NSDictionary dictionaryWithObjectsAndKeys:tmpDic,@"$gt", nil] forKey:key];
    } else{
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:object,@"$gt", nil];
        [self.queryDic setObject:tmpDic forKey:key];
    }
}


- (void)whereKey:(NSString *)key greaterThanOrEqualTo:(id)object{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    if (!object) {
        return;
    }
    if ([object isKindOfClass:[NSDate class]]) {
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Date",@"__type",[BCommonUtils stringOfDate:object ],@"iso", nil];
        [self.queryDic setObject:[NSDictionary dictionaryWithObjectsAndKeys:tmpDic,@"$gte", nil] forKey:key];
    }else{
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:object,@"$gte", nil];
        [self.queryDic setObject:tmpDic forKey:key];
    }
    
    
}

- (void)whereKey:(NSString *)key lessThan:(id)object{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    if (!object) {
        return;
    }
    if ([object isKindOfClass:[NSDate class]]) {
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Date",@"__type",[BCommonUtils stringOfDate:object ],@"iso", nil];
        [self.queryDic setObject:[NSDictionary dictionaryWithObjectsAndKeys:tmpDic,@"$lt", nil] forKey:key];
    } else{
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:object,@"$lt", nil];
        [self.queryDic setObject:tmpDic forKey:key];
    }
}


- (void)whereKey:(NSString *)key lessThanOrEqualTo:(id)object{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    if (!object) {
        return;
    }
    if ([object isKindOfClass:[NSDate class]]) {
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Date",@"__type",[BCommonUtils stringOfDate:object ],@"iso", nil];
        [self.queryDic setObject:[NSDictionary dictionaryWithObjectsAndKeys:tmpDic,@"$lte", nil] forKey:key];
    } else{
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:object,@"$lte", nil];
        [self.queryDic setObject:tmpDic forKey:key];
    }
}

- (void)whereKey:(NSString *)key containedIn:(NSArray *)array{
    
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    if (!array) {
        return;
    }
    
    NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:array,@"$in", nil];
    [self.queryDic setObject:tmpDic forKey:key];
}

- (void)whereKey:(NSString *)key notContainedIn:(NSArray *)array{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    if (!array) {
        return;
    }
    NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:array,@"$nin", nil];
    [self.queryDic setObject:tmpDic forKey:key];
}

- (void)whereKeyExists:(NSString *)key{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"$exists", nil];
    [self.queryDic setObject:tmpDic forKey:key];
}

-(void)whereKeysExists:(NSArray *)keys{
    for (NSString *key in keys) {
        [self whereKeyExists:key];
    }
}

-(void)whereKeyDoesNotExist:(NSString *)key{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"$exists", nil];
    [self.queryDic setObject:tmpDic forKey:key];
}

-(void)whereKeysDoesNotExist:(NSArray *)keys{
    
    for (NSString *key in keys) {
        [self whereKeyDoesNotExist:key];
    }
}

# pragma 模糊查询
-(void)whereKey:(NSString*)key matchesWithRegex:(NSString*)regex{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    if (!regex || [key isEqualToString:@""]) {
        return;
    }
    NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:regex,@"$regex", nil];
    [self.queryDic setObject:tmpDic forKey:key];
}

-(void)whereKey:(NSString *)key startWithString:(NSString*)start{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    if (!start || [start isEqualToString:@""]) {
        return;
    }
    NSString *startString = [NSString stringWithFormat:@"^%@",start];
    NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:startString,@"$regex", nil];
    [self.queryDic setObject:tmpDic forKey:key];
}

-(void)whereKey:(NSString *)key endWithString:(NSString*)end{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    if (!end || [end isEqualToString:@""]) {
        return;
    }
    NSString *endString = [NSString stringWithFormat:@"%@$",end];
    NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:endString,@"$regex", nil];
    [self.queryDic setObject:tmpDic forKey:key];
}



- (void)whereKey:(NSString *)key nearGeoPoint:(BmobGeoPoint *)geopoint{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    if (!geopoint) {
        return;
    }
    if ([key isEqualToString:@"objectId"]) {
        key = @"_id";
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"GeoPoint",@"__type",[NSNumber numberWithDouble:geopoint.longitude],@"longitude",[NSNumber numberWithDouble:geopoint.latitude],@"latitude", nil];
    NSDictionary  *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:dic,@"$nearSphere",nil];
    [self.queryDic setObject:tmpDic forKey:key];
}

- (void)whereKey:(NSString *)key matchesQuery:(BmobQuery *)query{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    if (!query) {
        return;
    }
    NSDictionary    *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:query.queryDic,@"where",query.queryClassName,@"className", nil];
    NSDictionary    *qDic = [NSDictionary dictionaryWithObjectsAndKeys:tmpDic,@"$inQuery", nil];
    [self.queryDic setObject:qDic forKey:key];
}


- (void)whereKey:(NSString *)key doesNotMatchQuery:(BmobQuery *)query{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    if (!query) {
        return;
    }
    NSDictionary*    tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:query.queryDic,@"where",query.queryClassName,@"className", nil];
    NSDictionary*    qDic = [NSDictionary dictionaryWithObjectsAndKeys:tmpDic,@"$notInQuery", nil];
    [self.queryDic setObject:qDic forKey:key];
}

- (void)whereObjectKey:(NSString *)key relatedTo:(BmobObject*)object{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    if (!object) {
        return;
    }
    NSDictionary*    tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer",@"__type",object.className,@"className" ,object.objectId,@"objectId",nil];
    NSDictionary*    rDic = [NSDictionary dictionaryWithObjectsAndKeys:tmpDic,@"object",key,@"key", nil];
    [self.queryDic setObject:rDic forKey:@"$relatedTo"];
    
}

#pragma mark 组合查询

- (void)add:(BmobQuery *)query{
    if (!query || [query queryDataDic].count != 1) {
        return;
    }
    [self.queryArray addObject:[query queryDataDic]];
}

-(void)addTheConstraintByAndOperationWithArray:(NSArray*)array;{
    if (!array) {
        return;
    }
    [self.queryDic setObject:array forKey:@"$and"];
}

- (void)andOperation{
//    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:1];
//    for (NSString *key in self.queryDic.allKeys) {
//        NSDictionary *dic = @{key:self.queryDic[key]};
//        [array addObject:dic];
//    }
//    [self.queryDic removeAllObjects];
    [self.queryDic setObject:self.queryArray forKey:@"$and"];
}


-(void)addTheConstraintByOrOperationWithArray:(NSArray *)array{
    if (!array) {
        return;
    }
    
    [self.queryDic setObject:array forKey:@"$or"];
}

- (void)orOperation{
//    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:1];
//    for (NSString *key in self.queryDic.allKeys) {
//        NSDictionary *dic = @{key:self.queryDic[key]};
//        [array addObject:dic];
//    }
//    [self.queryDic removeAllObjects];
    [self.queryDic setObject:self.queryArray forKey:@"$or"];
}


-(void)queryWithAllConstraint:(NSDictionary*)condition{
    if (!condition || [condition count ] == 0) {
        return;
    }
    [self.queryDic removeAllObjects];
    [self.queryDic setDictionary:condition ];
}

-(void)constructHavingDic:(NSDictionary*)havingDic{
    if (!havingDic || [havingDic count] == 0) {
        return;
    }
    [self.havingDic setDictionary:havingDic];
}

/**
 *  构造查询条件，可以与其他方法同时存在
 *
 *  @param dictionary 查询条件
 */
-(void)queryWithConstraint:(NSDictionary *)condition{
    if (!condition || [condition count ] == 0) {
        return;
    }
    
    [condition enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self.queryDic setObject:obj forKey:key];
    }];
}


//1公里 1000米
//1英里 1609

#pragma mark 地理位置查询

///3958.8000000000002f弧度 英里

//6371.0f

- (void)whereKey:(NSString *)key nearGeoPoint:(BmobGeoPoint *)geopoint withinMiles:(double)maxDistance{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    if (!geopoint) {
        return;
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"GeoPoint",@"__type",[NSNumber numberWithDouble:geopoint.longitude],@"longitude",[NSNumber numberWithDouble:geopoint.latitude],@"latitude", nil];
    NSDictionary  *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:dic,@"$nearSphere",[NSNumber numberWithDouble:maxDistance],@"$maxDistanceInMiles",nil];
    [self.queryDic setObject:tmpDic forKey:key];
}


- (void)whereKey:(NSString *)key nearGeoPoint:(BmobGeoPoint *)geopoint withinKilometers:(double)maxDistance{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    if (!geopoint) {
        return;
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"GeoPoint",@"__type",[NSNumber numberWithDouble:geopoint.longitude],@"longitude",[NSNumber numberWithDouble:geopoint.latitude],@"latitude", nil];
    NSDictionary  *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:dic,@"$nearSphere",[NSNumber numberWithDouble:maxDistance ],@"$maxDistanceInKilometers",nil];
    [self.queryDic setObject:tmpDic forKey:key];
}


- (void)whereKey:(NSString *)key nearGeoPoint:(BmobGeoPoint *)geopoint withinRadians:(double)maxDistance{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    if (!geopoint) {
        return;
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"GeoPoint",@"__type",[NSNumber numberWithDouble:geopoint.longitude],@"longitude",
                         [NSNumber numberWithDouble:geopoint.latitude],@"latitude", nil];
    NSDictionary  *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:dic,@"$nearSphere",[NSNumber numberWithDouble:maxDistance],@"$maxDistanceInRadians",nil];
    [self.queryDic setObject:tmpDic forKey:key];
}

- (void)whereKey:(NSString *)key withinGeoBoxFromSouthwest:(BmobGeoPoint *)southwest toNortheast:(BmobGeoPoint *)northeast{
    
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    if (!southwest || !northeast) {
        return;
    }
    NSDictionary *southwestDic = [NSDictionary dictionaryWithObjectsAndKeys:@"GeoPoint",@"__type",[NSNumber numberWithDouble:southwest.longitude],@"longitude",[NSNumber numberWithDouble:southwest.latitude],@"latitude", nil];
    NSDictionary *northeastDic = [NSDictionary dictionaryWithObjectsAndKeys:@"GeoPoint",@"__type",[NSNumber numberWithDouble:northeast.longitude],@"longitude",[NSNumber numberWithDouble:northeast.latitude],@"latitude", nil];
    NSDictionary  *boxpDic =
    [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:southwestDic,northeastDic, nil],@"$box",nil];
    NSDictionary  *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:boxpDic, @"$within",nil];
    [self.queryDic setObject:tmpDic forKey:key];
}

#pragma mark get object
//查询单条记录
- (void)getObjectInBackgroundWithId:(NSString *)objectId
                              block:(BmobObjectResultBlock)block{
    //异常处理
    if (!objectId || [objectId isEqualToString:@""]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(nil,[BCommonUtils errorWithType:BmobErrorTypeNullObjectId]);
            }
        });
        
        return;
    }
    
    
    //构造请求post字典
    NSDictionary *postDic = [self constructSingleRecordOperatorPostDataWithObjectId:objectId];
    NSString *getOneUrl   = [[SDKAPIManager defaultAPIManager] findInterface];
    //构造网络请求实体
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:getOneUrl];
    
    [requestUtil addParameter:postDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     int code = [BResponseUtil checkResponseWithDic:dictionary withDataCountCanZero:NO];
                     switch (code) {
                         case ResponseResultOfConnectError:{
                             //将网络请求中的错误返回
                             [self executeBlock:block withBmobObject:nil andError:error];
                         }
                             break;
                             
                         case ResponseResultOfServerError:{
                             NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                             [self executeBlock:block withBmobObject:nil andError:error];
                         }
                             break;
                             
                         case ResponseResultOfRequestError:{
                             //返回相应的错误信息
                             NSError *error = [BCommonUtils errorWithResult:dictionary];
                             [self executeBlock:block withBmobObject:nil andError:error];
                         }
                             break;
                             
                         case ResponseResultOfSuccess:{
                             //正确的返回
                             NSMutableArray *resArr = [NSMutableArray array];
                             
                             [resArr addObject:[dictionary objectForKey:@"data"]];

                             BmobObject *bmob  = nil;
                             NSDictionary *dictionary = [resArr objectAtIndex:0];
                             if ([_queryClassName isEqualToString:@"_User"]) {
                                 bmob = [[BmobUser alloc] initWithDictionary:dictionary];
                             }else if([_queryClassName isEqualToString:@"_Installation"]){
                                 bmob = [[BmobInstallation alloc] initWithDictionary:dictionary];
                             }else if([_queryClassName isEqualToString:@"_Role"]){
                                 bmob = [[BmobRole alloc] initWithDictionary:dictionary];
                             }else{
                                 bmob = [[BmobObject alloc] initWithDictionary:dictionary];
                             }
                             bmob.className = self.queryClassName;
                             [self executeBlock:block withBmobObject:bmob andError:nil];
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
                     [self executeBlock:block withBmobObject:nil andError:error];
                 }];
}

-(ResponseResult)checkResponseWithDic:(NSDictionary *)responseResultDic withDataCanNull:(BOOL)isDataCanNull{
    //判断是否有返回结果
    if (!responseResultDic || [responseResultDic count] <= 0)  {
        return ResponseResultOfConnectError;
    }
    
    //判断服务器返回来的两个字典是否为空，因为有些接口的data可为空，而有些接口不可为空，当不可为空时，若服务器传回来的数据为空，则说明是服务器错误，在使用服务器新接口时先明确该接口的data是否可以为空
    NSDictionary *dataDic = [responseResultDic objectForKey:@"data"];
    NSDictionary *resultDic = [responseResultDic objectForKey:@"result"];
    if (isDataCanNull) {
        if (!dataDic || !resultDic || resultDic.count <= 0) {
            return ResponseResultOfServerError;
        }
    } else {
        if (!dataDic || dataDic.count <= 0 || !resultDic || resultDic.count <= 0) {
            return ResponseResultOfServerError;
        }
    }
    
    //判断服务器返回结果代码
    int resultCode = [[resultDic objectForKey:@"code"] intValue];
    if (resultCode == 200) {
        return ResponseResultOfSuccess;
    } else {
        return ResponseResultOfRequestError;
    }
}





/**
 *  block不为空时，执行block
 *
 *  @param block      <#block description#>
 *  @param bmobObject <#bmobObject description#>
 *  @param error      <#error description#>
 */
-(void)executeBlock:(BmobObjectResultBlock)block withBmobObject:(BmobObject*)bmobObject andError:(NSError*)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block(bmobObject,error);
        }
    });
    
}

/**
 *  构造单条数据请求查询的PostData
 *
 *  @param objectId 查询对象的ObjectId
 *
 *  @return post 字典
 */
- (NSDictionary *)constructSingleRecordOperatorPostDataWithObjectId:(NSString*)objectId{
    
    //请求数据
    NSMutableDictionary  *requestDic = [NSMutableDictionary dictionaryWithDictionary:[BRequestDataFormat requestDictionaryWithClassname:_queryClassName data:nil objectId:objectId]];
    NSString *token = [BCommonUtils sessionToken];
    if (token) {
       
        requestDic[@"sessionToken"]      = token;
    }
    
    NSMutableDictionary  *tmpDataDic = [NSMutableDictionary dictionaryWithCapacity:1];
    if ([_keysArray count] > 0) {
        NSString  *keysString = [_keysArray componentsJoinedByString:@","];
        [tmpDataDic setObject:keysString forKey:@"keys"];
    }
    
    if (self.includeKey && self.includeKey.length > 0) {
        [tmpDataDic setObject:self.includeKey forKey:@"include"];
    }
    
    if ([tmpDataDic count] != 0)  {
        [requestDic setObject:tmpDataDic forKey:@"data"];
    }
    
    return requestDic;
}

//查询多条记录
- (void)findObjectsInBackgroundWithBlock:(BmobObjectArrayResultBlock)block{
    //存储整个post请求的数据
   
    NSDictionary *dataDic = [self makeQueryCondiction];
    NSMutableDictionary  *tmpDic = [NSMutableDictionary dictionaryWithDictionary:[BRequestDataFormat requestDictionaryWithClassname:_queryClassName data:dataDic]];
    //取出本地存储sessionToken，该sessionToken用于做什么，什么时候存储的？
    NSString *token = [BCommonUtils sessionToken];
    if (token) {
        
        tmpDic[@"sessionToken"]      = token;
    }
    
    //获取本地查询的文件名
    NSString *fileName = [self selfQueryFileName];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    switch (self.cachePolicy) {
            //默认，不缓存
        case kBmobCachePolicyIgnoreCache:{
            [self objectsWithDic:tmpDic cacheFileName:fileName block:block];
        }
            break;
            //只读缓存
        case kBmobCachePolicyCacheOnly:{
            
            if ([fileManage fileExistsAtPath:fileName]) {
                if ([self isExpired]){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (block) {
                            NSError *error = [BCommonUtils errorWithType:BmobErrorTypeQueryCachedExpired];
                            //过期时返回nil
                            block(nil,error);
                        }
                    });
                    
                    
                } else{
                    [self getDataFromLocalWithBlock:block dataDic:tmpDic];
                }
            } else{
                //不存在时返回空数组
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) {
                        NSArray *resultArray = [NSArray array];
                        block(resultArray,nil);
                    }
                });
                
            }
        }
            break;
            //只读网络
        case kBmobCachePolicyNetworkOnly:{
            [self objectsWithDic:tmpDic cacheFileName:fileName block:block];
        }
            break;
            //无缓存或缓存过期，则读网络
        case kBmobCachePolicyCacheElseNetwork:{
            if ([fileManage fileExistsAtPath:fileName]) {
                if (![self isExpired]) {
                    [self getDataFromLocalWithBlock:block dataDic:tmpDic];
                } else{
                    [self objectsWithDic:tmpDic cacheFileName:fileName block:block];
                }
            } else{
                [self objectsWithDic:tmpDic cacheFileName:fileName block:block];
            }
        }
            break;
            //网络没有数据就读缓存
        case kBmobCachePolicyNetworkElseCache:{
            [self objectsWithDic:tmpDic cacheFileName:fileName block:block];
        }
            break;
            //先读缓存再读网络，回调方法会运行两次
        case kBmobCachePolicyCacheThenNetwork:{
            if ([fileManage fileExistsAtPath:fileName]) {
                if ([self isExpired]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (block) {
                            NSError *error = [BCommonUtils errorWithType:BmobErrorTypeQueryCachedExpired];
                            block(nil,error);
                        }
                    });
                    
                    
                } else{
                    [self getDataFromLocalWithBlock:block dataDic:tmpDic];
                }
            }
            [self objectsWithDic:tmpDic cacheFileName:fileName block:block];
        }
            break;
        default:
            break;
    }
}

//__deprecated_msg("Method deprecated. Use `sd_setImageWithURL:placeholderImage:`");
-(void)calcInBackgroundWithBlock:(BmobObjectArrayResultBlock)block{
    
    
    
    
    //存储data数据
    NSMutableDictionary  *tmpDataDic = [NSMutableDictionary dictionaryWithCapacity:1];
    
    //keys键值对
    if ([_keysArray count] > 0) {
        NSString  *keysString = [_keysArray componentsJoinedByString:@","];
        [tmpDataDic setObject:keysString forKey:@"keys"];
    }
    //order键值对
    if ([_orderArray count] > 0) {
        NSString  *keysString = [_orderArray componentsJoinedByString:@","];
        [tmpDataDic setObject:keysString forKey:@"order"];
    }
    
    if (self.includeKey && self.includeKey.length > 0) {
        [tmpDataDic setObject:self.includeKey forKey:@"include"];
    }
    //构造where键值对
    if ([self.queryDic count] > 0) {
        [tmpDataDic setObject:self.queryDic forKey:@"where"];
    }
    
    //skip键值对
    if (self.skip != 0) {
        [tmpDataDic setObject:[NSNumber numberWithInteger:self.skip] forKey:@"skip"];
    }
    
    //limit键值对
    if (self.limit != 0) {
        [tmpDataDic setObject:[NSNumber numberWithInteger:self.limit] forKey:@"limit"];
    }
    
    //统计相关参数
    if ([_sumArray count] > 0 ) {
        NSString *keysString = [_sumArray componentsJoinedByString:@","];
        [tmpDataDic setObject:keysString forKey:@"sum"];
    }
    
    if ([_averageArray count] > 0 ) {
        NSString *keysString = [_averageArray componentsJoinedByString:@","];
        [tmpDataDic setObject:keysString forKey:@"average"];
    }
    
    if ([_maxArray count] > 0 ) {
        NSString *keysString = [_maxArray componentsJoinedByString:@","];
        [tmpDataDic setObject:keysString forKey:@"max"];
    }
    
    if ([_minArray count] > 0 ) {
        NSString *keysString = [_minArray componentsJoinedByString:@","];
        [tmpDataDic setObject:keysString forKey:@"min"];
    }
    
    if ([_groupbyArray count] > 0 ) {
        NSString *keysString = [_groupbyArray componentsJoinedByString:@","];
        [tmpDataDic setObject:keysString forKey:@"groupby"];
    }
    
    if ([self.havingDic count] > 0 ) {
        [tmpDataDic setObject:self.havingDic forKey:@"having"];
    }
    
    if (self.isGroupcount) {
        [tmpDataDic setObject:[NSNumber numberWithBool:self.isGroupcount] forKey:@"groupcount"];
    }
    
    
    //存储整个post请求的数据
    NSMutableDictionary  *tmpDic = [NSMutableDictionary dictionaryWithDictionary:[BRequestDataFormat requestDictionaryWithClassname:_queryClassName data:tmpDataDic ]];
    //取出本地存储sessionToken，该sessionToken用于做什么，什么时候存储的？
    NSString *token = [BCommonUtils sessionToken];
    if (token) {
        
        tmpDic[@"sessionToken"]      = token;
    }
    
    //将data加入到post字典中
    if ([tmpDataDic count] != 0)  {
        [tmpDic setObject:tmpDataDic forKey:@"data"];
    }
    
    //构造请求链接
    NSString *queryUrl            = [[SDKAPIManager defaultAPIManager] findInterface];
    debugLog(@"请求链接:%@",queryUrl);
    
    //构造请求实体
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:queryUrl];
    //构造请求实体数组
    [_requestArray addObject:requestUtil];
    
    __weak typeof(BHttpClientUtil *) weakRequest = requestUtil;
    //添加post数据字典，并进行请求，命名不太恰当
    [weakRequest addParameter:tmpDic
                 successBlock:^(NSDictionary *dictionary,NSError *error) {
                     //获取一个新队列，并且往队列中添加任务
                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                         //获取请求结果
                         NSMutableDictionary *resDic = [NSMutableDictionary dictionary];
                         if (dictionary) {
                             [resDic setDictionary:dictionary];
                         }
                         
                         if (resDic && [resDic count] > 0) {
                             if ([[[resDic objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                                 if ([BCommonUtils isNotNilOrNull:[resDic objectForKey:@"data"]]) {
                                     //results返回的是一个结果，结构为单条或多条记录
                                     NSMutableArray *resArr = [NSMutableArray array];
                                     if ([[[resDic objectForKey:@"data"] objectForKey:@"results"] isKindOfClass:[NSArray class]]) {
                                         [resArr setArray:[[resDic objectForKey:@"data"] objectForKey:@"results"]];
                                         block(resArr,nil);
                                     }
                                 }else{
                                     //错误处理
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (block) {
                                             NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                             //[NSArray array]返回空数据
                                             block([NSArray array],error);
                                         }
                                     });
                                 }
                             }else{
                                 //返回发生错误的请求码
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (block) {
                                         NSError *error = [BCommonUtils errorWithResult:resDic];
                                         NSArray *resultArray = [NSArray array];
                                         block(resultArray,error);
                                     }
                                 });
                             }
                         }else{
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if (block) {
                                     //此处的error直接使用
                                     block([NSArray array],error);
                                 }
                             });
                         }
                     });
                     
                 } failBlock:^(NSError *err){
                     if (block) {
                         BmobErrorType type = BmobErrorTypeConnectFailed;
                         if (err) {
                             type = (BmobErrorType)err.code;
                         }
                         NSError * error = [BCommonUtils errorWithType:type];
                         block([NSArray array],error);
                     }
                 }];
    
    
}

/**
 *	进行网络请求，查询结果
 *
 *	@param dic 查询使用的post语句
 *
 *  @param cacheFileName 本地缓存的文件名
 *
 *	@param block 返回给用户的 block
 */
-(void)objectsWithDic:(NSDictionary*)dic cacheFileName:(NSString*)cacheFileName block:(BmobObjectArrayResultBlock)block{
    
    //构造请求链接
    NSString *queryUrl            = [[SDKAPIManager defaultAPIManager] findInterface];
    //构造请求实体
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:queryUrl];
    //
    debugLog(@"queryUrl %@",queryUrl);
    [_requestArray addObject:requestUtil];
    __weak typeof(BHttpClientUtil *) weakRequest = requestUtil;
    //添加post数据字典，并进行请求，命名不太恰当
    [weakRequest addParameter:dic
                 successBlock:^(NSDictionary *dictionary,NSError *error) {
                     //获取一个新队列，并且往队列中添加任务
                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                         //获取请求结果
                         NSMutableDictionary *resDic = [NSMutableDictionary dictionary];
                         if (dictionary) {
                             [resDic setDictionary:dictionary];
                         }
                         @try {
                             if (resDic && [resDic count] > 0) {
                                 if ([[[resDic objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                                     if ([BCommonUtils isNotNilOrNull:[resDic objectForKey:@"data"]]) {
                                         //results返回的是一个结果，结构为单条或多条记录
                                         NSMutableArray *resArr = [NSMutableArray array];
                                         if ([[resDic objectForKey:@"data"] objectForKey:@"results"] && [[[resDic objectForKey:@"data"] objectForKey:@"results"] isKindOfClass:[NSArray class]]) {
                                             [resArr setArray:[[resDic objectForKey:@"data"] objectForKey:@"results"]];
                                         }
                                         
                                         if (resArr && [resArr count] > 0) {
                                             //数组转成BmobObject数组
                                             NSMutableArray *array = [self turnArrayToBmobObjectArray:resArr];
                                             
                                             //除了默认情况，其它情况都需要将结果进行缓存，
                                             if (self.cachePolicy !=kBmobCachePolicyIgnoreCache) {
                                                 //将数据存入缓存文件
                                                 [NSKeyedArchiver archiveRootObject:[BEncryptUtil encodeBase64String:[BCommonUtils stringOfJson:resArr]] toFile:cacheFileName];
                                                 
                                                 //
                                                 NSString *plistFileName = [[BCommonUtils filePath] stringByAppendingPathComponent:[NSString stringWithFormat: @"%@.plist",@"cacheArray"]];
                                                 
                                                 
                                                 if ([[NSFileManager defaultManager] fileExistsAtPath:plistFileName]) {
                                                     NSMutableArray *cacheArray = [NSMutableArray arrayWithContentsOfFile:plistFileName];
                                                     if (![cacheArray containsObject:cacheFileName]) {
                                                         [cacheArray addObject:cacheFileName];
                                                         [cacheArray writeToFile:plistFileName atomically:YES];
                                                     }
                                                 } else{
                                                     NSMutableArray *cacheArray = [NSMutableArray arrayWithObject:cacheFileName];
                                                     [cacheArray writeToFile:plistFileName atomically:YES];
                                                 }
                                                 
                                             }
                                             //dispatch_async 函数会将传入的block块放入指定的queue里运行。这个函数是异步的，这就意味着它会立即返回而不管block是否运行结束。因此，我们可以在block里运行各种耗时的操作（如网络请求） 而同时不会阻塞UI线程。
                                             //将数据返回给用户
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 if (block) {
                                                     block(array,nil);
                                                 }
                                             });
                                             
                                         } else{
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 if (block) {
                                                     block([NSArray array],nil);
                                                 }
                                             });
                                         }
                                         
                                     }else{
                                         //服务器上返回的data结果有误，属于未知错误，一般是服务器存在bug
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (block) {
                                                 NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                                 //[NSArray array]返回空数据
                                                 block([NSArray array],error);
                                             }
                                         });
                                     }
                                 }else{
                                     //返回发生错误的请求码
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (block) {
                                             NSError *error = [BCommonUtils errorWithResult:resDic];
                                             NSArray *resultArray = [NSArray array];
                                             block(resultArray,error);
                                         }
                                     });
                                 }
                             }else{
                                 //针对服务器没有返回结果的情况给出的提示
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (block) {
                                         //此处的error直接使用
                                         block([NSArray array],error);
                                     }
                                 });
                                 
                             }
                         }
                         @catch (NSException *exception) {
                             //错误处理
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if (block) {
                                     NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                     //[NSArray array]返回空数据
                                     block([NSArray array],error);
                                 }
                             });
                         }
                         @finally {
                             
                         }
                         
                         
                         
                     });
                     
                 } failBlock:^(NSError *err){
                     //判断缓存策略，只有缓存策略为kBmobCachePolicyNetworkElseCache的情况下会读缓存
                     
                     //网络没有数组,访问缓存
                     if (self.cachePolicy == kBmobCachePolicyNetworkElseCache) {
                         NSFileManager *fileManage = [NSFileManager defaultManager];
                         if ([fileManage fileExistsAtPath:cacheFileName]) {
                             if ([self isExpired]) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (block) {
                                         NSError *error = [BCommonUtils errorWithType:BmobErrorTypeQueryCachedExpired];
                                         NSArray *resultArray = [NSArray array];
                                         block(resultArray,error);
                                     }
                                 });
                             } else{
                                 [self getDataFromLocalWithBlock:block dataDic:dic];
                             }
                         }else{
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if (block) {
                                     NSArray *resultArray = [NSArray array];
                                     block(resultArray,nil);
                                 }
                             });
                         }
                     }else{
                         if (block) {
                             BmobErrorType type = BmobErrorTypeConnectFailed;
                             if (err) {
                                 type = (BmobErrorType)err.code;
                             }
                             NSError * error = [BCommonUtils errorWithType:type];
                             block([NSArray array],error);
                         }
                     }
                     
                     
                 }];
}

-(void)countObjectsInBackgroundWithBlock:(BmobIntegerResultBlock)block{
    

    
    NSMutableDictionary  *tmpDataDic = [NSMutableDictionary dictionary];
    [tmpDataDic setDictionary:[self makeQueryCondiction]];
    [tmpDataDic setObject:[NSNumber numberWithBool:YES] forKey:@"count"];

    NSMutableDictionary  *tmpDic = [NSMutableDictionary dictionaryWithDictionary:[BRequestDataFormat requestDictionaryWithClassname:_queryClassName data:tmpDataDic ]];
    NSString *token = [BCommonUtils sessionToken];
    
    if (token) {
        
        tmpDic[@"sessionToken"]      = token;
    }
    
    NSString *countUrl       = [[SDKAPIManager defaultAPIManager] findInterface];
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:countUrl];
    
    [requestUtil addParameter:tmpDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     NSDictionary *countDic = dictionary;
                     if (countDic && [countDic count] > 0) {
                         if ([[[countDic objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                             
                             if ([BCommonUtils isNotNilOrNull:[countDic objectForKey:@"data"]]) {
                                 if (block) {
                                     int count = [[[countDic objectForKey:@"data"] objectForKey:@"count"] intValue];
                                     block(count,nil);
                                 }
                             }else{
                                 if (block) {
                                     NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                     block(-1,error);
                                 }
                             }
                         } else{
                             if (block) {
                                 NSError *error = [BCommonUtils errorWithResult:countDic];
                                 block(-1,error);
                             }
                         }
                     } else{
                         if (block) {
                             block(-1,error);
                         }
                     }
                 } failBlock:^(NSError *err){
                     if (block) {
                         BmobErrorType type = BmobErrorTypeConnectFailed;
                         if (err) {
                             type = (BmobErrorType)err.code;
                         }
                         NSError * error = [BCommonUtils errorWithType:type];
                         block(-1,error);
                     }
                 }];
    
}

- (void)queryInBackgroundWithBQL:(NSString *)bql block:(BmobBQLObjectResultBlock)block{
    [self queryInBackgroundWithBQL:bql pvalues:nil block:block];
    
}

- (void)queryInBackgroundWithBQL:(NSString *)bql  pvalues:(NSArray*)pvalues block:(BmobBQLObjectResultBlock)block{
    
    if (!bql || [bql isEqualToString:@""]) {
        return;
    }
    
    
    
    //构造data
    NSMutableDictionary  *tmpDataDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [tmpDataDic setObject:bql forKey:@"bql"];
    if (pvalues) {
        [tmpDataDic setObject:pvalues forKey:@"values"];
    }
    
    NSMutableDictionary  *tmpDic = [NSMutableDictionary dictionaryWithDictionary:[BRequestDataFormat requestDictionaryWithData:tmpDataDic]];
    //这种构造最好放一块，否则容易搞错
    NSString *token = [BCommonUtils sessionToken];
    if (token) {
        
        tmpDic[@"sessionToken"]      = token;
    }
    
    debugLog(@"%@",tmpDic);
    
    //设置一个方法
    NSString *bqlUrl       = [[SDKAPIManager defaultAPIManager] cloudQueryInterface];
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:bqlUrl];
    
    [requestUtil addParameter:tmpDic successBlock:^(NSDictionary *dictionary, NSError *error) {
        NSDictionary *bqlDic = dictionary;
        debugLog(@"bqlDic:%@",bqlDic);
        debugLog(@"error:%@",error);
        if (bqlDic && [bqlDic count] > 0) {
            //未知错误
            if ([[[bqlDic objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                //输入的参数有误
                if ([BCommonUtils isNotNilOrNull:[bqlDic objectForKey:@"data"]]) {
                    //服务器
                    NSDictionary *dataDic = [bqlDic objectForKey:@"data"];
                    if (dataDic && [dataDic count] > 0) {
                        //判断返回来的数据是否
                        debugLog(@"服务器返回来的数据：%@",dataDic);
                        
                        BQLQueryResult *bqlQueryResult = [self tranDicToBQLQueryResult:dataDic];
                        if (block) {
                            block(bqlQueryResult,nil);
                        }
                    } else {
                        if (block) {
                            block(nil,nil);
                        }
                    }
                } else {
                    if (block) {
                        NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                        block(nil,error);
                    }
                }
            } else {
                if (block) {
                    NSError *error = [BCommonUtils errorWithResult:bqlDic];
                    block(nil,error);
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

- (void)queryWithBQLConnectServerWithDic:(NSDictionary*)dic cacheFileName:(NSString*)cacheFileName block:(BmobBQLObjectResultBlock)block{
    
    //设置一个方法
    NSString *bqlUrl       = [[SDKAPIManager defaultAPIManager] cloudQueryInterface];
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:bqlUrl];
    
    [requestUtil addParameter:dic successBlock:^(NSDictionary *dictionary, NSError *error) {
        NSDictionary *bqlDic = dictionary;
        debugLog(@"bqlDic:%@",bqlDic);
        debugLog(@"error:%@",error);
        if (bqlDic && [bqlDic count] > 0) {
            //未知错误
            if ([[[bqlDic objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                //输入的参数有误
                if ([BCommonUtils isNotNilOrNull:[bqlDic objectForKey:@"data"]]) {
                    //服务器
                    NSDictionary *dataDic = [bqlDic objectForKey:@"data"];
                    if (dataDic && [dataDic count] > 0) {
                        //判断返回来的数据是否
                        debugLog(@"服务器返回来的数据：%@",dataDic);
                        
                        BQLQueryResult *bqlQueryResult = [self tranDicToBQLQueryResult:dataDic];
                        
                        //此处存储存的是整个data数据
                        if (self.cachePolicy !=kBmobCachePolicyIgnoreCache) {
                            //将数据存入缓存文件
                            [NSKeyedArchiver archiveRootObject:[BEncryptUtil encodeBase64String:[BCommonUtils stringOfJson:dataDic]] toFile:cacheFileName];
                            
                            //将文件名写入plist文件中
                            NSString *plistFileName = [[BCommonUtils filePath] stringByAppendingPathComponent:[NSString stringWithFormat: @"%@.plist",@"cacheArray"]];
                            
                            
                            if ([[NSFileManager defaultManager] fileExistsAtPath:plistFileName]) {
                                NSMutableArray *cacheArray = [NSMutableArray arrayWithContentsOfFile:plistFileName];
                                if (![cacheArray containsObject:cacheFileName]) {
                                    [cacheArray addObject:cacheFileName];
                                    [cacheArray writeToFile:plistFileName atomically:YES];
                                }
                            } else{
                                NSMutableArray *cacheArray = [NSMutableArray arrayWithObject:cacheFileName];
                                [cacheArray writeToFile:plistFileName atomically:YES];
                            }
                        }
                        if (block) {
                            block(bqlQueryResult,nil);
                        }
                    } else {
                        if (block) {
                            block(nil,nil);
                        }
                    }
                } else {
                    if (block) {
                        NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                        block(nil,error);
                    }
                }
            } else {
                if (block) {
                    NSError *error = [BCommonUtils errorWithResult:bqlDic];
                    block(nil,error);
                }
            }
        }
    } failBlock:^(NSError *err){
        //网络没有数组,访问缓存
        if (self.cachePolicy == kBmobCachePolicyNetworkElseCache) {
            NSFileManager *fileManage = [NSFileManager defaultManager];
            if ([fileManage fileExistsAtPath:cacheFileName]) {
                if ([self isBQLCacheFileExpiredWithDic:dic]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (block) {
                            NSError *error = [BCommonUtils errorWithType:BmobErrorTypeQueryCachedExpired];
                            block(nil,error);
                        }
                    });
                } else{
                    [self getBQLDataFromLocalWithBlock:block dataDic:dic];
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) {
                        block(nil,nil);
                    }
                });
            }
        }else{
            if (block) {
                BmobErrorType type = BmobErrorTypeConnectFailed;
                if (err) {
                    type = (BmobErrorType)err.code;
                }
                NSError * error = [BCommonUtils errorWithType:type];
                block(nil,error);
            }
        }
        
        
    }];
    
}

- (void)queryBQLCanCacheInBackgroundWithblock:(BmobBQLObjectResultBlock)block{
    if (!_bqlString || [_bqlString isEqualToString:@""]) {
        return;
    }
    
    //构造data
    NSMutableDictionary  *tmpDataDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [tmpDataDic setObject:_bqlString forKey:@"bql"];
    if (_placeholderArray) {
        [tmpDataDic setObject:_placeholderArray forKey:@"values"];
    }
    
    NSMutableDictionary  *tmpDic = [NSMutableDictionary dictionaryWithDictionary:[BRequestDataFormat requestDictionaryWithData:tmpDataDic]];
    //这种构造最好放一块，否则容易搞错
    NSString *token = [BCommonUtils sessionToken];
    if (token) {
        tmpDic[@"sessionToken"]      = token;
    }
    
    debugLog(@"%@",tmpDic);
    //获取本地查询的文件名
    NSString *fileName = [self getBQLCacheFileNameWithDic:tmpDataDic];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    switch (self.cachePolicy) {
            //默认，不缓存
        case kBmobCachePolicyIgnoreCache:{
            [self queryWithBQLConnectServerWithDic:tmpDic cacheFileName:fileName block:block];
        }
            break;
            //只读缓存
        case kBmobCachePolicyCacheOnly:{
            //判断缓存是否还在
            if ([fileManage fileExistsAtPath:fileName]) {
                //判断缓存是否过期
                if ([self isBQLCacheFileExpiredWithDic:tmpDataDic]){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (block) {
                            NSError *error = [BCommonUtils errorWithType:BmobErrorTypeQueryCachedExpired];
                            block(nil,error);
                        }
                    });
                    
                } else{
                    [self getBQLDataFromLocalWithBlock:block dataDic:tmpDataDic];
                }
            } else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) {
                        //缓存不存在时返回空对象
                        block(nil,nil);
                    }
                });
                
            }
        }
            break;
            //只读网络,但会缓存数据
        case kBmobCachePolicyNetworkOnly:{
            [self queryWithBQLConnectServerWithDic:tmpDic cacheFileName:fileName block:block];
        }
            break;
            //缓存没有数据，就读网络
        case kBmobCachePolicyCacheElseNetwork:{
            if ([fileManage fileExistsAtPath:fileName]) {
                if (![self isBQLCacheFileExpiredWithDic:tmpDataDic]) {
                    [self getBQLDataFromLocalWithBlock:block dataDic:tmpDic];
                } else{
                    [self queryWithBQLConnectServerWithDic:tmpDic cacheFileName:fileName block:block];
                }
            } else{
                [self queryWithBQLConnectServerWithDic:tmpDic cacheFileName:fileName block:block];
            }
        }
            break;
            //网络没有数据就读缓存
        case kBmobCachePolicyNetworkElseCache:{
            [self queryWithBQLConnectServerWithDic:tmpDic cacheFileName:fileName block:block];
        }
            break;
            //缓存后再读网络
        case kBmobCachePolicyCacheThenNetwork:{
            if ([fileManage fileExistsAtPath:fileName]) {
                if ([self isExpired]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (block) {
                            NSError *error = [BCommonUtils errorWithType:BmobErrorTypeQueryCachedExpired];
                            block(nil,error);
                        }
                        
                    });
                    
                } else{
                    [self getBQLDataFromLocalWithBlock:block dataDic:tmpDic];
                }
            }
            [self queryWithBQLConnectServerWithDic:tmpDic cacheFileName:fileName block:block];
        }
            break;
        default:
            break;
    }
}

-(BQLQueryResult*) tranDicToBQLQueryResult:(NSDictionary*)dataDic{
    //转换字典为BQLQueryResult对象
    NSString *className = [dataDic objectForKey:@"c"];
    NSArray *bmobObjectDicAry = [dataDic objectForKey:@"results"];
    
    
    NSArray *bmobObjectAry = [[NSArray alloc] init];
    if (bmobObjectDicAry) {
        bmobObjectAry = [[self class] turnArrayToBmobObjectArray:bmobObjectDicAry withClassName:className];
    }
    
    NSNumber *count = [dataDic objectForKey:@"count"];
    int iCount = -1;
    if (count) {
        iCount = [count intValue];
    }
    
    BQLQueryResult *bqlQueryResult = [[BQLQueryResult alloc] init];
    bqlQueryResult.className = className;
    bqlQueryResult.resultsAry = bmobObjectAry;
    bqlQueryResult.count = iCount;
    return bqlQueryResult;
}



- (void)statisticsInBackgroundWithBQL:(NSString *)bql block:(BmobBQLArrayResultBlock)block{
    
    [self statisticsInBackgroundWithBQL:bql pvalues:nil block:block];
    
}

- (void)statisticsInBackgroundWithBQL:(NSString *)bql pvalues:(NSArray*)pvalues block:(BmobBQLArrayResultBlock)block{
    
    if (!bql || [bql isEqualToString:@""]) {
        return;
    }
    
    //构造data
    NSMutableDictionary  *tmpDataDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [tmpDataDic setObject:bql forKey:@"bql"];
    if (pvalues && [pvalues count] > 0) {
        [tmpDataDic setObject:pvalues forKey:@"values"];
    }
    
    NSMutableDictionary  *tmpDic = [NSMutableDictionary dictionaryWithDictionary:[BRequestDataFormat requestDictionaryWithData:tmpDataDic]];
    //这种构造最好放一块，否则容易搞错
    NSString *token = [BCommonUtils sessionToken];
    if (token) {
        tmpDic[@"sessionToken"]      = token;
    }
    
    NSString *bqlUrl       = [[SDKAPIManager defaultAPIManager] cloudQueryInterface];
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:bqlUrl];
    debugLog(@"%@",tmpDic);
    [requestUtil addParameter:tmpDic successBlock:^(NSDictionary *dictionary, NSError *error) {
        NSDictionary *bqlDic = dictionary;
        debugLog(@"bqlDic:%@",bqlDic);
        debugLog(@"error:%@",error);
        if (bqlDic && [bqlDic count] > 0) {
            if ([[[bqlDic objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                if ([BCommonUtils isNotNilOrNull:[bqlDic objectForKey:@"data"]]) {
                    if (block) {
                        NSDictionary *dataDic = [bqlDic objectForKey:@"data"];
                        NSMutableArray *resArr = [NSMutableArray array];
                        if ([[dataDic objectForKey:@"results"] isKindOfClass:[NSArray class]]) {
                            [resArr setArray:[dataDic objectForKey:@"results"]];
                            block(resArr,nil);
                        }
                    }
                } else {
                    if (block) {
                        NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                        block(nil,error);
                    }
                }
            } else {
                if (block) {
                    NSError *error = [BCommonUtils errorWithResult:bqlDic];
                    block(nil,error);
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

-(void)cancel{
    for (BHttpClientUtil *reuqest in _requestArray) {
        [reuqest cancel];
    }
}

# pragma mark BQL查询方法
-(void)setBQL:(NSString*)bql{
    if (!bql || [bql isEqualToString:@""]) {
        return;
    }
    [_bqlString setString:bql];
}

-(void)setPlaceholder:(NSArray*)ary{
    if (!ary || ary.count <= 0) {
        return;
    }
    [_placeholderArray setArray:ary];
}

/**
 *  返回缓存查询结果文件名
 *
 *  @return <#return value description#>
 */
-(NSString*)selfQueryFileName{
    
    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
    [tmpDic setDictionary:[self makeQueryCondiction]];
    //把查询条件更改key为是data
    [tmpDic removeObjectForKey:@"where"];
    tmpDic[@"data"] = self.queryDic;
    tmpDic[@"c"]    = self.queryClassName;

    NSString *fileName = [[BCommonUtils filePath] stringByAppendingPathComponent:[NSString stringWithFormat: @"%@.archive",[BEncryptUtil md5WithString:[BCommonUtils stringOfJson:tmpDic]]]];
    
    return fileName;
}

/**
 *  返回bql缓存查询文件名
 *
 *  @param dic 跟服务器交互的data
 *
 *  @return <#return value description#>
 */
-(NSString*)getBQLCacheFileNameWithDic:(NSDictionary *)dic{
    NSString *fileName = [[BCommonUtils filePath] stringByAppendingPathComponent:[NSString stringWithFormat: @"%@.archive",[BEncryptUtil md5WithString:[BCommonUtils stringOfJson:dic]]]];
    return fileName;
}

/**
 *  判断BQL查询缓存是否过期
 *
 *  @param dataDic 查询中post数组中的data数据
 */
-(BOOL)isBQLCacheFileExpiredWithDic:(NSDictionary*)dataDic{
    //取得文件属性
    NSDictionary *attrDic = [[NSFileManager defaultManager] attributesOfItemAtPath:[self getBQLCacheFileNameWithDic:dataDic] error:nil];
    //返回当前时间
    NSDate *nowDate       = [NSDate date];
    return   [nowDate timeIntervalSinceDate:[attrDic objectForKey:NSFileModificationDate]] > self.maxCacheAge ? YES:NO;
}


/**
 *  将返回的数组转成BmobObject数组
 *
 *  @param array 数组
 *
 *  @return BmobObject数组
 */
-(NSMutableArray*)turnArrayToBmobObjectArray:(NSArray*)array{
    NSMutableArray *tmpArray = [[self class] turnArrayToBmobObjectArray:array withClassName:self.queryClassName];
    return tmpArray;
}


/**
 *  将服务器返回的数组转成BmobObject数组
 *
 *  @param array 数组
 *  @param className 表名
 *
 *  @return BmobObject数组
 */
+(NSMutableArray*)turnArrayToBmobObjectArray:(NSArray*)array withClassName:(NSString*)className{
    int type = 0;
    if ([className isEqualToString:@"_User"]) {
        type = 1;
    }else if([className isEqualToString:@"_Installation"]){
        type = 2;
    }else if([className isEqualToString:@"_Role"]){
        type = 3;
    }else{
        type = 0;
    }
    
    NSMutableArray *tmpArray = [NSMutableArray array];
    for (int i= 0; i < [array count]; i++) {
        if ([[array objectAtIndex:i] isKindOfClass:[NSDictionary class]] ) {
            NSDictionary *dic = [array objectAtIndex:i];
            switch (type) {
                    //普通表
                case 0:{
                    BmobObject *obj  = [[BmobObject alloc] initWithDictionary:dic];
                    obj.className = className;
                    [tmpArray addObject:obj];
                }
                    break;
                    //用户表
                case 1:{
                    BmobUser *obj  = [[BmobUser alloc] initWithDictionary:dic];
                    obj.className = className;
                    [tmpArray addObject:obj];
                }
                    break;
                //设备表
                case 2:{
                    BmobInstallation *obj  = [[BmobInstallation alloc] initWithDictionary:dic];
                    obj.className = className;
                    [tmpArray addObject:obj];
                }
                    break;
                //角色表
                case 3:{
                    BmobRole *obj  = [[BmobRole alloc] initWithDictionary:dic];
                    obj.className = className;
                    [tmpArray addObject:obj];
                }
                    break;
                
                default:
                    break;
            }
        }
    }
    return tmpArray;
}



//是否过期
-(BOOL)isExpired{

    //取得文件属性
    NSDictionary *attrDic = [[NSFileManager defaultManager] attributesOfItemAtPath:[self selfQueryFileName] error:nil];
    //返回当前时间
    NSDate *nowDate       = [NSDate date];
    //计算当前时间与文件修改日期时间之差，并与macCacheAge对比来文件判断是否过期
    NSTimeInterval different = [nowDate timeIntervalSinceDate:[attrDic objectForKey:NSFileModificationDate]];

    return   different > self.maxCacheAge ? YES:NO;
}


/**
 *  获取本地缓存查询数据
 *
 *  @param block 返回查询结果的回调方法
 *  @param dic   网络查询时的post数据，用于本地查询不存在时需要从网络查询的情况
 */
-(void)getDataFromLocalWithBlock:(BmobObjectArrayResultBlock)block dataDic:(NSDictionary*)dic {

    NSString *dataString = [BEncryptUtil decodeBase64String:[NSKeyedUnarchiver unarchiveObjectWithFile:[self selfQueryFileName]] ];
    
    NSData  *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *array =  [NSMutableArray arrayWithArray: [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil] ];
    NSMutableArray *bmobObjectArray = [self turnArrayToBmobObjectArray:array];
    if ([bmobObjectArray count] !=0) {
        if (block) {
            block(bmobObjectArray,nil);
        }
        
    }else{
        if (self.cachePolicy == kBmobCachePolicyCacheElseNetwork) {
            [self objectsWithDic:dic cacheFileName:[self selfQueryFileName] block:block];
        }else{
            if (block) {
                NSArray *resultArray = [NSArray array];
                block(resultArray,nil);
            }
            
        }
    }
}

/**
 *  获取本地缓存查询数据
 *
 *  @param block 返回查询结果的回调方法
 *  @param dic   网络查询时的post数据，用于本地查询不存在时需要从网络查询的情况
 */
-(void)getBQLDataFromLocalWithBlock:(BmobBQLObjectResultBlock)block dataDic:(NSDictionary*)dic {
    NSString *fileName = [self getBQLCacheFileNameWithDic:dic];
    NSString *dataString = [BEncryptUtil decodeBase64String:[NSKeyedUnarchiver unarchiveObjectWithFile:fileName]];
    
    NSData  *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *queryResultDic = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil]];
    
    if ([queryResultDic count] > 0) {
        BQLQueryResult *bqlQueryResult = [self tranDicToBQLQueryResult:queryResultDic];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(bqlQueryResult,nil);
            }
        });
        
        
    }else{
        if (self.cachePolicy == kBmobCachePolicyCacheElseNetwork) {
            [self queryWithBQLConnectServerWithDic:dic cacheFileName:[self getBQLCacheFileNameWithDic:dic] block:block];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(nil,nil);
                }
            });
            
            
        }
    }
}

#pragma mark - 构造查询条件
-(NSDictionary *)makeQueryCondiction{
    //存储data数据
    NSMutableDictionary *condictionDic = [NSMutableDictionary dictionary];
    //keys键值对
    if ([_keysArray count] > 0) {
        NSString  *keysString = [_keysArray componentsJoinedByString:@","];
        [condictionDic setObject:keysString forKey:@"keys"];
    }
    //order键值对
    if ([_orderArray count] > 0) {
        NSString  *keysString = [_orderArray componentsJoinedByString:@","];
        [condictionDic setObject:keysString forKey:@"order"];
    }
    
    if (self.includeKey && self.includeKey.length > 0) {
        [condictionDic setObject:self.includeKey forKey:@"include"];
    }
    //构造where键值对
    if ([self.queryDic count] > 0) {
        [condictionDic setObject:self.queryDic forKey:@"where"];
    }
    
    //skip键值对
    if (self.skip != 0) {
        [condictionDic setObject:[NSNumber numberWithInteger:self.skip] forKey:@"skip"];
    }
    
    //limit键值对
    if (self.limit != 0) {
        [condictionDic setObject:[NSNumber numberWithInteger:self.limit] forKey:@"limit"];
    }

    return condictionDic;
}

#pragma mark -- cache method
/**
 *  检查当前查询是否存在
 *
 *  @return 当前查询条件存在时返回YES，否则返回NO
 */
-(BOOL)hasCachedResult{
    NSString *cacheResultFilePath = [self cachedResultFilePath];
    return [[NSFileManager defaultManager] fileExistsAtPath:cacheResultFilePath];
}

/**
 *  如果当前查询条件的查询结果存在则清除该查询结果
 */
-(void)clearCachedResult{
    if ([self hasCachedResult]) {
         NSString *cacheResultFilePath = [self cachedResultFilePath];
        [[NSFileManager defaultManager] removeItemAtPath:cacheResultFilePath error:nil];
    }
}

/**
 *  得到当前查询其缓存结果文件所有的位置
 *
 *  @return 缓存文件路径
 */
- (NSString*)cachedResultFilePath{
    NSString *cacheResultFilePath;
    if (_bqlString && ![_bqlString isEqualToString:@""]) {
        //构造data
        NSMutableDictionary  *tmpDataDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [tmpDataDic setObject:_bqlString forKey:@"bql"];
        if (_placeholderArray) {
            [tmpDataDic setObject:_placeholderArray forKey:@"values"];
        }
        cacheResultFilePath = [self getBQLCacheFileNameWithDic:tmpDataDic];
    } else {
        cacheResultFilePath = [self selfQueryFileName];
    }
    return cacheResultFilePath;
}

/**
 *  清除所有缓存结果
 */
+(void)clearAllCachedResults{
    //记录缓存的文件
    NSString *plistFileName = [[BCommonUtils filePath] stringByAppendingPathComponent:[NSString stringWithFormat: @"%@.plist",@"cacheArray"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistFileName]) {
        NSMutableArray *cacheArray = [NSMutableArray arrayWithContentsOfFile:plistFileName];
        if ([cacheArray count] != 0) {
            for (int i = 0; i < [cacheArray count]; i++) {
                NSString *fileName = [cacheArray objectAtIndex:i];
                [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
            }
        }
        [[NSFileManager defaultManager] removeItemAtPath:plistFileName error:nil];
    }
}

#pragma mark
- (void)storeCacheWithCacheFileName:(NSString*)cacheFileName AndCacheData:(NSDictionary*)dataDic{
    //将数据存入缓存文件
    [NSKeyedArchiver archiveRootObject:[BEncryptUtil encodeBase64String:[BCommonUtils stringOfJson:dataDic]] toFile:cacheFileName];
    
    //在应用的documents目录下创建一个文件，filePath方法表示documents的路径，该方法需要修改名字
    NSString *plistFileName = [[BCommonUtils filePath] stringByAppendingPathComponent:[NSString stringWithFormat: @"%@.plist",@"cacheArray"]];
    
    //将缓存文件存入cacheArry.plist文件，修改命名为cacheFileNameArray.plist会更好一些
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistFileName]) {
        
        NSMutableArray *cacheArray = [NSMutableArray arrayWithContentsOfFile:plistFileName];
        if (![cacheArray containsObject:cacheFileName]) {
            [cacheArray addObject:cacheFileName];
            [cacheArray writeToFile:plistFileName atomically:YES];
        }
    } else{
        NSMutableArray *cacheArray = [NSMutableArray arrayWithObject:cacheFileName];
        [cacheArray writeToFile:plistFileName atomically:YES];
    }
}

#pragma mark delloc
-(void)dealloc{
    _queryObjectId  = nil;
    _queryClassName = nil;
    _queryDic       = nil;
    _requestArray   = nil;
    _orderArray     = nil;
    _keysArray      = nil;
    
}

@end
