//
//  BmobACL.m
//  BmobSDK
//
//  Created by Bmob on 14-5-9.
//  Copyright (c) 2014年 Bmob. All rights reserved.
//

#import "BmobACL.h"
#import "BmobUser.h"
#import "BmobRole.h"
@interface BmobACL(){

}

@property(nonatomic,strong) NSMutableDictionary *aclDictionary;



@end


@implementation BmobACL

@synthesize aclDictionary = _aclDictionary;


-(id)init{
    self = [super init];
    if (self) {
    }
    
    return self;
}



+(instancetype)ACL{
    
    BmobACL *acl = [[[self class] alloc] init];
    
    return acl;
}

-(NSMutableDictionary*)aclDictionary{
    if (!_aclDictionary) {
        _aclDictionary = [[NSMutableDictionary alloc] init];
    }
    return _aclDictionary;
}

-(NSDictionary*)aclDic{
    
    return self.aclDictionary;
}



-(void)dealloc{

   _aclDictionary = nil;
    

}

#pragma mark set method

-(void)setPublicReadAccess:(BOOL)allowed{
    NSDictionary *tmpDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:allowed] forKey:@"read"];
    NSString *key = @"*";
    if (tmpDic) {
        [self setDictionary:tmpDic forKey:key];
    }
}
- (void)setPublicWriteAccess:(BOOL)allowed{
   NSDictionary *tmpDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:allowed] forKey:@"write"];
    
    NSString *key = @"*";
    if (tmpDic) {
        [self setDictionary:tmpDic forKey:key];
    }
}

- (void)setReadAccess:(BOOL)allowed forUserId:(NSString *)userId{
    if (userId) {
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:allowed] forKey:@"read"];
        NSString *key = userId;
        if (tmpDic) {
           [self setDictionary:tmpDic forKey:key];
        }
    }
}


- (void)setWriteAccess:(BOOL)allowed forUserId:(NSString *)userId{
    if (userId) {
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:allowed] forKey:@"write"];
        NSString *key = userId;
        if (tmpDic) {
            [self setDictionary:tmpDic forKey:key];
        }
    }
}

- (void)setReadAccess:(BOOL)allowed forUser:(BmobUser *)user{
    if (user) {
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:allowed] forKey:@"read"];
        NSString *key = user.objectId;
        if (tmpDic) {
            [self setDictionary:tmpDic forKey:key];
        }
    }
}
- (void)setWriteAccess:(BOOL)allowed forUser:(BmobUser *)user{
    if (user) {
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:allowed] forKey:@"write"];
        NSString *key = user.objectId;
        if (tmpDic) {
            [self setDictionary:tmpDic forKey:key];
        }
    }
}
- (void)setReadAccess:(BOOL)allowed forRoleWithName:(NSString *)name{
    if (name) {
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:allowed] forKey:@"read"];
        NSString *key = [NSString stringWithFormat:@"role:%@",name];
        if (tmpDic) {
           [self setDictionary:tmpDic forKey:key];
        }
    }
}
- (void)setWriteAccess:(BOOL)allowed forRoleWithName:(NSString *)name{
    if (name) {
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:allowed] forKey:@"write"];
        NSString *key = [NSString stringWithFormat:@"role:%@",name];
        if (tmpDic) {
           [self setDictionary:tmpDic forKey:key];
        }
    }
}
- (void)setReadAccess:(BOOL)allowed forRole:(BmobRole *)role{
    if (role) {
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:allowed] forKey:@"read"];
        NSString *key = [NSString stringWithFormat:@"role:%@",role.name];
        if (tmpDic) {
           [self setDictionary:tmpDic forKey:key];
        }
    }
}
- (void)setWriteAccess:(BOOL)allowed forRole:(BmobRole *)role{
    if (role) {
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:allowed] forKey:@"write"];
        NSString *key = [NSString stringWithFormat:@"role:%@",role.name];
        if (tmpDic) {
           [self setDictionary:tmpDic forKey:key];
        }
    }
}

-(void)setDictionary:(NSDictionary *)tmpDic forKey:(NSString *)key{
    //如果aclDictionary里面有这个key的值，那么把内容取出来，新建个临时变量存储该内容，再把新添加的内容添加上去
    if ([self.aclDictionary objectForKey:key]) {
        NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:[self.aclDictionary objectForKey:key]];
        for (NSString *key1 in [tmpDic allKeys]) {
            [mutableDic setObject:tmpDic[key1] forKey:key1];
        }
        [self.aclDictionary setObject:mutableDic forKey:key];
    }else{
        [self.aclDictionary setObject:tmpDic forKey:key];
    }
}


//-(void)setWriteDictionary:(NSDictionary *)tmpDic forKey:(NSString *)key{
//    if ([self.aclDictionary objectForKey:key]) {
//        NSMutableDictionary *mutableDic = [self.aclDictionary objectForKey:key];
//        mutableDic[@"write"] = [NSNumber numberWithBool:allowed];
//        [self.aclDictionary setObject:mutableDic forKey:key];
//    }else{
//        [self.aclDictionary setObject:tmpDic forKey:key];
//    }
//}


- (void)setPublicReadAccess{
    [self setPublicReadAccess:YES];
}

- (void)setPublicWriteAccess{
    [self setPublicWriteAccess:YES];
}

- (void)setReadAccessForUserId:(NSString *)userId{
    [self setReadAccess:YES forUserId:userId];
}

- (void)setWriteAccessForUserId:(NSString *)userId{
    [self setWriteAccess:YES forUserId:userId];
}

- (void)setReadAccessForUser:(BmobUser *)user{
    [self setReadAccess:YES forUser:user];
}

- (void)setWriteAccessForUser:(BmobUser *)user{
    [self setWriteAccess:YES forUser:user];
}


- (void)setReadAccessForRoleWithName:(NSString *)name{
    [self setReadAccess:YES forRoleWithName:name];
}

- (void)setWriteAccessForRoleWithName:(NSString *)name{
    [self setWriteAccess:YES forRoleWithName:name];
}

- (void)setReadAccessForRole:(BmobRole *)role{
    [self setReadAccess:YES forRole:role];
}

- (void)setWriteAccessForRole:(BmobRole *)role{
    [self setWriteAccess:YES forRole:role];
}


#pragma mark get method


@end
