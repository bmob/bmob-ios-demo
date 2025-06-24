//
//  BHttpClientUtil.m
//  BmobSDK
//
//  Created by Bmob on 16/2/19.
//  Copyright © 2016年 bmob. All rights reserved.
//

#import "BHttpClientUtil.h"

#import "BCommonUtils.h"
#import "BmobManager.h"

#import "BmobReachability.h"
#import "Bmob.h"
#import "BEncryptUtil.h"


@interface BHttpClientUtil ()

@property (assign, nonatomic) BOOL                isSecertUrl;
@property (assign, nonatomic) BOOL                isInitUrl;
@property (strong, nonatomic) NSMutableURLRequest *mutableURLRequest;
@property (strong, nonatomic) NSMutableString     *myUrlString;
@property (strong, nonatomic) BHttpClient         *httpClient;

@property (strong, nonatomic) dispatch_queue_t    networkQueue;

@end


@implementation BHttpClientUtil

-(instancetype)initWithUrl:(NSString *)url{
    self = [super init];
    if (self) {
        
        if (url) {
            [self.myUrlString setString:url];
        }
        self.isInitUrl = [self isUrl:1];
        self.isSecertUrl = [self isUrl:0];

        _mutableURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [_mutableURLRequest setHTTPMethod:@"POST"];
        
        [_mutableURLRequest addValue:@"gzip,deflate,sdch" forHTTPHeaderField:@"Accept-Encoding"];
        [_mutableURLRequest addValue:@"text/html;charset=utf-8" forHTTPHeaderField:@"Content-type"];
        
        NSString *timeStramp = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
        NSString *user_agent = [NSString stringWithFormat:@"%@%@%@",timeStramp,@"iOS",kBmobSDKVersion];
        [_mutableURLRequest addValue:user_agent forHTTPHeaderField:@"User-Agent"];
        
        self.networkQueue = dispatch_queue_create("cn.bmob.network", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}



-(NSMutableString *)myUrlString{
    if (!_myUrlString) {
        _myUrlString = [[NSMutableString alloc] init];
    }
    return _myUrlString;
}

-(BHttpClient *)httpClient{
    if (!_httpClient) {
        _httpClient = [[BHttpClient alloc] init];
    }
    return _httpClient;
}

/**
 *  是否是初始化接口跟secret
 *
 *  @param type 0 密钥 1 初始化
 *
 *  @return 是否是
 */
-(BOOL)isUrl:(int)type{
    NSString *urlString    = self.myUrlString;
    NSString *secretString = @"";
    switch (type) {
        case 0:{
            secretString = @"/secret";
        }
            break;
        case 1:{
            secretString = @"/init";
        }
            break;
        default:
            break;
    }
    
    const int secretLength = (int)secretString.length;
    if ([urlString rangeOfString:secretString].location != NSNotFound) {
        
        NSString *lastString = [urlString substringWithRange:NSMakeRange(urlString.length-secretLength, secretLength)];
        if ([lastString isEqualToString:secretString]) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}



+(instancetype)requestUtilWithUrl:(NSString *)url{
    
    
    BHttpClientUtil *util = [[BHttpClientUtil alloc] initWithUrl:url];
    
    return util;
}

#pragma mark - encode and decode
/**
 *  加密参数
 *
 *  @param dic 参数
 *
 *  @return 加密后的内容
 */
-(NSData *)eParameter:(NSDictionary *)dic{
    NSMutableDictionary *requestDic  = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    requestDic[@"appSign"]           = [BEncryptUtil aS];
    
    //普通请求获取时间戳
    if (!_isSecertUrl && !_isInitUrl) {
        NSTimeInterval clientTime        = [[NSDate date] timeIntervalSince1970];
        BmobManager *manager             = [BmobManager defaultManager];
        int serveTime                    = manager.time + (int)clientTime;
        requestDic[@"timestamp"]         = [NSNumber numberWithInt:serveTime];
        
    }

    //获得请求头参数
    NSDictionary *reqHttpHeaderField = [self.mutableURLRequest allHTTPHeaderFields];
//    debugLog(@"http头:%@",reqHttpHeaderField);
//    debugLog(@"post data:%@",requestDic);

    
    NSData *postData                 = nil;
    
    //加密json数据，即需要post数据
    NSData *jsonData                 = [NSJSONSerialization dataWithJSONObject:requestDic options:NSJSONWritingPrettyPrinted error:nil];
    if (_isSecertUrl) {
        NSString *useragent   = [reqHttpHeaderField objectForKey:@"User-Agent"];
        NSData *useragentData = [useragent dataUsingEncoding:NSUTF8StringEncoding];
        //User-Agent取最后16位作为Key1，来加密请求内容data
        NSData *kData         = [useragentData subdataWithRange:NSMakeRange(useragentData.length-16, 16)];
        postData              = [[BEncryptUtil aEncryptedData:jsonData keyData:kData ivData:kData] base64EncodedDataWithOptions:0];

    }else{
        //构造Accept-ID，除获取secret key外的其它请求都要传这个值
        NSString *appKey      = [BEncryptUtil decodeBase64String:[[NSString alloc] initWithData:[BmobManager defaultManager].apid encoding:NSUTF8StringEncoding]];
        
        NSData *aKData        = [appKey dataUsingEncoding:NSUTF8StringEncoding];
        NSString *useragent   = [reqHttpHeaderField objectForKey:@"User-Agent"];
        NSData *useragentData = [useragent dataUsingEncoding:NSUTF8StringEncoding];
        //从User-Agent的第2位开始取16位长度作为请求头的appKey的加密Key
        NSData *k3Data        = [useragentData subdataWithRange:NSMakeRange(1, 16)];
        
        [self.mutableURLRequest addValue:[BEncryptUtil encodeBase64Data:[BEncryptUtil aEncryptedData:aKData keyData:k3Data ivData:k3Data]] forHTTPHeaderField:@"Accept-Id"];
        //读取secret key
        NSData *kAD           = [BmobManager defaultManager].sk;
        //对请求进行加密
        postData              = [[BEncryptUtil aEncryptedData:jsonData keyData:kAD ivData:kAD] base64EncodedDataWithOptions:0];
        //[BmobBase64 encodeData:];
    }
    
    return postData;
}

/**
 *  解密返回的结果
 *
 *  @param data 加密的数据
 *
 *  @return 解密后的数据
 */
-(NSData *)decData:(NSData *)data{
    
    
    NSData *decData = [NSData data];
    if (_isSecertUrl) {
        //如果是获取secret key请求，则使用key2解密，Http响应Headers中的response-id: <时间戳><服务端版本> 取最后16位作为Key2，解密得到字符串的secretKey
        NSDictionary *headerDictionary = [[self.httpClient httpResponse] allHeaderFields];
        NSString *rid                  = [headerDictionary[@"Response-Id"] description];
        static int keyLength           = 16;
        if (rid && rid.length > keyLength) {
            NSData *ridData = [rid dataUsingEncoding:NSUTF8StringEncoding];
            NSData  *key2Data = [ridData subdataWithRange:NSMakeRange(ridData.length-keyLength, keyLength)];
            if (data && data.length > 0) {
                //解密
                NSData *decodeData = [[NSData alloc] initWithBase64EncodedData:data options:0];
                decData            = [BEncryptUtil aDecryptedData:decodeData keyData:key2Data ivData:key2Data];
            }
        }
    }else{
        //其它请求则使用secret key作为来进行解密
        if (data && data.length > 0) {
            NSData *kAD        = [BmobManager defaultManager].sk;
            if (kAD) {
                //解码
                NSData *decodeData = [[NSData alloc] initWithBase64EncodedData:data options:0];
                //解密
                decData            = [BEncryptUtil aDecryptedData:decodeData keyData:kAD ivData:kAD];
            } else {
                //没有secret key的情况下，用key3来解析错误信息
                decData = [self decDataWithKey3:data];
            }
            
        }
    }
    
    return decData;
    
}

/**
 *  用于解密获取secret key失败时再试图调用其它接口时解析错误，但在客户端已经做了处理，无secret key 时不允许调用其它接口，因此该方法暂时未用
 *
 *  @param data 加密的数据
 *
 *  @return 解密后的数据
 */
-(NSData *)decDataWithKey3:(NSData *)data{
    
    NSData *decData = [NSData data];
    NSDictionary *headerDictionary = [[self.httpClient httpResponse] allHeaderFields];
    NSString *rid                  = [headerDictionary[@"Response-Id"] description];
    static int keyLength           = 16;
    if (rid && rid.length > keyLength) {
        NSData *ridData = [rid dataUsingEncoding:NSUTF8StringEncoding];
        NSData  *key3Data = [ridData subdataWithRange:NSMakeRange(1, keyLength)];
        if (data && data.length > 0) {
            //解密
            NSData *decodeData = [[NSData alloc] initWithBase64EncodedData:data options:0];
//            [BmobBase64 decodeData:data];
            decData            = [BEncryptUtil aDecryptedData:decodeData keyData:key3Data ivData:key3Data];
        }
    }
    
    
    return decData;
    
}

#pragma mark - request

-(void)setHttpMethod:(NSString *)method{
    [self.mutableURLRequest setHTTPMethod:method];
}

/**
 *  进行网络请求
 *
 *  @param dic     <#dic description#>
 *  @param success <#success description#>
 *  @param fail    <#fail description#>
 */
-(void)addParameter:(NSDictionary *)dic
       successBlock:(BRequestSuccessBlock)success
          failBlock:(BRequestFailBlock)fail{
    
    
    //检测网络状态，苹果提供的网络状态检测方法
    NetworkStatus state = [BmobReachability reachabilityForInternetConnection].currentReachabilityStatus;
    //网络不通的时候
    if (state == NotReachable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (fail) {
                fail(nil);
            }
        });
        return;
    }
    
    BmobManager *manager    = [BmobManager defaultManager];
    
    //创建请求
    BRequestObject *requestObj = [BRequestObject requestObject];
    requestObj.para = dic;
    
    if (success) {
        requestObj.success = success;
    }
    if (fail) {
        requestObj.fail = fail;
    }
    if (_myUrlString) {
        requestObj.url = _myUrlString;
    }
    requestObj.rid = (manager.requestId ++);
    requestObj.state = BRequestObjectStateInit;
    
    //如果是secretKey跟初始化接口，直接处理
    if (_isSecertUrl || _isInitUrl) {
        [self requestWithPara:requestObj];
    }else{
        
        //初始化未成功或者 sk为空
        if (!manager.initFinished || !manager.sk || manager.sk.length == 0) {
            //        if(!manager.initFinished){
            
            //初始化未成功，则进行初始化
            if (!manager.isIniting && !manager.isSecrecting) {
                [Bmob activateSDK];
            }
            
            //注册过程是异步的，在没有获取secret key或者init未完成时，其它的请求保存起来，等初始化完成后再去执行，即将注册过程变成同步
            [manager.requestArray addObject:requestObj];
        }else{
            //初始化成功，并且sk不为空，执行除获取secretKey或者初始化外的其它请求
            [self requestWithPara:requestObj];
        }
    }
    
}

/**
 *  判断完网络请求类型后进行网络请求
 *
 *  @param request       请求对象
 *  @param completeBlock 没有用处，原意是用来处理注册期间的其它请求的，现已经在通知处完成了这些请求，重构时可删除
 */
-(void)requestWithPara:(BRequestObject *)request{
    
    dispatch_async(self.networkQueue, ^{
        //请求的post data
        NSDictionary *dic            = request.para;
        BRequestSuccessBlock success = request.success;
        BRequestFailBlock fail       = request.fail;
        
        //此处为请求连接
        NSData *postData = [self eParameter:dic];
        [self.mutableURLRequest setHTTPBody:postData];
        [self.httpClient timeoutIntervalForRequest:[BmobManager defaultManager].timeout];
        [self.httpClient timeoutIntervalForResource:[BmobManager defaultManager].timeout];

        __weak typeof(BHttpClient *)weakClient = self.httpClient;
        //连接后的回调
        [weakClient uploadRequest:self.mutableURLRequest
                          success:^(NSURLResponse *response, id responseData) {
                              NSData *decData = [self decData:responseData];
                              NSError *error = nil;
                              //有数据从服务器返回
                              if (decData && decData.length > 0) {
                                  NSDictionary *tmpDic = [NSJSONSerialization JSONObjectWithData:decData options:NSJSONReadingMutableContainers error:&error];
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      if (success) {
                                          success(tmpDic,error);
                                      }
                                  });
                              }else{
                                  //无数据从服务器返回
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      if (success) {
                                          success([NSDictionary dictionary],error);
                                      }
                                  });
                              }
                              self.httpClient = nil;
                          } failure:^(NSError *error) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  if (fail) {
                                      fail(error);
                                  }
                              });
                             
                          } progress:^(int64_t completedBytesCount, int64_t totalBytesCount) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  if (self.progressBlock) {
                                      self.progressBlock(completedBytesCount/(totalBytesCount * 1.0f));
                                  }
                              });
                          }];
    });

}





-(void)cancel{
    if (self.httpClient) {
        [self.httpClient cancel];
    }
}


-(void)dealloc{
    
}



@end
