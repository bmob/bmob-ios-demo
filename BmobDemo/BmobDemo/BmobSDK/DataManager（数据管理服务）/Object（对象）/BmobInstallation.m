//
//  BmobInstallation.m
//  BmobSDK
//
//  Created by Bmob on 14-4-25.
//  Copyright (c) 2014年 Bmob. All rights reserved.
//

#import "BmobInstallation.h"
#import "BCommonUtils.h"
#import "BmobQuery.h"

@interface BmobInstallation() {

}

//@property (nonatomic,readwrite,copy) NSString *deviceType;
@end

@implementation BmobInstallation

@synthesize badge       = _badge;
@synthesize channels    = _channels;
@synthesize deviceToken = _deviceToken;
@synthesize deviceType  = _deviceType;

static NSString  *kInstallationTable = @"_Installation";

-(id)init{
    self = [super initWithClassName:kInstallationTable];
    if (self) {
        _badge = 0;
        _deviceType = [@"ios" copy];
    }
    
    return self;
}

-(id)initWithClassName:(NSString *)className{
    
    self = [super initWithClassName:kInstallationTable];
    
    if (self) {
        _badge = 0;
        _deviceType = [@"ios" copy];
    }
    
    return self;
}

+(instancetype)objectWithClassName:(NSString *)className {
    BmobInstallation *installation = [[[self class] alloc] initWithClassName:nil];
    return installation;
}

+(instancetype)objectWithoutDataWithClassName:(NSString*)className objectId:(NSString *)objectId {
    BmobInstallation *installation = [[[self class] alloc] initWithClassName:nil];
    installation.objectId = objectId;
    return installation ;
}


//查询installation表
+(BmobQuery *)query{
    BmobQuery *installationQuery = [BmobQuery queryWithClassName:kInstallationTable];
    return installationQuery;
}

+(instancetype)installation{
    BmobInstallation*   install = [[[self class] alloc] initWithClassName:kInstallationTable];
    
    return install ;
}

+(instancetype)currentInstallation{
    return [self installation];
}

- (void)setDeviceTokenFromData:(NSData *)deviceTokenData{
    NSString* deviceTokenString = [BCommonUtils hexStringFromData:deviceTokenData];
    self.deviceToken = deviceTokenString ;
    [self setObject:deviceTokenString forKey:@"deviceToken"];
}

-(void)subsccribeToChannels:(NSArray*)channels{
    [self addUniqueObjectsFromArray:channels forKey:@"channels"];
}
-(void)unsubscribeFromChannels:(NSArray*)channels{
    [self removeObjectsInArray:channels forKey:@"channels"];
}

-(void)setAppInfo{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString*  appName    = [infoDic objectForKey:@"CFBundleDisplayName"];
    NSString*  appVersion = [infoDic objectForKey:@"CFBundleVersion"];
    NSString*  pageName   = [infoDic objectForKey:@"CFBundleIdentifier"];
    NSString*  timeZone   = [[NSTimeZone systemTimeZone] name];
    
    [self setObject:@"ios" forKey:@"deviceType"];
//    [super setObject:pageName forKey:@"appIdentifiter"];
    [self setObject:pageName forKey:@"appIdentifier"];
    [self setObject:appName forKey:@"appName"];
    [self setObject:appVersion forKey:@"appVersion"];
    [self setObject:timeZone forKey:@"timeZone"];
    [self setObject:kBmobSDKVersion forKey:@"BmobVersion"];
    [self setObject:[NSNumber numberWithInt:self.badge] forKey:@"badge"];
    
    if (self.channels) {
        [self setObject:self.channels forKey:@"channels"];
    }
    
}



-(void)saveInBackground{
    
    [self setAppInfo];
    [super saveInBackground ];
    
}

-(void)saveInBackgroundWithResultBlock:(BmobBooleanResultBlock)block{
    [self setAppInfo];
    [super saveInBackgroundWithResultBlock:block];
}



-(void)deleteInBackground{

}

-(void)deleteInBackgroundWithBlock:(BmobBooleanResultBlock)block{

}



-(void)dealloc{
    _badge       = 0;
   
    _channels = nil;
    
    _deviceType = nil;
    
    _deviceToken = nil;
//    self.channels    = nil;
//    self.deviceType  = nil;
//    self.deviceToken = nil;
}


@end
