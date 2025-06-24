//
//  BmobFile.m
//  BmobSDK
//
//  Created by Bmob on 13-9-10.
//  Copyright (c) 2013年 Bmob. All rights reserved.
//

#import "BmobFile.h"
#import "BCommonUtils.h"
#import "BHttpClientUtil.h"
#import "BmobManager.h"
#import "BmobUpYun.h"
#import "SDKHostUtil.h"
#import "BRequestDataFormat.h"
#import "BEncryptUtil.h"
#import "BmobManager.h"
#import "CDNModel.h"
#import "SDKAPIManager.h"

//#import "UpYunFormUploader.h"
//#import "UpYunBlockUpLoader.h"
//#import "UpYunFileDealManger.h"

@interface BmobFile(){
    NSString         *_className;
    NSString         *_fileName; //用户上传时输入的文件名
    NSMutableData    *_fileData;
    int              choseId;   //0 路径 1 二进制
}

@property (assign, nonatomic) NSInteger      uploadRetryCount;
@property (assign, nonatomic) NSUInteger     haveUploadLength;
@property (strong, nonatomic) BmobUpYun *uy ;
@property (strong, nonatomic) CDNModel *upyunCDN;

/**
 *  保存的路径
 */
@property (copy, nonatomic  ) NSString       *path;
@end

@implementation BmobFile

//此处的name是上传文件后服务器返回的filename
@synthesize url=_url,name=_name,group=_group;

//@synthesize uploadRetryCount = _uploadRetryCount;
@synthesize haveUploadLength = _haveUploadLength;


static NSString *kUPYun = @"upyun";
//static NSUInteger kUPYUNExpirationTime = 1;//60 * 30;



-(id)initWithFileName:(NSString*)fileName
                  url:(NSString*)url
                group:(NSString*)group{
    self = [super init];
    if (self) {
        _name = fileName;
        _url = url;
        _group = group;
    }
    return self;
}

-(id)initWithClassName:(NSString*)className withFilePath:(NSString*)filePath{
    self = [super init];
    if (self ) {
        _className        = [className copy];
        _fileData         = [[NSMutableData alloc] init];
        _uploadRetryCount = 0;
        _haveUploadLength = 0;
        choseId           = 0;
        _fileName         = [filePath copy];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSData  *data = [[NSData alloc] initWithContentsOfFile:_fileName];
            if (data) {
                [_fileData setData:data];
            }
        }else{
            _fileName = nil;
        }
        _name = [[filePath lastPathComponent] copy];
    }
    
    return self;
    
}



-(id)initWithClassName:(NSString *)className
          withFileName:(NSString *)fileName
          withFileData:(NSData *)data {
    self = [super init];
    if (self) {
        _fileData         = [[NSMutableData alloc] init];
        if (data) {
            [_fileData setData:data];
        }
        _className        = [className copy];
        _fileName         = [fileName copy];
        _name             = [fileName copy];
        choseId           = 1;
        _uploadRetryCount = 0;
        _haveUploadLength = 0;
    }
    return self;
    
}

-(CDNModel *)upyunCDN{
    if (!_upyunCDN) {
        _upyunCDN = [[CDNModel alloc] init];
    }
    
    return _upyunCDN;
}



-(id)initWithFilePath:(NSString*)filePath{
    
    return [self initWithClassName:@"FILE" withFilePath:filePath];
}

-(id)initWithFileName:(NSString*)fileName  withFileData:(NSData*)data{
    
    return [self initWithClassName:@"FILE" withFileName:fileName withFileData:data];
}


-(void)dealloc{
    
    _name = nil;
    _url = nil;
    _group = nil;
    _fileData = nil;
    _fileName = nil;
    
}

-(NSString *)url{
    return [BCommonUtils urlEncodeWithInput: _url];
}


#pragma mark - save



-(void)saveInBackground:(BmobBooleanResultBlock)block{
    //没有文件名
    if (!_fileName || [_fileName isEqualToString:@""]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullFilename];
                block(NO,error);
            }
        });
        
        //文件内容为空
    }else if ([_fileData length] == 0){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullFileData];
                block(NO,error);
            }
        });
        
        //文件大小超出限制
    }else {
        [self saveInBackground:block
                      withData:_fileData
                  withFileName:[_fileName lastPathComponent]
             withProgressBlock:nil
             needProgressBlock:NO];
    }
    
}




-(void)saveInBackground:(BmobBooleanResultBlock)block
               withData:(NSData*)data
           withFileName:(NSString*)fileName
      withProgressBlock:(BmobProgressBlock)progressBlock
      needProgressBlock:(BOOL)needProgressBlock{
    
    if (![BmobManager defaultManager].initFinished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeInitNotFinish];
                block(NO,error);
            }
            if (progressBlock) {
                progressBlock(0.0f);
            }
        });
        
        return;
    }
    
    if ([_fileName rangeOfString:@"."].location == NSNotFound) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullFilename];
                block(NO,error);
            }
            if (progressBlock) {
                progressBlock(0.0f);
            }
        });
        
        return;
    }
    
    
    //如果本地没有版本或者本地的版本小于服务器的版本，则先调用cdn接口获取数据
    if (![SDKHostUtil upyunVersion] || [[SDKHostUtil upyunVersion] intValue] < [BmobManager defaultManager].upyunVersion || ![SDKHostUtil upyunName] || [SDKHostUtil upyunName].length == 0) {
        [self cdnHostAndUploadFileWithFilename:fileName
                                          data:data
                                    completion:block
                                      progress:progressBlock];
    }else{
    
        self.upyunCDN.domin = [SDKHostUtil upyunHost];
        self.upyunCDN.key = [SDKHostUtil upyunKey];
        self.upyunCDN.name = [SDKHostUtil upyunName];
        
        [self uploadFileWithFilename:fileName
                                data:data
                          completion:block
                            progress:progressBlock];
    }
}

-(void)cdnHostAndUploadFileWithFilename:(NSString *)filename
                                   data:(NSData *)data
                             completion:(BmobBooleanResultBlock)block
                               progress:(BmobProgressBlock)progressBlock{
    
    NSDictionary  *requestDic       = [BRequestDataFormat requestDictionaryWithData:nil ];
    NSString *url                   = [[SDKAPIManager defaultAPIManager] cdnInterface];
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:url];
    //    __weak __typeof(self)weakSelf   = self;
    [requestUtil addParameter:requestDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     if (block) {
                         debugLog(@"cdn %@",dictionary);
                         if (dictionary && dictionary.count > 0) {
                             //获取cdn
                             NSDictionary *resultDic = [dictionary objectForKey:@"result"];
                             if (resultDic && [resultDic[@"code"] intValue] == 200) {
                                 
                                 NSDictionary *dataDic = dictionary[@"data"][@"cdn"][kUPYun];
                                 self.upyunCDN.domin   = dataDic[@"domain"];
                                 self.upyunCDN.key     = dataDic[@"secret"];
                                 self.upyunCDN.name    = dataDic[@"name"];
                                 
                                 //保存在本地,域名，密钥，版本
                                 [SDKHostUtil saveUPYunKey:self.upyunCDN.key];
                                 [SDKHostUtil saveUPYunHost:self.upyunCDN.domin];
                                 
                                   [SDKHostUtil saveUPYunName:self.upyunCDN.name];
                                 
                                 [SDKHostUtil saveUPYunVersion:[NSString stringWithFormat:@"%d",[BmobManager defaultManager].upyunVersion]];
                                 
                                 [SDKHostUtil syncHosts];
                                                                  
                                 [self uploadFileWithFilename:filename
                                                         data:data
                                                   completion:block
                                                     progress:progressBlock];
                             }else {
                                 if (block) {
                                     NSError *error = [BCommonUtils errorWithResult:dictionary];
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


/**
 * 调用又拍云接口上传文件
 */

-(void)uploadFileWithFilename:(NSString *)filename
                         data:(NSData *)data
                   completion:(BmobBooleanResultBlock)block
                     progress:(BmobProgressBlock)progressBlock {
    
    [BmobUPYUNConfig sharedInstance].DEFAULT_BUCKET = self.upyunCDN.name;//@"test654123";
    [BmobUPYUNConfig sharedInstance].DEFAULT_PASSCODE = self.upyunCDN.key;//@"0/8/1gPFWUQWGcfjFn6Vsn3VWDc=";
    
    
    _uy = [[BmobUpYun alloc] init];
    self.uy.uploadMethod = UPMutUPload;
    
    
    NSString *saveKey = [[BCommonUtils uuid] stringByReplacingOccurrencesOfString:@"-" withString:@""].lowercaseString;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierISO8601];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSString *director = [dateFormatter stringFromDate:[NSDate date]];
    NSString *path = [NSString stringWithFormat:@"/%@/%@.%@",director,saveKey,[_fileName pathExtension]];
    
    
//    NSString *operatorName = @"one";
//    UpYunFormUploader *up  = [[UpYunFormUploader alloc]init];
//    [up uploadWithOperator:operatorName policy:@"22" signature:@"11" fileData:data fileName:filename success:^(NSHTTPURLResponse *response, NSDictionary *responseBody) {
//
//    } failure:^(NSError *error, NSHTTPURLResponse *response, NSDictionary *responseBody) {
//
//    } progress:^(int64_t completedBytesCount, int64_t totalBytesCount) {
//
//    }];
    
    __weak typeof(BmobUpYun *)weakUY = self.uy;
    
    //    __weak typeof(self)weakSelf = self;
    
    weakUY.successBlocker = ^(NSURLResponse *response, id responseData) {
        
        self.group = @"";
        self.path = path;
        
        
        if ([self.upyunCDN.domin rangeOfString:@"http"].location != NSNotFound) {
            self.url = [self.upyunCDN.domin stringByAppendingPathComponent:self.path];
        }else{
            self.url = [NSString stringWithFormat:@"http://%@",[self.upyunCDN.domin stringByAppendingPathComponent:self.path]] ;
        }
        
        [self saveUPYunCDNFileToServerWithBlock:block];
        self.uy = nil;
    };
    self.uy.failBlocker = ^(NSError * error) {
        NSString *message = [error.userInfo objectForKey:@"message"];
        
        if ([message rangeOfString:@"返回值不正确,将进行本地计算"].location == NSNotFound) {
            NSError *error1 = nil;
            error1 = [NSError errorWithDomain:error.domain code:error.code userInfo:@{NSLocalizedDescriptionKey:message}];
            
            if (block) {
                block(NO,error1);
            }
        }else {
            if(block)
                block(NO, error);
        }
        
        
    };
    self.uy.progressBlocker = ^(CGFloat percent, int64_t requestDidSendBytes) {
        if (progressBlock) {
            progressBlock(percent);
        }
    };
    
    [self.uy uploadFile:_fileData saveKey:path];
    
    
}



-(void)saveInBackgroundByDataSharding:(BmobBooleanResultBlock)block{
    
    
    if (!_fileName || [_fileName isEqualToString:@""]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullFilename];
                block(NO,error);
            }
        });
        
        
        //文件内容为空
    }else if ([_fileData length] == 0){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullFileData];
                block(NO,error);
            }
        });
        
    }
    
    else {
        [self saveInBackground:block];
    }
    
    
}

-(void)saveInBackgroundByDataSharding:(BmobBooleanResultBlock)block progressBlock:(BmobProgressBlock)progressBlock{
    if (!_fileName || [_fileName isEqualToString:@""]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullFilename];
                block(NO,error);
            }
            
        });
        
        //文件内容为空
    }else if ([_fileData length] == 0){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullFileData];
                block(NO,error);
            }
        });
        //文件大小超出限制
    }
    
    else {
        [self saveInBackground:block withProgressBlock:progressBlock];
    }
}


/**
 * 保存cdn上传的文件信息
 */
-(void)saveUPYunCDNFileToServerWithBlock:(BmobBooleanResultBlock)block{
    
    NSDictionary *dataDic = @{@"filename":[_fileName lastPathComponent],@"url":self.path,@"filesize":@(_fileData.length),@"cdn":kUPYun};
    
    NSDictionary  *requestDic    = [BRequestDataFormat requestDictionaryWithClassname:nil data:dataDic];
    NSString *url                = [[SDKAPIManager defaultAPIManager] saveCdnUploadInterface];
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:url];
    [requestUtil addParameter:requestDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     
                     
                     if (dictionary && dictionary.count > 0) {
                         NSDictionary *resultDic = [dictionary objectForKey:@"result"];
                         if (resultDic && [resultDic[@"code"] intValue] == 200) {
                             self.uploadRetryCount = 0;
                             if (block) {
                                 block(YES,nil);
                             }
                         }else {
                             ++self.uploadRetryCount;
                             if (self.uploadRetryCount < 3) {
                                 [self saveUPYunCDNFileToServerWithBlock:block];
                             }else{
                                 if (block) {
                                     self.url = nil;
                                     NSError *error = [BCommonUtils errorWithResult:dictionary];
                                     block(NO,error);
                                 }
                             }
                         }
                     }else {
                         ++self.uploadRetryCount;
                         if (self.uploadRetryCount < 3) {
                             [self saveUPYunCDNFileToServerWithBlock:block];
                         }else{
                             if (block) {
                                 NSError *error = [BCommonUtils errorWithType:BmobErrorTypeConnectFailed];
                                 block(NO,error);
                             }
                         }
                     }
                     
                 }
                    failBlock:^(NSError *err){
                        ++self.uploadRetryCount;
                        if (self.uploadRetryCount < 3) {
                            [self saveUPYunCDNFileToServerWithBlock:block];
                        }else{
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

+(void)filesUploadBatchWithPaths:(NSArray *)pathArray
                   progressBlock:(BmobFileBatchProgressBlock)progress
                     resultBlock:(BmobFileBatchResultBlock)block{
    
    if (!pathArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) {
                progress(0,0.0f);
            }
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullFilename];
                block(nil,NO,error);
            }
        });
        
    }else{
        
        NSMutableArray *fileArray = [NSMutableArray array];
        
        [[self class] uploadFilesWithPaths:pathArray
                                     index:0
                               resultBlock:block
                                  progress:progress
                                 fileArray:fileArray];
        
        // Create the dispatch group
        //        dispatch_group_t serviceGroup = dispatch_group_create();
        //
        //        for (int i = 0; i < pathArray.count; ++ i)  {
        //            NSString *path = pathArray[i];
        //           dispatch_group_enter(serviceGroup);
        //            BmobFile *tmpFile = [[[self class] alloc] initWithFilePath:path];
        //            __weak typeof(BmobFile *)weakFile = tmpFile;
        //            [tmpFile saveInBackground:^(BOOL isSuccessful, NSError *error) {
        //
        //                if (isSuccessful) {
        //                    [fileArray addObject:weakFile];
        //                    dispatch_group_leave(serviceGroup);
        //                }else{
        //                    if (block) {
        //                        block(fileArray,NO,error);
        //                    }
        //                }
        //            } withProgressBlock:^(CGFloat pro) {
        //                if (progress) {
        //                    progress(i,pro);
        //                }
        //            }];
        //        }
        //
        //        dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^{
        //            if (block) {
        //                block(fileArray,YES,nil);
        //            }
        //        });
    }
    
    
}


+(void)uploadFilesWithPaths:(NSArray *)array
                      index:(int)index
                resultBlock:(BmobFileBatchResultBlock)block
                   progress:(BmobFileBatchProgressBlock)progressBlock
                  fileArray:(NSMutableArray *)fileArray{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (!array[index]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullFilename];
                    block(nil,NO,error);
                }
            });
            
        }else{
            BmobFile *tmpFile = [[[self class] alloc] initWithFilePath:array[index]];
            __weak typeof(BmobFile *)weakFile = tmpFile;
            [tmpFile saveInBackgroundByDataSharding:^(BOOL isSuccessful, NSError *error) {
                if (isSuccessful) {
                    int next = index +1;
                    __strong typeof(BmobFile *)strongFile = weakFile;
                    BmobFile *file = [[BmobFile alloc] init];
                    file.url = strongFile.url;
                    file.name = strongFile.name;
                    
                    [fileArray addObject:file];
                    if (next < array.count) {
                        [[self class] uploadFilesWithPaths:array
                                                     index:next
                                               resultBlock:block
                                                  progress:progressBlock
                                                 fileArray:fileArray];
                    }else{
                        if (block) {
                            block(fileArray,YES,nil);
                        }
                    }
                }else{
                    
                    if (block) {
                        block(fileArray,NO,error);
                    }
                    
                    
                }
            } progressBlock:^(CGFloat progress) {
                if (progressBlock) {
                    progressBlock(index,progress);
                }
                
            }];
            //            tmpFile = nil;
        }
    });
    
    
}

+(void)filesUploadBatchWithDataArray:(NSArray *)dataArray
                       progressBlock:(BmobFileBatchProgressBlock)progress
                         resultBlock:(BmobFileBatchResultBlock)block{
    if (!dataArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) {
                progress(0,0.0f);
            }
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullFilename];
                block(nil,NO,error);
            }
        });
        
    }else{
        
        for (int i= 0; i < dataArray.count ;i ++) {
            if (![[dataArray objectAtIndex:i] isKindOfClass:[NSDictionary class]] || ![[[dataArray objectAtIndex:i] objectForKey:@"filename"] isKindOfClass:[NSString class]] || ![[[dataArray objectAtIndex:i] objectForKey:@"data"] isKindOfClass:[NSData class]]) {
                //失败就返回
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError *error = [BCommonUtils errorWithType:BmobErrorTypeErrorFormat];
                    if (block) {
                        block([NSArray array],NO,error);
                    }
                    if (progress) {
                        progress(0,0.0f);
                    }
                });
                
                return;
            }
        }
        
        for (NSDictionary *dic in dataArray) {
            if (![[dic allKeys] containsObject:@"filename"] || ![[dic allKeys] containsObject:@"data"]) {
                //失败就返回
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError *error = [BCommonUtils errorWithType:BmobErrorTypeErrorFormat];
                    if (block) {
                        block([NSArray array],NO,error);
                    }
                    if (progress) {
                        progress(0,0.0f);
                    }
                });
                
                return;
            }
        }
        
        NSMutableArray *fileArray = [NSMutableArray array];
        
        [[self class] uploadFilesWithDatas:dataArray
                                     index:0
                               resultBlock:block
                                  progress:progress
                                 fileArray:fileArray];
    }
}

+(void)uploadFilesWithDatas:(NSArray *)array
                      index:(int)index
                resultBlock:(BmobFileBatchResultBlock)block
                   progress:(BmobFileBatchProgressBlock)progressBlock
                  fileArray:(NSMutableArray *)fileArray{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (!array[index]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (progressBlock) {
                    progressBlock(index,0.0f);
                }
                if (block) {
                    NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullFilename];
                    block(nil,NO,error);
                }
            });
            
        }else{
            NSDictionary *dic  = array[index];
            NSString *fileName = dic[@"filename"];
            NSData *data       = dic[@"data"];
            BmobFile *tmpFile  = [[[self class] alloc] initWithFileName:fileName withFileData:data];
            
            __weak typeof(BmobFile *)weakFile = tmpFile;
            
            
            [tmpFile saveInBackgroundByDataSharding:^(BOOL isSuccessful, NSError *error) {
                if (isSuccessful) {
                    int next = index +1;
                    
                    __strong typeof(BmobFile *)strongFile = weakFile;
                    
                    BmobFile *file = [[BmobFile alloc] init];
                    file.url = strongFile.url;
                    file.name = strongFile.name;
                    [fileArray addObject:file];
                    if (next < array.count) {
                        [[self class] uploadFilesWithDatas:array
                                                     index:next
                                               resultBlock:block
                                                  progress:progressBlock
                                                 fileArray:fileArray];
                    }else{
                        
                        if (block) {
                            block(fileArray,YES,nil);
                        }
                    }
                    
                    
                }else{
                    if (block) {
                        block(fileArray,NO,error);
                    }
                }
            } progressBlock:^(CGFloat progress) {
                if (progressBlock) {
                    progressBlock(index,progress);
                }
            }];
            
        }
        
        
    });
}

# pragma mark upyun接口方法

-(void)saveInBackground:(BmobBooleanResultBlock)block withProgressBlock:(BmobProgressBlock)progressBlock{
    
    //没有文件名
    if (!_fileName || [_fileName isEqualToString:@""]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullFilename];
                block(NO,error);
            }
            if (progressBlock) {
                progressBlock(0.0f);
            }
        });
        
        //文件内容为空
    }else if ([_fileData length] == 0){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullFileData];
                block(NO,error);
            }
            if (progressBlock) {
                progressBlock(0.0f);
            }
        });
        
    }else {
        [self saveInBackground:block
                      withData:_fileData
                  withFileName:[_fileName lastPathComponent]
             withProgressBlock:progressBlock
             needProgressBlock:YES];
    }
    
    
    
    
}


#pragma mark - cancel delete

-(void)cancel{
    //    [Bmob cancelAllOperations];
    [self.uy cancel];
}


-(void)deleteInBackground{
    if (_url ) {
        [self deleteInBackground:nil ];
    }
}

-(void)deleteInBackground:(BmobBooleanResultBlock)block{
    
    if (!_url ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullFileUrl];
                block(NO,error);
            }
        });
        
    }else{
        NSString *url = [[self class] removePrefixWithUPYunUrl:self.url];
        [self deleteUPYunFileWithUrl:url completion:block];
    }
    
}



/**
 *  删除又拍云上的文件
 */
-(void)deleteUPYunFileWithUrl:(NSString *)url
                   completion:(BmobBooleanResultBlock)block{
    NSDictionary  *tmpDataDic = [NSDictionary dictionaryWithObjectsAndKeys:url,@"filename" ,kUPYun,@"cdn",nil];
    NSDictionary  *requestDic = [BRequestDataFormat requestDictionaryWithClassname:nil data:tmpDataDic ];
    NSString *deleteUrl       = [[SDKAPIManager defaultAPIManager] delCdnFileInterface];
    
    
    debugLog(@"para %@",requestDic.description);
    
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:deleteUrl];
    __weak typeof(BHttpClientUtil*) weakRequest = requestUtil;
    [weakRequest addParameter:requestDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     NSDictionary    *deleteDic =dictionary;
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


/**
 *  批量删除又拍云上的文件
 *
 *  @param urls  url数组
 *  @param block <#block description#>
 */
+(void)filesDeleteBatchWithArray:(NSArray <NSString *>*)urls
                     resultBlock:(BmobFilesDeleteBlock)block{
    if (!urls || urls.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullArray];
                block(urls,NO,error);
            }
        });
        return;
    }
    NSMutableArray *fileUrls = [NSMutableArray arrayWithCapacity:urls.count];
    [urls enumerateObjectsUsingBlock:^(NSString *  url, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *shortUrl = [self removePrefixWithUPYunUrl:url];
        if (shortUrl) {
            [fileUrls addObject:shortUrl];
        }
        
    }];
    
    if (fileUrls.count != 0) {
        NSDictionary  *tmpDataDic    = @{@"upyun":fileUrls};
        NSDictionary  *requestDic    = [BRequestDataFormat requestDictionaryWithClassname:nil data:tmpDataDic];
        NSString *deleteUrl          = [[SDKAPIManager defaultAPIManager] delCdnBatchInterface];
        BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:deleteUrl];
        [requestUtil addParameter:requestDic
                     successBlock:^(NSDictionary *dictionary, NSError *error) {
                         
                         
                         if (dictionary && dictionary.count > 0) {
                             //删除成功
                             if (dictionary[@"result"] && [dictionary[@"result"][@"code"] intValue] == 200) {
                                 if (block) {
                                     block([NSArray array],YES,nil);
                                 }
                             }else {
                                 if (block) {
                                     NSString *domin           = [SDKHostUtil upyunHost];
                                     NSError *error            = [BCommonUtils errorWithResult:dictionary];
                                     NSArray *array            = dictionary[@"data"][@"upyun"];
                                     NSMutableArray *failArray = [NSMutableArray array];
                                     [array enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                         NSString *url = [NSString stringWithFormat:@"https://%@%@",domin,obj];
                                         [failArray addObject:url];
                                     }];
                                     
                                     block(failArray,NO,error);
                                 }
                             }
                         }else {
                             if (block) {
                                 NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                 block(fileUrls,NO,error);
                             }
                         }
                     } failBlock:^(NSError *err){
                         if (block) {
                             BmobErrorType type = BmobErrorTypeConnectFailed;
                             if (err) {
                                 type = (BmobErrorType)err.code;
                             }
                             NSError * error = [BCommonUtils errorWithType:type];
                             block(fileUrls,NO,error);
                         }
                     }];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullArray];
                block(fileUrls,NO,error);
            }
        });
        
    }
    
    
}


#pragma mark - private method

+(BmobFile*)initFromDic:(NSDictionary*)dic{
    if (!dic) {
        return nil;
    }
    
    NSString *filename    = dic[@"filename"];
    NSString *group       = dic[@"group"];
    NSString *fileurl     = dic[@"url"];
    NSString *fileoldhost = dic[@"fileoldhost"];
    
    BmobFile *file = [[[self class] alloc] initWithFileName:filename url:[NSString stringWithFormat:@"%@%@",fileoldhost,fileurl] group:group];
    return file;
    
}

-(NSString *)description{
    NSMutableString *bmobFileDescription = [[NSMutableString alloc] initWithCapacity:1];
    
    NSString *fileName = [NSString stringWithFormat:@"\nfileName:%@;\n",self.name];
    NSString *url = [NSString stringWithFormat:@"url:%@;\n",self.url];
    NSString *group = [NSString stringWithFormat:@"group:%@;\n",self.group];
    
    [bmobFileDescription appendString:fileName];
    [bmobFileDescription appendString:url];
    [bmobFileDescription appendString:group];
    return bmobFileDescription;
}


+(NSString *)removePrefixWithUPYunUrl:(NSString *)url{
    NSString *string = nil;
    if (url) {
        if ([url rangeOfString:@"https://"].location != NSNotFound ) {
            
            NSString *cdndomin = [SDKHostUtil upyunHost];
            
            if (cdndomin.length == 0) {
                NSArray *array = [url componentsSeparatedByString:@"/"];
                if (array.count > 3) {
                    string = [url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"https://%@",array[2]] withString:@""];
                }
            }else{
                string = [url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"https://%@",cdndomin] withString:@""];
            }
        }else{
            string = url;
        }
    }
    
    return string;
}
@end
