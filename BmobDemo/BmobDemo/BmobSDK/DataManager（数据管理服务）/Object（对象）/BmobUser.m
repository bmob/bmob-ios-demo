//
//  BmobUser.m
//  BmobSDK
//
//  Created by Bmob on 13-8-6.
//  Copyright (c) 2013年 Bmob. All rights reserved.
//

#import "BmobUser.h"
#import "BCommonUtils.h"
#import "BmobGeoPoint.h"
#import "BmobFile.h"
#import "BHttpClientUtil.h"
#import "BmobQuery.h"
#import "BCommonUtils.h"
#import "BRequestDataFormat.h"
#import "BEncryptUtil.h"
#import "BResponseUtil.h"
#import "SDKAPIManager.h"


@interface BmobUser(){
    
}

//@property(nonatomic,strong) NSMutableDictionary *userDic;

@end

@implementation BmobUser

static NSString *kUserTable = @"_User";



//@synthesize userDic=_userDic;
//@synthesize className = _className;
@synthesize username = _username;
@synthesize password = _password;
@synthesize email    = _email;
@synthesize mobilePhoneNumber = _mobilePhoneNumber;

-(id)init{
    self = [super init];
    if (self ) {
        //        _userDic = [[NSMutableDictionary alloc] init];
        
        self.className = kUserTable;
    }
    
    return self;
}

-(id)initWithClassName:(NSString *)className{
    
    return [self init];
}

+(BmobQuery*)query{
    BmobQuery   *bmobQueryInstance = [[BmobQuery alloc] initWithClassName:kUserTable];
    return bmobQueryInstance;
}


#pragma mark - set

-(void)setUsername:(NSString *)username{
    [self setUserName:username];
}




-(void)setUserName:(NSString*)username{
    if (!username) {
        return;
    }
    _username = username;
    [self setObject:username forKey:@"username"];
    
}

-(void)setPassword:(NSString*)password{
    if (!password) {
        return;
    }
    _password = password;
    [self setObject:password forKey:@"password"];
    
}

-(void)setEmail:(NSString *)email{
    if (!email) {
        return;
    }
    _email = email;
    [self setObject:email forKey:@"email"];
    
}

-(void)setMobilePhoneNumber:(NSString *)mobilePhoneNumber{
    if (!mobilePhoneNumber) {
        return;
    }
    _mobilePhoneNumber = mobilePhoneNumber;
    [self setObject:mobilePhoneNumber forKey:@"mobilePhoneNumber"];
}



-(NSDictionary*)dataDictionary{
    
    return [super valueForKey:@"requestDataDictionary"];
}

#pragma mark sing up - login
-(void)signUpInBackground{
    
    if (!self.password || [self.password isEqualToString: @""]) {
        
        return;
    }
    
    if (!self.username || [self.username isEqualToString:@""]) {
        return;
    }
    
    [self signUpInBackgroundWithBlock:nil callback:NO];
    
}


-(void)signUpInBackgroundWithBlock:(BmobBooleanResultBlock)block{
    
    if (!self.password || [self.password isEqualToString: @""]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullPassword];
                block(NO,error);
            }
        });
        
        
    }
    else if (!self.username || [self.username isEqualToString:@""]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullUsername];
                block(NO,error);
            }
        });
        
        
    }
    else{
        [self signUpInBackgroundWithBlock:block callback:YES];
    }
}

-(void)signUpInBackgroundWithBlock:(BmobBooleanResultBlock)block callback:(BOOL)needCallback{
    
    NSDictionary    *tmpDataDictionary = [self dataDictionary];
    NSDictionary *requestDic = [BRequestDataFormat requestDictionaryWithClassname:nil data:tmpDataDictionary];
    
    NSString *userSignUpUrl            = [[SDKAPIManager defaultAPIManager] signupInterface];
    BHttpClientUtil *requestUtil    = [BHttpClientUtil requestUtilWithUrl:userSignUpUrl];
    __weak typeof(BHttpClientUtil *) weakRequest       = requestUtil;
    [weakRequest addParameter:requestDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     NSDictionary *signUpDic = dictionary;
                     NSMutableDictionary *signUpMutableDic = [NSMutableDictionary dictionary];
                     if (signUpDic && signUpDic.count > 0) {
                         if ([[[signUpDic objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                             if ([BCommonUtils isNotNilOrNull:[signUpDic objectForKey:@"data"]]) {
                                 //save token
                                 NSString    *sessionToken = [[[signUpDic objectForKey:@"data"] objectForKey:@"sessionToken"] description];
                                 [[NSUserDefaults standardUserDefaults] setObject:sessionToken forKey:kBmobSessionToken];
                                 
                                 //save local
                                 [signUpMutableDic setDictionary:[signUpDic objectForKey:@"data"]];
                                 for (NSString *key in tmpDataDictionary) {
                                     [signUpMutableDic setObject:[tmpDataDictionary objectForKey:key] forKey:key];
                                 }
                                 [signUpMutableDic removeObjectForKey:@"password"];
                                 [signUpMutableDic removeObjectForKey:@"ACL"];
                                 [signUpMutableDic removeObjectForKey:@"sessionToken"];
                                 NSString *filepath = [[BCommonUtils filePath] stringByAppendingPathComponent:@"current.archive"];
                                 [NSKeyedArchiver archiveRootObject:signUpMutableDic toFile:filepath];
                                 
                                 self.objectId = [[signUpMutableDic objectForKey:@"objectId"] description];
                                 self.createdAt = [BCommonUtils dateOfString:[[signUpMutableDic objectForKey:@"createdAt"] description]];
                                 self.updatedAt = [BCommonUtils dateOfString:[[signUpMutableDic objectForKey:@"updatedAt"] description]];
                                 //注册，不需要加这句
                                 //                                 [BmobUser removeSomeObjectForKeys:self];
                                 
                                 if (needCallback) {
                                     if (block) {
                                         block(YES,nil);
                                     }
                                     
                                 }
                             }else{
                                 if (needCallback) {
                                     if (block) {
                                         NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                         block(NO,error);
                                     }
                                     
                                 }
                             }
                         }else{
                             if (needCallback) {
                                 if (block) {
                                     NSError *error = [BCommonUtils errorWithResult:signUpDic];
                                     block(NO,error);
                                 }
                                 
                             }
                         }
                     }else{
                         if (needCallback) {
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


+(void)loginInBackgroundWithUsername:(NSString*)username withPassword:(NSString*)password{
    
    if (!username || [username isEqualToString:@""]) {
        
        return;
    }
    if (!password || [password isEqualToString:@""]) {
        return;
    }
    [self logInWithUsernameInBackground:username password:password block:nil callback:NO];
}

+(void)loginWithUsernameInBackground:(NSString*)username password:(NSString*)password{
    [self loginInBackgroundWithUsername:username withPassword:password];
}

+(void)loginWithUsernameInBackground:(NSString *)username password:(NSString *)password block:(BmobUserResultBlock)block{
    if (!username || [username isEqualToString:@""]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullUsername];
                block(nil,error);
            }
        });
        
        
    }
    else if (!password || [password isEqualToString:@""]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullPassword];
                block(nil,error);
            }
        });
        
        
    }
    else{
        [self logInWithUsernameInBackground:username password:password block:block callback:YES];
    }
    
}

+(void)logInWithUsernameInBackground:(NSString *)username password:(NSString *)password block:(BmobUserResultBlock)block callback:(BOOL)needCallback{
    
    NSDictionary *loginUserDic         = [NSDictionary dictionaryWithObjectsAndKeys:username,@"username",password,@"password", nil];
    NSDictionary *requestDic = [BRequestDataFormat requestDictionaryWithClassname:nil data:loginUserDic ];
    
    NSString *userLoginUrl             = [[SDKAPIManager defaultAPIManager] loginInterface];
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:userLoginUrl];
    [requestUtil addParameter:requestDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     
                     NSDictionary *loginDic = dictionary;
                     //解析正常
                     if (loginDic && [loginDic isKindOfClass:[NSDictionary class]]) {
                         if ([loginDic objectForKey:@"result"] && [[loginDic objectForKey:@"result"]isKindOfClass:[NSDictionary class]] ) {
                         //结果正确
                         if ([[[loginDic objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                             //save to local
                             NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
                             if ([loginDic objectForKey:@"data"]) {
                                 //保存sessionToken
                                 NSString    *sessionToken = [[loginDic objectForKey:@"data"] objectForKey:@"sessionToken"];
                                 [[NSUserDefaults standardUserDefaults] setObject:sessionToken forKey:kBmobSessionToken];
                                 //将除了sessionToken外的其它值保存在文件中
                                 [resultDic setDictionary:[loginDic objectForKey:@"data"]];
                                 [resultDic removeObjectForKey:@"sessionToken"];
                                 BOOL successCache = [NSKeyedArchiver archiveRootObject:resultDic toFile:[self currentUserFilePath]];
                                 debugLog(@"%i",successCache);
                             }
                             
                             //用户
                             BmobUser *buser = nil;
                             if ([BCommonUtils isNotNilOrNull:resultDic]) {
                                 if ([resultDic isKindOfClass:[NSDictionary class]]) {
                                     buser = [[[self class ]alloc] initWithDictionary:resultDic];
                                     buser.className = kUserTable;
                                     [buser setValue:resultDic forKey:kDataDicKey];
                                     
                                 }
                                 if (needCallback) {
                                     if (block) {
                                         block(buser,nil);
                                     }
                                 }
                             }else{
                                 if (needCallback) {
                                     if (block) {
                                         NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                         block(nil,error);
                                     }
                                 }
                             }
                         }else{
                             if (needCallback) {
                                 if (block) {
                                     if ([loginDic objectForKey:@"result"]) {
                                         NSError *error = [BCommonUtils errorWithResult:loginDic];
                                         block(nil,error);
                                     }else{
                                         NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                         block(nil,error);
                                     }
                                 }
                             }
                         }
                         }
                     }else{
                         if (needCallback) {
                             if (block) {
                                 NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                 block(nil,error);
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
                             block(nil,error);
                         }
                     }
                 }];
}

+(NSString*)currentUserFilePath{
    
    NSString *filepath = [[BCommonUtils filePath] stringByAppendingPathComponent:@"current.archive"];
    return filepath;
    
}

-(NSString*)currentUserFilePath{
    
    NSString *filepath = [[BCommonUtils filePath] stringByAppendingPathComponent:@"current.archive"];
    
    return filepath;
    
}

+(void)logout{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self currentUserFilePath]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[self currentUserFilePath] error:nil];
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kBmobSessionToken];
}

#pragma mark - user util
+(void)requestPasswordResetInBackgroundWithEmail:(NSString *)email{
    [self requestPasswordResetInBackgroundWithEmail:email block:nil];
}

/**
 *  通过邮件设置密码
 *
 *  @param email 邮箱地址
 *  @param block 请求的结果信息
 */
+(void)requestPasswordResetInBackgroundWithEmail:(NSString *)email
                                           block:(BmobBooleanResultBlock)block{
    if (!email) {
        if (block) {
            NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullEmail];
            block(NO,error);
        }
        return;
    }
    NSDictionary *tmpDataDic     = [NSDictionary dictionaryWithObjectsAndKeys:email,@"email", nil];
    NSDictionary *requestDic     = [BRequestDataFormat requestDictionaryWithClassname:kUserTable data:tmpDataDic];
    NSString *resetUrl           = [[SDKAPIManager defaultAPIManager] resetInterface];
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:resetUrl];
    
    [requestUtil addParameter:requestDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     debugLog(@"reset %@",dictionary);
                     if (dictionary && dictionary.count > 0) {
                         if ([[[dictionary objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                             if (block) {
                                 block(YES,nil);
                             }
                         }else{
                             if (block) {
                                 NSError *error = [BCommonUtils errorWithResult:dictionary];
                                 block(NO,error);
                             }
                         }
                     }else{
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


-(void)verifyEmailInBackgroundWithEmailAddress:(NSString *)email{
    [self verifyEmailInBackgroundWithEmailAddress:email block:nil];
}

-(void)verifyEmailInBackgroundWithEmailAddress:(NSString *)email
                                         block:(BmobBooleanResultBlock)block{
    if (!email) {
        if (block) {
            NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullEmail];
            block(NO,error);
        }
        return;
    }
    NSDictionary *tmpDataDic     = [NSDictionary dictionaryWithObjectsAndKeys:email,@"email", nil];
    NSDictionary *requestDic     = [BRequestDataFormat requestDictionaryWithClassname:kUserTable data:tmpDataDic];
    
    NSMutableString *url         = [NSMutableString string];
    NSString *resetUrl           = [[SDKAPIManager defaultAPIManager] emailVerifyInterface];
    [url setString:resetUrl];
    
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:url];
    [requestUtil addParameter:requestDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     debugLog(@"verifyEmail %@",dictionary);
                     if (dictionary && dictionary.count > 0) {
                         if ([[[dictionary objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                             if (block) {
                                 block(YES,nil);
                             }
                         }else{
                             if (block) {
                                 NSError *error = [BCommonUtils errorWithResult:dictionary];
                                 
                                 block(NO,error);
                             }
                             
                         }
                     }else{
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


-(void)userEmailVerified:(BmobBooleanResultBlock)block{
    
    if (![self objectForKey:@"emailVerified"] || ![[self objectForKey:@"emailVerified"] boolValue]) {
        BmobQuery *query = [[self class] query];
        [query getObjectInBackgroundWithId:self.objectId
                                     block:^(BmobObject *object, NSError *error) {
                                         if (block) {
                                             BOOL isVerified = [[object objectForKey:@"emailVerified"] boolValue];
                                             
                                             if (isVerified) {
                                                 NSString *filePath = [[BCommonUtils filePath] stringByAppendingPathComponent:@"current.archive"];
                                                 if ([[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] isKindOfClass:[NSDictionary class]]) {
                                                     NSMutableDictionary *uDic  = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:filePath]];
                                                     [uDic setObject:[NSNumber numberWithBool:isVerified] forKey:@"emailVerified"];
                                                     [NSKeyedArchiver archiveRootObject:uDic toFile:filePath];
                                                 }else if([[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] isKindOfClass:[NSString class]]){
                                                     NSString *filepath          = [[BCommonUtils filePath] stringByAppendingPathComponent:@"current.archive"];
                                                     NSString *dataString        = [BEncryptUtil decodeBase64String:[NSKeyedUnarchiver unarchiveObjectWithFile:filepath] ];
                                                     NSData  *data               = [dataString dataUsingEncoding:NSUTF8StringEncoding];
                                                     NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil] ];
                                                     NSMutableDictionary *uDic   = [NSMutableDictionary dictionary];
                                                     if ([[[tmpDic objectForKey:@"r"] objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                                                         [uDic setDictionary:[[tmpDic objectForKey:@"r"] objectForKey:@"data"]];
                                                     }
                                                     [uDic setObject:[NSNumber numberWithBool:isVerified] forKey:@"emailVerified"];
                                                     [NSKeyedArchiver archiveRootObject:uDic toFile:filepath];
                                                 }
                                             }
                                             block(isVerified,error);
                                         }
                                     }];
    }else{
        if (block) {
            block(YES,nil);
        }
    }
    
}

- (void)updateCurrentUserPasswordWithOldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword block:(BmobBooleanResultBlock)block{
    
    if ([BCommonUtils isStrEmptyOrNull:oldPassword] || [BCommonUtils isStrEmptyOrNull:newPassword]) {
        NSError *error = [BCommonUtils errorWithType:BmobErrorTypeErrorPara];
        [BResponseUtil executeBooleanResultBlock:block withResult:NO andError:error];
        return;
    }
    
    NSDictionary *dataDic = @{@"oldPassword":oldPassword,@"newPassword":newPassword};
    NSDictionary *extraDic;
    NSString *token = [BCommonUtils sessionToken];
    if (token) {
        extraDic = @{@"objectId":self.objectId,@"sessionToken":token};
    }
    
    NSDictionary *postDic = [BResponseUtil constructRequestCommonParaWithTableName:kUserTable andAPIData:dataDic extraRequestDicValue:extraDic];
    
    NSString *requestUrl = [[SDKAPIManager defaultAPIManager] updateUserPasswordInterface];
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:requestUrl];
    
    [requestUtil addParameter:postDic successBlock:^(NSDictionary *dictionary, NSError *error) {
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
                NSError *error = [BResponseUtil constructResponseErrorMessage:dictionary];
                [BResponseUtil executeBooleanResultBlock:block withResult:NO andError:error ];
            }
                break;
                
            case ResponseResultOfSuccess:{
                [BResponseUtil executeBooleanResultBlock:block withResult:YES andError:nil];
                
            }
                break;
                
            default:
                break;
        } }failBlock:^(NSError *err){
            BmobErrorType type = BmobErrorTypeConnectFailed;
            if (err) {
                type = (BmobErrorType)err.code;
            }
            NSError * error = [BCommonUtils errorWithType:type];
            [BResponseUtil executeBooleanResultBlock:block withResult:NO andError:error];
        }];
}

#pragma mark - 手机注册登录
+(void)signOrLoginInbackgroundWithMobilePhoneNumber:(NSString*)phoneNumber andSMSCode:(NSString*)smsCode block:(BmobUserResultBlock)block{
    debugLog(@"%d",[BCommonUtils isMobilePhoneNumberLegal:phoneNumber]);
    if ([BCommonUtils isMobilePhoneNumberLegal:phoneNumber]){
        NSError *error = [BCommonUtils errorWithType:BmobErrorTypeInvalidMobilePhoneNumber];
        [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
        return;
    }
    
    if ([BCommonUtils isSMSCodeLegal:smsCode]) {
        NSError *error = [BCommonUtils errorWithType:BmobErrorTypeInvalidSMSCode];
        [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
        return;
    }
    
    NSDictionary *dataDic = @{@"mobilePhoneNumber":phoneNumber,@"smsCode":smsCode};
    NSDictionary *postDic = [BResponseUtil constructRequestCommonParaWithTableName:kUserTable andAPIData:dataDic];
    NSString *requestUrl = [[SDKAPIManager defaultAPIManager] loginOrSignupInterface];
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:requestUrl];
    
    [requestUtil addParameter:postDic successBlock:^(NSDictionary *dictionary, NSError *error) {
        int code = [BResponseUtil checkResponseWithDic:dictionary withDataCountCanZero:NO];
        
        switch (code) {
            case ResponseResultOfConnectError:{
                //将网络请求中的错误返回
                [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
            }
                break;
                
            case ResponseResultOfServerError:{
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
            }
                break;
                
            case ResponseResultOfRequestError:{
                //返回相应的错误信息
                NSError *error = [BResponseUtil constructResponseErrorMessage:dictionary];
                [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
            }
                break;
                
            case ResponseResultOfSuccess:{
                
                [BmobUser savaUserMsgLocol:dictionary];
                
                BmobUser *buser = [[self class] constructBmobUser:dictionary];
                
                [BResponseUtil executeUserResultBlock:block withResult:buser andError:nil];
            }
                break;
                
            default:
                break;
        } }failBlock:^(NSError *err){
            BmobErrorType type = BmobErrorTypeConnectFailed;
            if (err) {
                type = (BmobErrorType)err.code;
            }
            NSError * error = [BCommonUtils errorWithType:type];
            [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
        }];
}

+(void)signOrLoginInbackgroundWithMobilePhoneNumber:(NSString*)phoneNumber SMSCode:(NSString*)smsCode andPassword:(NSString *)password block:(BmobUserResultBlock)block{
    debugLog(@"%d",[BCommonUtils isMobilePhoneNumberLegal:phoneNumber]);
    if ([BCommonUtils isMobilePhoneNumberLegal:phoneNumber]){
        NSError *error = [BCommonUtils errorWithType:BmobErrorTypeInvalidMobilePhoneNumber];
        [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
        return;
    }
    
    if ([BCommonUtils isSMSCodeLegal:smsCode]) {
        NSError *error = [BCommonUtils errorWithType:BmobErrorTypeInvalidSMSCode];
        [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
        return;
    }
    
    
    NSDictionary *dataDic;
    if ([BCommonUtils isStrEmptyOrNull:password]) {
        dataDic = @{@"mobilePhoneNumber":phoneNumber,@"smsCode":smsCode};
    } else {
        dataDic = @{@"mobilePhoneNumber":phoneNumber,@"smsCode":smsCode,@"password":password};
    }
    
    
    NSDictionary *postDic = [BResponseUtil constructRequestCommonParaWithTableName:kUserTable andAPIData:dataDic];
    NSString *requestUrl =[[SDKAPIManager defaultAPIManager] loginOrSignupInterface] ;
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:requestUrl];
    
    [requestUtil addParameter:postDic successBlock:^(NSDictionary *dictionary, NSError *error) {
        int code = [BResponseUtil checkResponseWithDic:dictionary withDataCountCanZero:NO];
        
        switch (code) {
            case ResponseResultOfConnectError:{
                //将网络请求中的错误返回
                [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
            }
                break;
                
            case ResponseResultOfServerError:{
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
            }
                break;
                
            case ResponseResultOfRequestError:{
                //返回相应的错误信息
                NSError *error = [BResponseUtil constructResponseErrorMessage:dictionary];
                [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
            }
                break;
                
            case ResponseResultOfSuccess:{
                
                [BmobUser savaUserMsgLocol:dictionary];
                
                BmobUser *buser = [[self class] constructBmobUser:dictionary];
                
                [BResponseUtil executeUserResultBlock:block withResult:buser andError:nil];
            }
                break;
                
            default:
                break;
        } }failBlock:^(NSError *err){
            BmobErrorType type = BmobErrorTypeConnectFailed;
            if (err) {
                type = (BmobErrorType)err.code;
            }
            NSError * error = [BCommonUtils errorWithType:type];
            [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
        }];
}

- (void)signUpOrLoginInbackgroundWithSMSCode:(NSString *)smsCode block:(BmobBooleanResultBlock)block{
    if ([BCommonUtils isMobilePhoneNumberLegal:self.mobilePhoneNumber]){
        NSError *error = [BCommonUtils errorWithType:BmobErrorTypeInvalidMobilePhoneNumber];
        [BResponseUtil executeBooleanResultBlock:block  withResult:NO andError:error];
        return;
    }
    
    if ([BCommonUtils isSMSCodeLegal:smsCode]) {
        NSError *error = [BCommonUtils errorWithType:BmobErrorTypeInvalidSMSCode];
        [BResponseUtil executeBooleanResultBlock:block  withResult:NO andError:error];
        return;
    }
    
    
    
    NSMutableDictionary *tmpDataDictionary = [[NSMutableDictionary alloc] initWithDictionary:[self dataDictionary]];
    [tmpDataDictionary setObject:smsCode forKey:@"smsCode"];
    
    
    NSDictionary *requestDic = [BRequestDataFormat requestDictionaryWithClassname:kUserTable data:tmpDataDictionary ];
    NSString *userSignUpUrl            = [[SDKAPIManager defaultAPIManager] loginOrSignupInterface];
    BHttpClientUtil *requestUtil    = [BHttpClientUtil requestUtilWithUrl:userSignUpUrl];
    __weak typeof(BHttpClientUtil *) weakRequest       = requestUtil;
    [weakRequest addParameter:requestDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     NSDictionary *signUpDic = dictionary;
                     NSMutableDictionary *signUpMutableDic = [NSMutableDictionary dictionary];
                     if (signUpDic && signUpDic.count > 0) {
                         if ([[[signUpDic objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                             if ([BCommonUtils isNotNilOrNull:[signUpDic objectForKey:@"data"]]) {
                                 //save token
                                 NSString    *sessionToken = [[[signUpDic objectForKey:@"data"] objectForKey:@"sessionToken"] description];
                                 [[NSUserDefaults standardUserDefaults] setObject:sessionToken forKey:kBmobSessionToken];
                                 
                                 //save local
                                 [signUpMutableDic setDictionary:[signUpDic objectForKey:@"data"]];
                                 for (NSString *key in tmpDataDictionary) {
                                     [signUpMutableDic setObject:[tmpDataDictionary objectForKey:key] forKey:key];
                                 }
                                 [signUpMutableDic removeObjectForKey:@"password"];
                                 [signUpMutableDic removeObjectForKey:@"ACL"];
                                 [signUpMutableDic removeObjectForKey:@"sessionToken"];
                                 [signUpMutableDic removeObjectForKey:@"smsCode"];
                                 NSString *filepath = [[BCommonUtils filePath] stringByAppendingPathComponent:@"current.archive"];
                                 [NSKeyedArchiver archiveRootObject:signUpMutableDic toFile:filepath];
                                 
                                 self.objectId = [[signUpMutableDic objectForKey:@"objectId"] description];
                                 self.createdAt = [BCommonUtils dateOfString:[[signUpMutableDic objectForKey:@"createdAt"] description]];
                                 self.updatedAt = [BCommonUtils dateOfString:[[signUpMutableDic objectForKey:@"updatedAt"] description]];
                                 [BmobUser removeSomeObjectForKeys:self];
                                 
                                 
                                 if (block) {
                                     block(YES,nil);
                                 }
                                 
                                 
                             }else{
                                 
                                 if (block) {
                                     NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                     block(NO,error);
                                 }
                                 
                             }
                         }else{
                             
                             if (block) {
                                 NSError *error = [BCommonUtils errorWithResult:signUpDic];
                                 block(NO,error);
                             }
                             
                             
                         }
                     }else{
                         
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

+(void)loginInbackgroundWithAccount:(NSString *)account andPassword:(NSString *)password block:(BmobUserResultBlock)block{
    if ([BCommonUtils isStrEmptyOrNull:account]){
        NSError *error = [BCommonUtils errorWithType:BmobErrorTypeErrorPara];
        [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
        return;
    }
    
    if ([BCommonUtils isStrEmptyOrNull:password]) {
        NSError *error = [BCommonUtils errorWithType:BmobErrorTypeErrorPara];
        [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
        return;
    }
    
    NSDictionary *dataDic = @{@"username":account,@"password":password};
    NSDictionary *postDic = [BResponseUtil constructRequestCommonParaWithTableName:kUserTable andAPIData:dataDic];
    NSString *requestUrl = [[SDKAPIManager defaultAPIManager] loginInterface];
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:requestUrl];
    
    [requestUtil addParameter:postDic successBlock:^(NSDictionary *dictionary, NSError *error) {
        debugLog(@"%@",dictionary);
        int code = [BResponseUtil checkResponseWithDic:dictionary withDataCountCanZero:NO];
        
        switch (code) {
            case ResponseResultOfConnectError:{
                //将网络请求中的错误返回
                [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
            }
                break;
                
            case ResponseResultOfServerError:{
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
            }
                break;
                
            case ResponseResultOfRequestError:{
                //返回相应的错误信息
                NSError *error = [BResponseUtil constructResponseErrorMessage:dictionary];
                [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
            }
                break;
                
            case ResponseResultOfSuccess:{
                [BmobUser savaUserMsgLocol:dictionary];
                
                BmobUser *buser = [[self class] constructBmobUser:dictionary];
                
                [BResponseUtil executeUserResultBlock:block withResult:buser andError:nil];
            }
                break;
                
            default:
                break;
        } }failBlock:^(NSError *err){
            BmobErrorType type = BmobErrorTypeConnectFailed;
            if (err) {
                type = (BmobErrorType)err.code;
            }
            NSError * error = [BCommonUtils errorWithType:type];
            [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
        }];
}

+(void)loginInbackgroundWithMobilePhoneNumber:(NSString *)phoneNumber andSMSCode:(NSString *)smsCode block:(BmobUserResultBlock)block{
    if ([BCommonUtils isMobilePhoneNumberLegal:phoneNumber]){
        NSError *error = [BCommonUtils errorWithType:BmobErrorTypeInvalidMobilePhoneNumber];
        [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
        return;
    }
    
    if ([BCommonUtils isSMSCodeLegal:smsCode]) {
        NSError *error = [BCommonUtils errorWithType:BmobErrorTypeInvalidSMSCode];
        [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
        return;
    }
    
    NSDictionary *dataDic = @{@"mobilePhoneNumber":phoneNumber,@"smsCode":smsCode};
    NSDictionary *postDic = [BResponseUtil constructRequestCommonParaWithTableName:kUserTable andAPIData:dataDic];
    NSString *requestUrl = [[SDKAPIManager defaultAPIManager] loginInterface];
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:requestUrl];
    
    [requestUtil addParameter:postDic successBlock:^(NSDictionary *dictionary, NSError *error) {
        debugLog(@"%@",dictionary);
        int code = [BResponseUtil checkResponseWithDic:dictionary withDataCountCanZero:NO];
        
        switch (code) {
            case ResponseResultOfConnectError:{
                //将网络请求中的错误返回
                [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
            }
                break;
                
            case ResponseResultOfServerError:{
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
            }
                break;
                
            case ResponseResultOfRequestError:{
                //返回相应的错误信息
                NSError *error = [BResponseUtil constructResponseErrorMessage:dictionary];
                [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
            }
                break;
                
            case ResponseResultOfSuccess:{
                
                [BmobUser savaUserMsgLocol:dictionary];
                
                BmobUser *buser = [[self class] constructBmobUser:dictionary];
                
                [BResponseUtil executeUserResultBlock:block withResult:buser andError:nil];
            }
                break;
                
            default:
                break;
        } }failBlock:^(NSError *err){
            BmobErrorType type = BmobErrorTypeConnectFailed;
            if (err) {
                type = (BmobErrorType)err.code;
            }
            NSError * error = [BCommonUtils errorWithType:type];
            [BResponseUtil executeUserResultBlock:block withResult:nil andError:error];
        }];
}

+(void)resetPasswordInbackgroundWithSMSCode:(NSString *)SMSCode andNewPassword:(NSString *)newPassword block:(BmobBooleanResultBlock)block{
    if ([BCommonUtils isSMSCodeLegal:SMSCode]){
        NSError *error = [BCommonUtils errorWithType:BmobErrorTypeInvalidSMSCode];
        [BResponseUtil executeBooleanResultBlock:block withResult:NO andError:error];
        return;
    }
    
    if ([BCommonUtils isStrEmptyOrNull:newPassword]) {
        NSError *error = [BCommonUtils errorWithType:BmobErrorTypeErrorPara];
        [BResponseUtil executeBooleanResultBlock:block withResult:NO andError:error];
        return;
    }
    
    NSDictionary *dataDic = @{@"smsCode":SMSCode,@"password":newPassword};
    NSDictionary *postDic = [BResponseUtil constructRequestCommonParaWithTableName:kUserTable andAPIData:dataDic];
    NSString *requestUrl = [[SDKAPIManager defaultAPIManager] phoneResetInterface];
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:requestUrl];
    
    [requestUtil addParameter:postDic successBlock:^(NSDictionary *dictionary, NSError *error) {
        debugLog(@"%@",dictionary);
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
                NSError *error = [BResponseUtil constructResponseErrorMessage:dictionary];
                [BResponseUtil executeBooleanResultBlock:block withResult:NO andError:error];
            }
                break;
                
            case ResponseResultOfSuccess:{
                [BResponseUtil executeBooleanResultBlock:block withResult:YES andError:nil];
            }
                break;
                
            default:
                break;
        } }failBlock:^(NSError *err){
            BmobErrorType type = BmobErrorTypeConnectFailed;
            if (err) {
                type = (BmobErrorType)err.code;
            }
            NSError * error = [BCommonUtils errorWithType:type];
            [BResponseUtil executeBooleanResultBlock:block withResult:NO andError:error];
        }];
}


#pragma mark - 第三方登录
//@{@"access_token":@"获取的token",@"uid":@"授权后获取的id",@"expirationDate":@"获取的过期时间（NSDate）"}
+(void)signUpInBackgroundWithAuthorDictionary:(NSDictionary *)infoDictionary
                                     platform:(BmobSNSPlatform)platform
                                        block:(BmobUserResultBlock)block{
    NSArray *keyArray  = [infoDictionary allKeys];
    if (![keyArray containsObject:@"access_token"] || ![keyArray containsObject:@"uid"] || ![keyArray containsObject:@"expirationDate"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error                     = [BCommonUtils errorWithType:BmobErrorTypeLackOfInfomation];
                block(nil,error);
                
            }
        });
        
    }else if (![[infoDictionary objectForKey:@"expirationDate"] isKindOfClass:[NSDate class]]){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error                     = [BCommonUtils errorWithType:BmobErrorTypeErrorType];
                block(nil,error);
            }
        });
        
    }else{
        
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
        NSDate *expirationDate           = [infoDictionary objectForKey:@"expirationDate"];
        NSInteger expires_in             = [expirationDate timeIntervalSinceNow];
        //需要的数据
        NSMutableDictionary *authDic     =[NSMutableDictionary dictionary];
        switch (platform) {
            case BmobSNSPlatformQQ:{
                [infoDic setObject:[infoDictionary objectForKey:@"access_token"] forKey:@"access_token"];
                [infoDic setObject:[infoDictionary objectForKey:@"uid"] forKey:@"openid"];
                [infoDic setObject:[NSNumber numberWithInteger:expires_in] forKey:@"expires_in"];
                [authDic setObject:infoDic forKey:@"qq"];
            }
                break;
                
            case BmobSNSPlatformSinaWeibo:{
                [infoDic setObject:[infoDictionary objectForKey:@"access_token"] forKey:@"access_token"];
                [infoDic setObject:[infoDictionary objectForKey:@"uid"] forKey:@"uid"];
                [infoDic setObject:[NSNumber numberWithInteger:expires_in] forKey:@"expires_in"];
                [authDic setObject:infoDic forKey:@"weibo"];
            }
                break;
                
            case BmobSNSPlatformWeiXin:{
                [infoDic setObject:[infoDictionary objectForKey:@"access_token"] forKey:@"access_token"];
                [infoDic setObject:[infoDictionary objectForKey:@"uid"] forKey:@"openid"];
                [infoDic setObject:[NSNumber numberWithInteger:expires_in] forKey:@"expires_in"];
                [authDic setObject:infoDic forKey:@"weixin"];
            }
                break;
                
            default:
                break;
        }
        
        NSDictionary *dataDic = @{@"authData":authDic};
        
        NSDictionary *requestDic = [BRequestDataFormat requestDictionaryWithClassname:kUserTable data:dataDic ];
        
        NSString *userSignUpUrl  = [[SDKAPIManager defaultAPIManager] loginOrSignupInterface];
        
        BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:userSignUpUrl];
        [requestUtil addParameter:requestDic
                     successBlock:^(NSDictionary *dictionary, NSError *error) {
                         NSDictionary *loginDic     = dictionary;
                         //解析正常
                         if (loginDic && loginDic.count > 0) {
                             //结果正确
                             if ([[[loginDic objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                                 //save to local
                                 NSMutableDictionary *resultDic        = [NSMutableDictionary dictionary];
                                 if ([loginDic objectForKey:@"data"]) {
                                     NSString    *sessionToken          = [[loginDic objectForKey:@"data"] objectForKey:@"sessionToken"];
                                     [[NSUserDefaults standardUserDefaults] setObject:sessionToken forKey:kBmobSessionToken];
                                     [resultDic setDictionary:[loginDic objectForKey:@"data"]];
                                     [resultDic removeObjectForKey:@"sessionToken"];
                                     [NSKeyedArchiver archiveRootObject:resultDic toFile:[self currentUserFilePath]];
                                     
                                 }
                                 //用户
                                 BmobUser *buser = nil;
                                 if ([BCommonUtils isNotNilOrNull:resultDic]) {
                                     if ([resultDic isKindOfClass:[NSDictionary class]]) {
                                         buser  = [[[self class] alloc] initWithDictionary:resultDic];
                                         buser.className = kUserTable;
                                         [buser setValue:resultDic forKey:kDataDicKey];
                                     }
                                     
                                     if (block) {
                                         block(buser,nil);
                                     }
                                 }else{
                                     if (block) {
                                         NSError *error  = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                         block(nil,error);
                                     }
                                 }
                             }else{
                                 if (block) {
                                     if ([loginDic objectForKey:@"result"]) {
                                         NSError *error  = [BCommonUtils errorWithResult:loginDic];
                                         block(nil,error);
                                     }else{
                                         NSError *error  = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                         block(nil,error);
                                     }
                                 }
                             }
                         }else{
                             if (block) {
                                 NSError *error  = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
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

+ (void)loginInBackgroundWithAuthorDictionary:(NSDictionary *)infoDictionary
                                     platform:(BmobSNSPlatform)platform
                                        block:(BmobUserResultBlock)block{
    [self signUpInBackgroundWithAuthorDictionary:infoDictionary
                                        platform:platform
                                           block:block];
}

-(void)linkedInBackgroundWithAuthorDictionary:(NSDictionary *)infoDictionary
                                     platform:(BmobSNSPlatform)platform
                                        block:(BmobBooleanResultBlock)block{
    
    NSArray *keyArray  = [infoDictionary allKeys];
    if (!self.objectId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullObjectId];
                block(NO,error);
            }
        });
        
        
    }else if (![keyArray containsObject:@"access_token"] || ![keyArray containsObject:@"uid"] || ![keyArray containsObject:@"expirationDate"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error                     = [BCommonUtils errorWithType:BmobErrorTypeLackOfInfomation];
                block(NO,error);
            }
        });
        
        
    }else if (![[infoDictionary objectForKey:@"expirationDate"] isKindOfClass:[NSDate class]]){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error                     = [BCommonUtils errorWithType:BmobErrorTypeErrorType];
                block(NO,error);
            }
        });
        
        
    }else{
        NSMutableDictionary  *requestDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [requestDic setObject:[BCommonUtils clientDic] forKey:@"client"];
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
        NSDate *expirationDate           = [infoDictionary objectForKey:@"expirationDate"];
        NSInteger expires_in             = [expirationDate timeIntervalSinceNow];
        //需要的数据
        NSMutableDictionary *authDic     =[NSMutableDictionary dictionary];
        switch (platform) {
            case BmobSNSPlatformQQ:{
                [infoDic setObject:[infoDictionary objectForKey:@"access_token"] forKey:@"access_token"];
                [infoDic setObject:[infoDictionary objectForKey:@"uid"] forKey:@"openid"];
                [infoDic setObject:[NSNumber numberWithInteger:expires_in] forKey:@"expires_in"];
                [authDic setObject:infoDic forKey:@"qq"];
            }
                break;
                
            case BmobSNSPlatformSinaWeibo:{
                [infoDic setObject:[infoDictionary objectForKey:@"access_token"] forKey:@"access_token"];
                [infoDic setObject:[infoDictionary objectForKey:@"uid"] forKey:@"uid"];
                [infoDic setObject:[NSNumber numberWithInteger:expires_in] forKey:@"expires_in"];
                [authDic setObject:infoDic forKey:@"weibo"];
            }
                break;
                
            case BmobSNSPlatformWeiXin:{
                [infoDic setObject:[infoDictionary objectForKey:@"access_token"] forKey:@"access_token"];
                [infoDic setObject:[infoDictionary objectForKey:@"uid"] forKey:@"openid"];
                [infoDic setObject:[NSNumber numberWithInteger:expires_in] forKey:@"expires_in"];
                [authDic setObject:infoDic forKey:@"weixin"];
            }
                break;
                
            default:
                break;
        }
        NSDictionary *dataDic = @{@"authData":authDic};
        [self updateWithDictionary:dataDic block:block needCallback:YES];
    }
    
}


-(void)cancelLinkedInBackgroundWithPlatform:(BmobSNSPlatform)platform
                                      block:(BmobBooleanResultBlock)block{
    
    if (!self.objectId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullObjectId];
                block(NO,error);
            }
        });
        
    }else{
        NSDictionary *updateContentDic = nil;
        switch (platform) {
            case BmobSNSPlatformQQ:{
                updateContentDic = @{@"qq":[NSNull null]};
            }
                break;
                
            case BmobSNSPlatformSinaWeibo:{
                updateContentDic = @{@"weibo":[NSNull null]};
            }
                break;
                
            case BmobSNSPlatformWeiXin:{
                updateContentDic = @{@"weixin":[NSNull null]};
            }
                break;
                
            default:
                break;
        }
        NSDictionary *updateDateDic  = @{@"authData":updateContentDic};
        [self updateWithDictionary:updateDateDic block:block needCallback:YES];
    }
}

#pragma mark 缓存用户
//清除一些数据
+(void )removeSomeObjectForKeys:(BmobUser *)buser{
    
    NSMutableDictionary *userDic = [buser valueForKey:kDataDicKey];
    
    for (NSString *key in [userDic allKeys]) {
        if ([key isEqualToString:@"_isdel"]) {
            [userDic removeObjectForKey:@"_isdel"];
        }
        if ([key isEqualToString:@"password"]) {
            [userDic removeObjectForKey:@"password"];
        }
    }
    if (userDic[@"objectId"]) {
        buser.objectId = userDic[@"objectId"];
        [userDic removeObjectForKey:@"objectId"];
    } else if (userDic [@"_id"]){
        buser.objectId = userDic [@"_id"];
    }
    if (userDic [@"createdAt"]) {
        NSDate *createAt = [BCommonUtils dateOfString:[NSString stringWithFormat:@"%@",userDic[@"createdAt"]]];
        buser.createdAt = createAt;
    }
    
    
    if (userDic [@"updatedAt"]) {
        NSDate *updateAt = [BCommonUtils dateOfString:[NSString stringWithFormat:@"%@",userDic [@"updatedAt"]]];
        buser.updatedAt = updateAt;
    }else{
        buser.updatedAt = buser.createdAt;
    }
    
    [buser setValue:userDic forKey:kDataDicKey];
    
}

/**
 *	得到当前BmobUser
 *
 *	@return	返回BmobUser对象
 */
+(BmobUser*)currentUser{
    NSString *currentUserFilePath = [[self class] currentUserFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:currentUserFilePath]) {
        //api7
        if ([[NSKeyedUnarchiver unarchiveObjectWithFile:currentUserFilePath] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *tmpDic = [NSKeyedUnarchiver unarchiveObjectWithFile:currentUserFilePath] ;
            BmobUser *buser = nil;
            if (tmpDic) {
                buser = [[[self class] alloc] initWithDictionary:tmpDic];
                buser.className = kUserTable;
                [buser setValue:tmpDic forKey:kDataDicKey];
                [[self class] removeSomeObjectForKeys:buser];
                
                return buser;
            }
        }
        //兼容7之前的
        else if([[NSKeyedUnarchiver unarchiveObjectWithFile:currentUserFilePath] isKindOfClass:[NSString class]]) {
            NSString *dataString = [BEncryptUtil decodeBase64String:[NSKeyedUnarchiver unarchiveObjectWithFile:currentUserFilePath] ];
            NSData  *data        = [dataString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *tmpDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            BmobUser *buser      = nil;
            
            if ([[[tmpDic objectForKey:@"r"] objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                
                buser = [[[self class] alloc] initWithDictionary:tmpDic];
                buser.className = kUserTable;
                [buser setValue:[[tmpDic objectForKey:@"r"] objectForKey:@"data"] forKey:kDataDicKey];
            }
            
            [[self class] removeSomeObjectForKeys:buser];
            return buser ;
        }
    }
    
    return nil;
}

//+(BmobUser*)getCurrentObject{
//    return [[self class]getCurrentUser];
//}

+(BmobUser*)getCurrentUser{
    
    return [[self class] currentUser];
    
}

+ (NSString *)getSessionToken
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:kBmobSessionToken];
}

+ (instancetype )fetchUserInfo
{
    return  [BmobQuery queryForUser];
    //return 0;
}

#pragma mark 继承

+(instancetype)objectWithoutDataWithClassName:(NSString *)className objectId:(NSString *)objectId{
    BmobUser *user = [[[self class] alloc] initWithClassName:kUserTable];
    user.objectId  = objectId;
    return user ;
}

+(BmobObject *)objectWithClassName:(NSString *)className{
    BmobUser *user = [[BmobUser alloc] initWithClassName:kUserTable];
    return user ;
}

-(void)saveAllWithDictionary:(NSDictionary *)dic{
    [super saveAllWithDictionary:dic];
}

//保存
-(void)saveInBackground{
}

-(void)saveInBackgroundWithResultBlock:(BmobBooleanResultBlock)block{
}

-(void)updateInBackground{
    if (!self.objectId) {
        return;
    }
    [self updateInBackgroundWithResultBlock:nil callback:NO];
    
}


-(void)updateInBackgroundWithResultBlock:(BmobBooleanResultBlock)block{
    
    if (!self.objectId) {
        if (block) {
            NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullObjectId];
            block(NO,error);
        }
        
    }else{
        [self updateInBackgroundWithResultBlock:block callback:YES];
    }
}

-(void)updateInBackgroundWithResultBlock:(BmobBooleanResultBlock)block callback:(BOOL)needCallback{
    NSMutableDictionary *dic = [[self dataDictionary] mutableCopy];
    if (![BCommonUtils isStrEmptyOrNull:self.mobilePhoneNumber]) {
        [dic setObject:self.mobilePhoneNumber forKey:@"mobilePhoneNumber"];
//        [dic setValue:self.mobilePhoneNumber forKey:@"mobilePhoneNumber"];
    }
    [self updateWithDictionary:dic block:block needCallback:needCallback];
}

/**
 *  更新本地缓存数据
 *
 *  @param localDic   本地的数据
 *  @param requestDic 更新请求时的数据
 *
 *  @return 替换后的数据s
 */
-(NSMutableDictionary *)updateSomeSpecialDataWithLocalData:(NSMutableDictionary *)localDic
                                               requestData:(NSMutableDictionary *)requestDic{
    //特别的数据更新
    NSDictionary *tmpDicCCcopy = [requestDic mutableCopy];
    
    [tmpDicCCcopy enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        //更新数组某个数据或者字典某个键
        if ([key rangeOfString:@"."].location != NSNotFound) {
            [self replaceElementFromArrayWithLocalData:localDic
                                           requestData:requestDic
                                                   Key:key
                                                object:obj];
            [localDic removeObjectForKey:key];
            [requestDic removeObjectForKey:key];
        }else{
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj[@"__op"] isEqualToString:@"Delete"]) {
                    //删除
                    [requestDic removeObjectForKey:key];
                    [localDic removeObjectForKey:key];
                    
                }else if([obj [@"__op"] isEqualToString:@"Increment"]) {
                    //自增自减
                    NSInteger tmpNumber = [obj [@"amount"] integerValue];
                    if ([localDic objectForKey:key] && [[localDic objectForKey:key] isKindOfClass:[NSNumber class]]){
                        NSInteger oldNumber = [[localDic objectForKey:key] integerValue];
                        NSInteger newNumber = tmpNumber + oldNumber;
                        [requestDic setObject:[NSNumber numberWithInteger:newNumber] forKey:key];
                    }else{
                        [requestDic setObject:[NSNumber numberWithInteger:tmpNumber] forKey:key];
                    }
                }else if([obj [@"__op"] isEqualToString:@"Add"]) {
                    //数组增加
                    NSArray  *tmpArray = obj [@"objects"];
                    if (tmpArray.count > 0) {
                        NSArray  *oldArray = [localDic objectForKey:key];
                        NSMutableArray *newArray = [NSMutableArray arrayWithArray:oldArray];
                        for (int i = 0; i < tmpArray.count ; i ++) {
                            [newArray addObject:tmpArray[i]];
                        }
                        [requestDic setObject:newArray forKey:key];
                    }
                }else if([obj [@"__op"] isEqualToString:@"AddUnique"]){
                    //数组增加唯一的数据
                    NSArray  *tmpArray = obj [@"objects"];
                    if (tmpArray.count > 0) {
                        NSArray  *oldArray = [localDic objectForKey:key];
                        NSMutableArray *newArray = [NSMutableArray arrayWithArray:oldArray];
                        for (int i = 0; i < tmpArray.count ; i ++) {
                            if (![newArray containsObject:tmpArray[i]]) {
                                [newArray addObject:tmpArray[i]];
                            }
                        }
                        [requestDic setObject:newArray forKey:key];
                    }
                }else if([obj [@"__op"] isEqualToString:@"Remove"]) {
                    //数组删除数据
                    NSArray  *tmpArray = obj [@"objects"];
                    NSArray  *oldArray = [localDic objectForKey:key];
                    if (oldArray && oldArray.count > 0 && tmpArray.count > 0) {
                        NSMutableArray *newArray = [NSMutableArray arrayWithArray:oldArray];
                        for (int i = 0; i < tmpArray.count ; i ++) {
                            if([newArray containsObject:tmpArray[i]]){
                                [newArray removeObject:tmpArray[i]];
                            }
                        }
                        [requestDic setObject:newArray forKey:key];
                    }
                }
            }
        }
    }];
    
    //更改authData 内容
    for (NSString *key in [requestDic allKeys]) {
        if ([key isEqualToString:@"authData"]) {
            NSMutableDictionary *_2ndDic = [NSMutableDictionary dictionary];
            if (localDic [@"authData"]) {
                [_2ndDic setDictionary:localDic [@"authData"]];
            }
            if (requestDic [@"authData"]) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:requestDic[@"authData"]];
                for (NSString *authDataKey in [dic allKeys]) {
                    [_2ndDic setObject:[dic objectForKey:authDataKey] forKey:authDataKey];
                }
            }
            [localDic setObject:_2ndDic forKey:@"authData"];
        } else{
            [localDic setObject:[requestDic objectForKey:key] forKey:key];
        }
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:localDic];
    return dic;
}

//更新数组中的某个位置的元素 或者字典的某个元素
-(void)replaceElementFromArrayWithLocalData:(NSMutableDictionary *)localDic
                                requestData:(NSMutableDictionary *)requestDic
                                        Key:(NSString *)key
                                     object:(id )obj {
    NSArray *keyArray = [key componentsSeparatedByString:@"."];
    NSString *middleString = keyArray[1];
    NSString *localKey = keyArray[0];
    
    if (localDic[localKey]) {
        if ([localDic[localKey] isKindOfClass:[NSDictionary class]]) {
            [self replaceDictionaryObjcetWithLocalData:localDic
                                                object:obj
                                             updateKey:middleString
                                              localKey:localKey
                                           localKeyDic:localDic[localKey]];
            
        }else if([localDic[localKey] isKindOfClass:[NSArray class]]){
            [self replaceArrayObjcetWithLocalData:localDic
                                         keyArray:keyArray
                                           object:obj
                                    localKeyArray:localDic[localKey]];
        }
        
    }else{
        //中间的字符串是数字就认定为数组，否则是字典
        if ([BCommonUtils isNumber:middleString]) {
            [self replaceArrayObjcetWithLocalData:localDic
                                         keyArray:keyArray
                                           object:obj
                                    localKeyArray:[NSArray array]];
        }else{
            
            [self replaceDictionaryObjcetWithLocalData:localDic
                                                object:obj
                                             updateKey:middleString
                                              localKey:localKey
                                           localKeyDic:[NSDictionary dictionary]];
        }
        
    }
    
    
    
    
    
}

/**
 *  更新字典里面的对应的键值对
 *
 *  @param localDic  本地数据
 *  @param obj       请求更新的数据
 *  @param updateKey 字典里要更新的key
 *  @param localKey  列名
 *  @param keyDic    列的值
 */
-(void)replaceDictionaryObjcetWithLocalData:(NSMutableDictionary *)localDic
                                     object:(id)obj
                                  updateKey:(NSString *)updateKey
                                   localKey:(NSString *)localKey
                                localKeyDic:(NSDictionary *)keyDic{
    //是字典
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:keyDic];
    [dic setObject:obj forKey:updateKey];
    //替换掉
    localDic[localKey] = dic;
}

/**
 *  更新对应键对应位置的值
 *
 *  @param localDic      本地数据
 *  @param keyArray      键分解成的数组
 *  @param obj           请求更新的数据
 *  @param localKey      列名
 *  @param localKeyArray 列的值
 */
-(void)replaceArrayObjcetWithLocalData:(NSMutableDictionary *)localDic
                              keyArray:(NSArray *)keyArray
                                object:(id)obj
                         localKeyArray:(NSArray *)localKeyArray{
    NSString *localKey = keyArray[0];
    //是数组
    NSMutableArray *array = [NSMutableArray arrayWithArray:localKeyArray];
    int position = [keyArray[1] intValue];
    if (keyArray.count == 2) {
        //超过数组界限
        if (position + 1 > array.count ) {
            NSUInteger count = position - array.count;
            for (int i = 0; i < count; ++i) {
                [array addObject:[NSNull null]];
            }
            [array addObject:obj];
            localDic[localKey] = array;
        }else{
            //不超过数组界限
            [array replaceObjectAtIndex:position withObject:obj];
            localDic[localKey] = array;
        }
    }else if (keyArray.count == 3){
        NSString *key = keyArray[2];
        if (position + 1 > array.count ) {
            //超过数组界限
            NSUInteger count = position - array.count;
            for (int i = 0; i < count; ++i) {
                [array addObject:[NSNull null]];
            }
            NSDictionary *dic = @{key:obj};
            [array addObject:dic];
            localDic[localKey] = array;
        }else{
            
            //不超过数组界限
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:localDic[localKey][position]] ;
            [dic setObject:obj forKey:key];
            
            [array replaceObjectAtIndex:position withObject:dic];
            localDic[localKey] = array;
        }
        
        
    }
}

-(void)updateWithDictionary:(NSDictionary *)dataDictionary
                      block:(BmobBooleanResultBlock)block
               needCallback:(BOOL)needCallback{
    
    
    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
    
    //更新的数据内容
    if (dataDictionary) {
        [tmpDic setDictionary:dataDictionary];
    }
    //去掉重要信息
    if (tmpDic [@"sessionToken"]) {
        [tmpDic removeObjectForKey:@"sessionToken"];
    }
    if (tmpDic [@"updatedAt"]) {
        [tmpDic removeObjectForKey:@"updatedAt"];
    }
    if (tmpDic [@"createdAt"]) {
        [tmpDic removeObjectForKey:@"createdAt"];
    }
    if (tmpDic [@"objectId"]) {
        [tmpDic removeObjectForKey:@"objectId"];
    }
    if (tmpDic [@"_id"]) {
        [tmpDic removeObjectForKey:@"_id"];
    }
    
    NSDictionary *tmpDicCopy = [tmpDic copy];
    [tmpDicCopy enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            if ([obj [@"__type"] isEqualToString:@"Relation"]) {
                [tmpDic removeObjectForKey:key];
            }
        }
    }];
    
    //key的内容一样，就不传
    NSString *filePath = [[BCommonUtils filePath] stringByAppendingPathComponent:@"current.archive"];
    if ([[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *uDic  = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:filePath]];
        for (NSString *key in [uDic allKeys]) {
            if ([tmpDic objectForKey:key]) {
                if ([[tmpDic objectForKey:key] isEqual:[uDic objectForKey:key]]) {
                    [tmpDic removeObjectForKey:key];
                }
            }
        }
    }else if ([[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] isKindOfClass:[NSString class]]){
        NSString *filepath          = [[BCommonUtils filePath] stringByAppendingPathComponent:@"current.archive"];
        NSString *dataString        = [BEncryptUtil decodeBase64String:[NSKeyedUnarchiver unarchiveObjectWithFile:filepath] ];
        NSData  *data               = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *tmpDic1 = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil] ];
        NSMutableDictionary *uDic   = [NSMutableDictionary dictionary];
        if ([[[tmpDic1 objectForKey:@"r"] objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
            [uDic setDictionary:[[tmpDic1 objectForKey:@"r"] objectForKey:@"data"]];
        }
        for (NSString *key in [uDic allKeys]) {
            if ([tmpDic objectForKey:key]) {
                if ([[tmpDic objectForKey:key] isEqual:[uDic objectForKey:key]]) {
                    [tmpDic removeObjectForKey:key];
                }
            }
        }
    }
    
    
    NSMutableDictionary  *requestDic = [NSMutableDictionary dictionaryWithDictionary:[BRequestDataFormat requestDictionaryWithClassname:kUserTable data:tmpDic objectId:self.objectId]];
    NSString *token = [BCommonUtils sessionToken];
    if (token) {
        
        requestDic[@"sessionToken"]  = token;
    }
    
    NSString *userSignUpUrl          = [[SDKAPIManager defaultAPIManager] updateInterface];
    
    BHttpClientUtil *requestUtil  = [BHttpClientUtil requestUtilWithUrl:userSignUpUrl];
    
    __weak typeof(BHttpClientUtil*) weakRequest     = requestUtil;
    [weakRequest addParameter:requestDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     
                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                         NSDictionary *updateDic = dictionary;
                         if (updateDic && updateDic.count > 0) {
                             if ([[[updateDic objectForKey:@"result"] objectForKey:@"code"] intValue] == 200) {
                                 NSString *filePath = [[BCommonUtils filePath] stringByAppendingPathComponent:@"current.archive"];
                                 if ([[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] isKindOfClass:[NSDictionary class]]) {
                                     NSMutableDictionary *uDic  = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:filePath]];
                                     if ([BCommonUtils isNotNilOrNull:[updateDic  objectForKey:@"data"]]) {
                                         NSString *updatedAtString = [[[updateDic  objectForKey:@"data"] objectForKey:@"updatedAt"] description];
                                         NSMutableDictionary *newUserDic = [self updateSomeSpecialDataWithLocalData:uDic requestData:tmpDic];
                                         //存储本地
                                         [newUserDic setObject:updatedAtString forKey:@"updatedAt"];
                                         if (newUserDic && newUserDic.count > 0) {
                                             [NSKeyedArchiver archiveRootObject:newUserDic toFile:filePath];
                                         }
                                         
                                         //                                         self.userDic = newUserDic;
                                         //                                         [self setSelfDataDictionary:self.userDic];
                                         
                                         [self setValue:newUserDic forKey:kDataDicKey];
                                         [BmobUser removeSomeObjectForKeys:self];
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (needCallback) {
                                                 if (block) {
                                                     block(YES,nil);
                                                 }
                                             }
                                         });
                                         
                                     }else{
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (block) {
                                                 NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                                 block(NO,error);
                                             }
                                         });
                                     }
                                     
                                 }else if ([[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] isKindOfClass:[NSString class]]) {
                                     
                                     NSString *filepath = [[BCommonUtils filePath] stringByAppendingPathComponent:@"current.archive"];
                                     NSString *dataString = [BEncryptUtil decodeBase64String:[NSKeyedUnarchiver unarchiveObjectWithFile:filepath] ];
                                     NSData  *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
                                     //本地字典
                                     NSMutableDictionary *tmpDic1 = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil] ];
                                     NSMutableDictionary *uDic  = [NSMutableDictionary dictionary];
                                     if ([[[tmpDic1 objectForKey:@"r"] objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                                         [uDic setDictionary:[[tmpDic1 objectForKey:@"r"] objectForKey:@"data"]];
                                     }
                                     NSMutableDictionary *newUserDic = [self updateSomeSpecialDataWithLocalData:uDic requestData:tmpDic];
                                     if (newUserDic && newUserDic.count > 0) {
                                         [NSKeyedArchiver archiveRootObject:newUserDic toFile:filePath];
                                     }
                                     //                                     self.userDic = newUserDic;
                                     //                                     [self setSelfDataDictionary:self.userDic];
                                     [self setValue:newUserDic forKey:kDataDicKey];
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (needCallback) {
                                             if (block) {
                                                 block(YES,nil);
                                             }
                                         }
                                     });
                                     
                                 }
                             }else{
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (needCallback) {
                                         if (block) {
                                             NSError *error = [BCommonUtils errorWithResult:updateDic];
                                             
                                             block(NO,error);
                                         }
                                         
                                     }
                                 });
                             }
                         }else{
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if (needCallback) {
                                     if (block) {
                                         NSError *error = [BCommonUtils errorWithType:BmobErrorTypeUnknownError];
                                         block(NO,error);
                                     }
                                 }
                             });
                             
                         }
                     });
                     
                     
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


-(void)deleteInBackground{
    
    if (!self.objectId) {
        return;
    }
    
    [self deleteInBackgroundWithBlock:nil callback:NO];
}


-(void)deleteInBackgroundWithBlock:(BmobBooleanResultBlock)block{
    
    if (!self.objectId) {
        if (block) {
            NSError *error = [BCommonUtils errorWithType:BmobErrorTypeNullObjectId];
            block(NO,error);
        }
        
    }
    else {
        [self deleteInBackgroundWithBlock:block callback:YES];
    }
}


-(void)deleteInBackgroundWithBlock:(BmobBooleanResultBlock)block callback:(BOOL)needCallback{
    
    if ([self valueForKey:kDataDicKey]) {
        [[self valueForKey:kDataDicKey] removeAllObjects];
        
    }
    
    NSMutableDictionary  *requestDic = [NSMutableDictionary dictionaryWithDictionary:[BRequestDataFormat requestDictionaryWithClassname:kUserTable data:nil objectId:self.objectId]];
    NSString *token = [BCommonUtils sessionToken];
    if (token) {
        requestDic[@"sessionToken"]  = token;
    }
    
    NSString *deleteUrl          = [[SDKAPIManager defaultAPIManager] deleteInterface];
    BHttpClientUtil *requestUtil = [BHttpClientUtil requestUtilWithUrl:deleteUrl];
    [requestUtil addParameter:requestDic
                 successBlock:^(NSDictionary *dictionary, NSError *error) {
                     NSDictionary *deleteDic = dictionary;
                     if (deleteDic && deleteDic.count > 0) {
                         if ([deleteDic [@"result"][@"code"] intValue] == 200) {
                             if (needCallback) {
                                 if (block) {
                                     block(YES,nil);
                                 }
                             }
                         }
                         else{
                             if (needCallback) {
                                 if (block) {
                                     NSError *error = [BCommonUtils errorWithResult:deleteDic];
                                     block(NO,error);
                                 }
                                 
                             }
                         }
                     }
                     else{
                         if (needCallback) {
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

+(void)savaUserMsgLocol:(NSDictionary*)responseDic{
    NSMutableDictionary *tmpDic        = [NSMutableDictionary dictionary];
    //保存sessionToken在本地存储
    NSString    *sessionToken          = [responseDic[@"data"] objectForKey:@"sessionToken"];
    [[NSUserDefaults standardUserDefaults] setObject:sessionToken forKey:kBmobSessionToken];
    
    //其它信息保存在文件中
    [tmpDic setDictionary:responseDic[@"data"]];
    [tmpDic removeObjectForKey:@"sessionToken"];
    [NSKeyedArchiver archiveRootObject:tmpDic toFile:[self currentUserFilePath]];
}

+(BmobUser*)constructBmobUser:(NSDictionary*)responseDic{
    BmobUser *buser = nil;
    
    if ([responseDic  [@"data"] isKindOfClass:[NSDictionary class]]) {
        buser = [[[self class] alloc] initWithDictionary:responseDic[@"data"]];
        buser.className = kUserTable;
        [buser setValue:responseDic [@"data"] forKey:kDataDicKey];
    }
    
    //去掉这些属性
    [BmobUser removeSomeObjectForKeys:buser];
    return buser;
}

-(NSString *)description{
    NSMutableString *bmobObjectDescription = [[NSMutableString alloc] initWithCapacity:1];
    NSString *className = [NSString stringWithFormat:@"\nclassName = %@;\n",self.className];
    NSString *userName = [NSString stringWithFormat:@"\nusername = %@;\n",self.username];
    NSString *mobilePhoneNumber = [NSString stringWithFormat:@"\nmobilePhoneNumber = %@;\n",self.mobilePhoneNumber];
    NSString *email = [NSString stringWithFormat:@"\nemail = %@;\n",self.email];
    NSString *objectId = [NSString stringWithFormat:@"objectId = %@;\n",self.objectId];
    NSString *createdAt = [NSString stringWithFormat:@"createdAt = %@;\n",self.createdAt];
    NSString *updatedAt = [NSString stringWithFormat:@"updatedAt = %@;\n",self.updatedAt];
    
    NSString *date = [NSString stringWithFormat:@"data = %@;",[self valueForKey:kDataDicKey]];
    
    [bmobObjectDescription appendString:className];
    [bmobObjectDescription appendString:userName];
    [bmobObjectDescription appendString:mobilePhoneNumber];
    [bmobObjectDescription appendString:email];
    [bmobObjectDescription appendString:objectId];
    [bmobObjectDescription appendString:createdAt];
    [bmobObjectDescription appendString:updatedAt];
    [bmobObjectDescription appendString:date];
    return bmobObjectDescription;
}

@end
