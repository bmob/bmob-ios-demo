//
//  BmobAK.m
//  BmobSDK
//
//  Created by Bmob on 15-1-7.
//  Copyright (c) 2015年 Bmob. All rights reserved.
//

#import "BmobManager.h"
#import "BHttpClientUtil.h"
#import "BCommonUtils.h"
#import "Bmob.h"
#import "SDKAPIManager.h"


@interface BmobManager ()

@end

@implementation BmobManager
@synthesize sk    = _sk;
@synthesize count = _count;
@synthesize time  = _time;
@synthesize initFinished = _initFinished;
@synthesize requestArray = _requestArray;
@synthesize requestId = _requestId;
@synthesize isSecrecting = _isSecrecting; //表示是否正在请求getscrect接口
@synthesize isIniting = _isIniting;


static BmobManager  *manager = NULL;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _count = 0;
        _time  = 0;
        _initFinished = NO;
        _requestArray = [[NSMutableArray alloc] init];
        
    }
    return self;
}

+(instancetype)defaultManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealUndoneRequest) name:@"kBmob_Init_Success_All_Notice_Notification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneRequestWhileInitFailed) name:kBmobInitFailNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneRequestWhenGetScrectFailed:) name:@"kBmobGetSecretFailNotification" object:nil];
    });
    
    return manager;
}

/**
 *  初始化成功后处理请求
 */
+(void)dealUndoneRequest{
    BmobManager *manager          = [[self class] defaultManager];
    
    if (!manager.requestArray || manager.requestArray.count == 0) {
        return;
    }
    SDKAPIManager *apiManager = [SDKAPIManager defaultAPIManager];
    NSArray *copyRequest = [manager.requestArray copy];
    for (int i = 0;i < copyRequest.count ;i ++) {
        BRequestObject *obj                         = copyRequest[i];
        if (obj.state == BRequestObjectStateInit) {
            NSString *stringUrl   = obj.url;
            NSString *key         = [[stringUrl componentsSeparatedByString:@"/"] lastObject];
            NSString *url         = nil;

            if ([stringUrl rangeOfString:[apiManager defaultServerDomain]].location != NSNotFound ) {
                url = [apiManager interfaceWithKey:key];
            }else{
                url = obj.url;
            }
            BHttpClientUtil *util = [[BHttpClientUtil alloc] initWithUrl:url];
            obj.state             = BRequestObjectStateDoing;
            [manager.requestArray replaceObjectAtIndex:i withObject:obj];
            [util requestWithPara:obj];
        }
    }
    [manager.requestArray removeAllObjects];
}

/**
 *  初始化失败后给出提示
 */
+(void)doneRequestWhileInitFailed{
   
    dispatch_async(dispatch_get_main_queue(), ^{
            BmobManager *manager          = [[self class] defaultManager];
            NSArray *copyRequest = [manager.requestArray copy];
            for (int i = 0;i < copyRequest.count ;i ++) {
                BRequestObject *obj            = copyRequest[i];
                BRequestFailBlock fail = obj.fail;
                
                if (fail) {
                    fail(nil);
                }
            }
            
            [manager.requestArray removeAllObjects];
    });

}

/**
 *  处理getscrectkey 获取失败后，给出提示
 *
 *  @param noti <#noti description#>
 */
+(void)doneRequestWhenGetScrectFailed:(NSNotification *)noti{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *errorInfo = noti.userInfo;
        BmobManager *manager          = [[self class] defaultManager];
        NSArray *copyRequest = [manager.requestArray copy];
        for (int i = 0;i < copyRequest.count ;i ++) {
            BRequestObject *obj            = copyRequest[i];
            BRequestSuccessBlock success = obj.success;
            if (success) {
                NSDictionary *resultDic = @{@"result": errorInfo,
                                            @"data":[NSDictionary dictionary]};
                success(resultDic,nil);
            }
        }
        [manager.requestArray removeAllObjects];
    });
    
    
}

@end
