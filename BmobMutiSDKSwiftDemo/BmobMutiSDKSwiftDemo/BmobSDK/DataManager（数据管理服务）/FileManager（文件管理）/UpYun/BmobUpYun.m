//
//  UpYun.m
//  UpYunSDK
//
//  Created by jack zhou on 13-8-6.
//  Copyright (c) 2013年 upyun. All rights reserved.
//

#import "BmobUpYun.h"
#import "BmobUPMultipartBody.h"
#import "NSString+BmobNSHash.h"
#import "BmobUPMutUploaderManager.h"

#define ERROR_DOMAIN @"UpYun.m"

#define SUB_SAVE_KEY_FILENAME @"{filename}"


@interface BmobUpYun ()

@property (nonatomic, strong) NSMutableDictionary *extParams;
@property (nonatomic, strong) BmobUPHTTPClient *client;
@property (strong, nonatomic) BmobUPMutUploaderManager *manager;

@property (nonatomic, strong) NSString *fileName;
@end

@implementation BmobUpYun

- (instancetype)init {
    if (self = [super init]) {
        self.bucket = [BmobUPYUNConfig sharedInstance].DEFAULT_BUCKET;
        self.expiresIn = [BmobUPYUNConfig sharedInstance].DEFAULT_EXPIRES_IN;
        self.passcode = [BmobUPYUNConfig sharedInstance].DEFAULT_PASSCODE;
        self.mutUploadSize = [BmobUPYUNConfig sharedInstance].DEFAULT_MUTUPLOAD_SIZE;
        self.retryTimes = [BmobUPYUNConfig sharedInstance].DEFAULT_RETRY_TIMES;
        self.uploadMethod = UPFormUpload;
        self.params = [NSMutableDictionary new];
        self.extParams = [NSMutableDictionary new];
    }
    return self;
}

- (void)uploadImage:(UIImage *)image savekey:(NSString *)savekey {
    NSData *imageData = UIImagePNGRepresentation(image);
    [self uploadImageData:imageData savekey:savekey];
}

- (void)uploadImagePath:(NSString *)path savekey:(NSString *)savekey {
    [self uploadFilePath:path savekey:savekey];
}

- (void)uploadImageData:(NSData *)data savekey:(NSString *)savekey {
    [self uploadFileData:data savekey:savekey];
}

- (void)uploadFilePath:(NSString *)path savekey:(NSString *)savekey {
    if (![self checkFilePath:path]) {
        return;
    }
    [self uploadSavekey:savekey data:nil filePath:path];
}

- (void)uploadFileData:(NSData *)data savekey:(NSString *)savekey {
    if (![self checkSavekey:savekey]) {
        return;
    }
    if (![self checkFileData:data]) {
        return;
    }
    [self uploadSavekey:savekey data:data filePath:nil];
}

- (void)uploadSavekey:(NSString *)savekey data:(NSData*)data filePath:(NSString*)filePath {
    
//    unsigned long long fileSize = data.length;
//    if (filePath) {
//        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
//
//        fileSize = [fileDictionary fileSize];
//    }
    
    switch (_uploadMethod) {
//        case UPFileSizeUpload:
//            if (fileSize > self.mutUploadSize) {
//                [self mutUploadWithFileData:data FilePath:filePath SaveKey:savekey RetryTimes:_retryTimes];
//            } else {
//                [self formUploadWithFileData:data FilePath:filePath SaveKey:savekey RetryTimes:_retryTimes];
//            }
//            break;
        case UPFormUpload:
            [self formUploadWithFileData:data FilePath:filePath SaveKey:savekey RetryTimes:_retryTimes];
            break;
        case UPMutUPload:
            
            [self mutUploadWithFileData:data FilePath:filePath SaveKey:savekey RetryTimes:_retryTimes];
            break;
    }
}

#ifdef __IPHONE_9_1

- (void)uploadLivePhoto:(PHLivePhoto *)livePhotoAsset saveKey:(NSString *)saveKey  {
    [self uploadLivePhoto:livePhotoAsset saveKey:saveKey extParams:nil];
}

- (void)uploadLivePhoto:(PHLivePhoto *)livePhotoAsset saveKey:(NSString *)saveKey extParams:(NSDictionary *)extParams {
    
    if (![self extractLivePhoto:livePhotoAsset]) {
        return;
    };
    
    UPSuccessBlock tmpSuccessBlocker = [self.successBlocker copy];
    UPFailBlock tmpFailBlocker = [self.failBlocker copy];
    UPProgressBlock tmpProgressBlocker = [self.progressBlocker copy];
    
    __block NSError *writeError = nil;
    __block NSMutableArray *responseArray = [NSMutableArray array];
    _successBlocker = ^(NSURLResponse *response, id responseData) {
        
        [responseArray addObject:responseData];
        if (tmpSuccessBlocker && (responseArray.count > 1)) {
            tmpSuccessBlocker(response, responseArray);
            [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:PATH_PHOTO_FILE error:nil];
        }
    };
    
    _failBlocker = ^(NSError * error) {
        if (tmpFailBlocker && !writeError) {
            tmpFailBlocker(error);
        }
        [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:PATH_PHOTO_FILE error:nil];
        writeError = error;
    };
    //////
    unsigned long long photoFileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:PATH_PHOTO_FILE error:nil].fileSize;
    unsigned long long moveFileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:PATH_MOVIE_FILE error:nil].fileSize;
    
    unsigned long long totalSize = (photoFileSize+moveFileSize);
    _progressBlocker = ^(CGFloat percent, int64_t requestDidSendBytes) {
        if (tmpProgressBlocker) {
            tmpProgressBlocker(percent*requestDidSendBytes/totalSize, totalSize);
        }
    };
    
    [self uploadFile:PATH_PHOTO_FILE saveKey:[NSString stringWithFormat:@"%@.jpg",saveKey]];
    [self uploadFile:PATH_MOVIE_FILE saveKey:[NSString stringWithFormat:@"%@.mov",saveKey] extParams:extParams];
}


- (BOOL)extractLivePhoto:(PHLivePhoto *)livePhotoAsset {
    if (!livePhotoAsset) {
        NSError *error = [NSError errorWithDomain:ERROR_DOMAIN
                                           code:-2016
                                       userInfo:@{@"message":@"livePhotoAsset 不存在"}];
        
        if (_failBlocker) {
            _failBlocker(error);
        }
        return NO;
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:PATH_PHOTO_FILE error:nil];
    
    NSArray *assetResArray= [PHAssetResource assetResourcesForLivePhoto:livePhotoAsset];
    PHAssetResource *movieResource;
    PHAssetResource *photoResource;
    for (PHAssetResource *assetRes in assetResArray) {
        if (assetRes.type == PHAssetResourceTypePhoto) {
            photoResource = assetRes;
        }
        if (assetRes.type == PHAssetResourceTypePairedVideo) {
            movieResource = assetRes;
        }
    }
    __block NSError *writeError = nil;
    __block BOOL twoHanldeOK = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [[PHAssetResourceManager defaultManager] writeDataForAssetResource:movieResource toFile:[NSURL fileURLWithPath:PATH_MOVIE_FILE] options:nil completionHandler:^(NSError * error) {
        writeError = error;
        if (twoHanldeOK) {
            dispatch_semaphore_signal(semaphore);
        }
        twoHanldeOK = YES;
    }];
    
    [[PHAssetResourceManager defaultManager] writeDataForAssetResource:photoResource toFile:[NSURL fileURLWithPath:PATH_PHOTO_FILE] options:nil completionHandler:^(NSError * error) {
        writeError = error;
        if (twoHanldeOK) {
            dispatch_semaphore_signal(semaphore);
        }
        twoHanldeOK = YES;
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    
    if (writeError) {
        if (_failBlocker) {
            _failBlocker(writeError);
        }
    }
    
    return writeError==nil;
}

#endif


- (void) uploadFile:(id)file saveKey:(NSString *)saveKey {
    [self uploadFile:file saveKey:saveKey extParams:nil];
}

// FIXME 
- (void)uploadFile:(id)file saveKey:(NSString *)saveKey extParams:(NSDictionary *)extParams {
    if (![self checkFile:file]) {
        return;
    }
    self.extParams = [NSMutableDictionary dictionaryWithDictionary:extParams] ;

    
    if([file isKindOfClass:[UIImage class]]) {
        [self uploadImage:file savekey:saveKey];
    } else if([file isKindOfClass:[NSData class]]) {
        [self uploadFileData:file savekey:saveKey];
    } else if([file isKindOfClass:[NSString class]]) {
        [self uploadFilePath:file savekey:saveKey];
    }
}

#pragma mark----form upload

- (void)formUploadWithFileData:(NSData *)data
                      FilePath:(NSString *)filePath
                       SaveKey:(NSString *)savekey
                    RetryTimes:(NSInteger)retryTimes {
    
    __weak typeof(self)weakSelf = self;
    
    //进度回调
    HttpProgressBlock httpProgress = ^(int64_t completedBytesCount, int64_t totalBytesCount) {
        CGFloat percent = completedBytesCount/(float)totalBytesCount;
        if (_progressBlocker) {
            _progressBlocker(percent, totalBytesCount);
        }
    };
    //成功回调
    HttpSuccessBlock httpSuccess = ^(NSURLResponse *response, id responseData) {
        NSError *error;
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        NSString *message = [jsonDic objectForKey:@"message"];
        if ([@"ok" isEqualToString:message]) {
            if (_successBlocker) {
                _successBlocker(response, jsonDic);
            }
        } else {
            NSError *err = [NSError errorWithDomain:ERROR_DOMAIN
                                               code:[[jsonDic objectForKey:@"code"] intValue]
                                           userInfo:jsonDic];
            if (_failBlocker) {
                _failBlocker(err);
            }
        }
    };
    
    //失败回调
    HttpFailBlock httpFail = ^(NSError * error) {
        
        if (retryTimes > 0 && error.code/100 == 5) {
            [weakSelf formUploadWithFileData:data FilePath:filePath SaveKey:savekey RetryTimes:retryTimes-1];
        } else {
            if (_failBlocker) {
                _failBlocker(error);
            }
        }
    };
    
    NSString *policy = @"";
    
    if (_policyBlocker) {
        policy = _policyBlocker();
    }
    
    if (policy.length == 0) {
        NSString *message = @"policyBlocker 返回值不正确,将进行本地计算";
        NSError *err = [NSError errorWithDomain:ERROR_DOMAIN
                                           code:-1999
                                       userInfo:@{@"message":message}];
        if (_failBlocker && _policyBlocker) {
            _failBlocker(err);
            return;
        }
        policy = [self getPolicyWithSaveKey:savekey];
    }
    

    __block NSString *signature = @"";
    if (_signatureBlocker) {

        signature = _signatureBlocker([policy stringByAppendingString:@"&"]);
    
    } else if (self.passcode.length > 0) {
        signature = [self getSignatureWithPolicy:policy];
    } else {
        NSString *message = _signatureBlocker ? @"signatureBlock 没有返回 signature" : @"没有提供密钥";
        NSError *err = [NSError errorWithDomain:ERROR_DOMAIN
                                           code:-1999
                                       userInfo:@{@"message":message}];
        if (_failBlocker) {
            _failBlocker(err);
        }
        return;
    }
    
    BmobUPMultipartBody *multiBody = [[BmobUPMultipartBody alloc]init];
    [multiBody addDictionary:@{@"policy":policy, @"signature":signature}];
    
    NSString *fileName = [filePath lastPathComponent];
    if (!fileName) {
        fileName = @"fileName";
    }
    [multiBody addFileData:data OrFilePath:filePath fileName:fileName fileType:nil];
    
    // 自己实现的UpYun Form表单上传，可以改成用UpYun SDK Form上传
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@/", [BmobUPYUNConfig sharedInstance].FormAPIDomain, self.bucket]]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [multiBody dataFromPart];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", multiBody.boundary] forHTTPHeaderField:@"Content-Type"];
    
    BmobUPHTTPClient *client = [[BmobUPHTTPClient alloc]init];
    [client uploadRequest:request success:httpSuccess failure:httpFail progress:httpProgress];
}

#pragma mark----mut upload

- (void)mutUploadWithFileData:(NSData *)data
                     FilePath:(NSString *)filePath
                      SaveKey:(NSString *)savekey
                   RetryTimes:(NSInteger)retryTimes {
    NSDictionary *fileInfo = [BmobUPMutUploaderManager getFileInfoDicWithFileData:data OrFilePath:filePath];
    NSDictionary *signaturePolicyDic = [self constructingSignatureAndPolicyWithFileInfo:fileInfo saveKey:savekey];
    if (!signaturePolicyDic) {
        return;
    }
    
    NSString *signature = signaturePolicyDic[@"signature"];
    NSString *policy = signaturePolicyDic[@"policy"];
    
    _manager= [[BmobUPMutUploaderManager alloc]initWithBucket:self.bucket];

    __weak typeof(BmobUPMutUploaderManager *)weakManager = self.manager;
    
    [weakManager uploadWithFile:data OrFilePath: filePath policy:policy signature:signature saveKey:savekey progressBlock:_progressBlocker completeBlock:^(NSError *error, NSDictionary *result, BOOL completed) {

            if (completed) {
                if (_successBlocker) {
                    _successBlocker(result[@"response"], result[@"responseData"]);
                }
            } else {
                if (retryTimes > 0 && error.code/100 == 5) {
                    [self mutUploadWithFileData:data FilePath:filePath SaveKey:savekey RetryTimes:retryTimes-1];
                } else {
                    if (_failBlocker) {
                        _failBlocker(error);
                    }
                }
            }
    }];
}

#pragma mark--Utils---

/**
 *  根据文件信息生成Signature\Policy (安全起见，以下算法应在服务端完成)
 */
- (NSDictionary *)constructingSignatureAndPolicyWithFileInfo:(NSDictionary *)fileInfo saveKey:(NSString*) saveKey{
    NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc]initWithDictionary:fileInfo];
    NSString *expiresIn = self.dateExpiresIn.length == 0 ? DATE_STRING(self.expiresIn) : self.dateExpiresIn;
    [mutableDic setObject:expiresIn forKey:@"expiration"];//设置授权过期时间
    [mutableDic setObject:saveKey forKey:@"path"];//设置保存路径
    
	    if (self.params) {
        for (NSString *key in self.params.keyEnumerator) {
            [mutableDic setObject:[self.params objectForKey:key] forKey:key];
        }
    }
    
    if (self.extParams.count > 0) {
        for (NSString *key in self.extParams.keyEnumerator) {
            [mutableDic setObject:[self.extParams objectForKey:key] forKey:key];
        }
    }
    self.extParams = nil;

    /**
     *  这个 mutableDic 可以塞入其他可选参数 见：http://docs.upyun.com/api/multipart_upload/#_2
     */
    
    NSString *policy = @"";
    if (_policyBlocker) {
        policy = _policyBlocker();
    }
    
    if (policy.length == 0) {
        NSString *message = @"policyBlocker 返回值不正确,将进行本地计算";
        NSError *err = [NSError errorWithDomain:ERROR_DOMAIN
                                           code:-1999
                                       userInfo:@{@"message":message}];
        if (_failBlocker && _policyBlocker) {
            _failBlocker(err);
            return nil;
        }
        
        policy = [self dictionaryToJSONStringBase64Encoding:mutableDic];
    }
    
    __block NSString *signature = @"";
    if (_signatureBlocker) {
        signature = _signatureBlocker(policy);
    } else if (self.passcode) {
        NSArray *keys = [[mutableDic allKeys] sortedArrayUsingSelector:@selector(compare:)];
        for (NSString * key in keys) {
            NSString * value = mutableDic[key];
            signature = [NSString stringWithFormat:@"%@%@%@", signature, key, value];
        }
        signature = [signature stringByAppendingString:self.passcode];
        signature = [signature MD5];
    } else {
        NSString *message = _signatureBlocker ? @"signatureBlock 没有返回 signature" : @"没有提供密钥";
        NSError *err = [NSError errorWithDomain:ERROR_DOMAIN
                                           code:-1999
                                       userInfo:@{@"message":message}];
        if (_failBlocker) {
            _failBlocker(err);
            return nil;
        }
    }
    return @{@"signature":signature,
             @"policy":policy};
}

- (NSString *)getPolicyWithSaveKey:(NSString *)savekey {
    NSString *expiresIn = self.dateExpiresIn.length == 0 ? DATE_STRING(self.expiresIn) : self.dateExpiresIn;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.bucket forKey:@"bucket"];
    [dic setObject:expiresIn forKey:@"expiration"];
    if (savekey && ![savekey isEqualToString:@""]) {
        [dic setObject:savekey forKey:@"save-key"];
    }
    if (self.params) {
        for (NSString *key in self.params.keyEnumerator) {
            [dic setObject:[self.params objectForKey:key] forKey:key];
        }
    }
    
    if (self.extParams.count > 0) {
        for (NSString *key in self.extParams.keyEnumerator) {
            [dic setObject:[self.extParams objectForKey:key] forKey:key];
        }
    }
    self.extParams = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [json Base64encode];
}

- (NSString *)getSignatureWithPolicy:(NSString *)policy {
    NSString *str = [NSString stringWithFormat:@"%@&%@", policy, self.passcode];
    NSString *signature = [[[str dataUsingEncoding:NSUTF8StringEncoding] MD5HexDigest] lowercaseString];
    return signature;
}

- (NSString *)dictionaryToJSONStringBase64Encoding:(NSDictionary *)dic {
    id paramesData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:paramesData
                                                 encoding:NSUTF8StringEncoding];
    return [jsonString Base64encode];
}

- (BOOL)checkSavekey:(NSString *)string {
    NSRange rangeFileName;
    NSRange rangeFileNameOnDic;
    rangeFileNameOnDic.location = NSNotFound;
    rangeFileName = [string rangeOfString:SUB_SAVE_KEY_FILENAME];
    if ([_params objectForKey:@"save-key"]) {
        rangeFileNameOnDic = [[_params objectForKey:@"save-key"]
                              rangeOfString:SUB_SAVE_KEY_FILENAME];
    }

    if(rangeFileName.location != NSNotFound || rangeFileNameOnDic.location != NSNotFound) {
        NSString *message = [NSString stringWithFormat:@"传入file为NSData或者UIImage时,不能使用%@方式生成savekey", SUB_SAVE_KEY_FILENAME];
        NSError *err = [NSError errorWithDomain:ERROR_DOMAIN
                                           code:-1998
                                       userInfo:@{@"message":message}];
        if (_failBlocker) {
            _failBlocker(err);
        }
        return NO;
    }
    return YES;
}

- (BOOL)checkFilePath:(NSString *)filePath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSString *message = [NSString stringWithFormat:@"传入filepath找不到文件, %@", filePath];
        NSError *err = [NSError errorWithDomain:ERROR_DOMAIN
                                           code:-1997
                                       userInfo:@{@"message":message}];
        if (_failBlocker) {
            _failBlocker(err);
        }

        return NO;
    }
    return YES;
}

- (BOOL)checkFileData:(NSData *)filedata {
    if (!filedata) {
        NSString *message = [NSString stringWithFormat:@"传入filedata 为空！"];
        NSError *err = [NSError errorWithDomain:ERROR_DOMAIN
                                           code:-1997
                                       userInfo:@{@"message":message}];
        if (_failBlocker) {
            _failBlocker(err);
        }
        
        return NO;
    }
    return YES;
}

- (BOOL)checkFile:(id) file {
    if (!file) {
        NSString *message = [NSString stringWithFormat:@"传入file 为空！"];
        NSError *err = [NSError errorWithDomain:ERROR_DOMAIN
                                           code:-1997
                                       userInfo:@{@"message":message}];
        if (_failBlocker) {
            _failBlocker(err);
        }
        
        return NO;
    }
    return YES;
}

-(void)cancel{
    [_client cancel];
    [_manager cancelAllTasks];
}

-(void)dealloc{
//    NSLog(@"%@ dealloc",[self class]);
}

@end
