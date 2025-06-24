//
//  BmobRole.m
//  BmobSDK
//
//  Created by Bmob on 14-5-9.
//  Copyright (c) 2014年 Bmob. All rights reserved.
//

#import "BmobRole.h"
#import "BmobQuery.h"
#import "BmobACL.h"

@implementation BmobRole

@synthesize name = _name;

static NSString *kRoleTable = @"_Role";

-(id)init{
    self = [super init];
    if (self) {
        self.className = kRoleTable;
    }
    return self;
}

-(id)initWithClassName:(NSString *)className{
    self = [super initWithClassName:kRoleTable];
    if (self) {

    }
    
    return self;
}




-(instancetype)initWithName:(NSString *)name{
    
    self = [super initWithClassName:kRoleTable];
    if (self) {
        if (name) {
            _name = [name copy];
        }
        
    }
    return self;
}
- (instancetype)initWithName:(NSString *)name acl:(BmobACL *)acl{
    self = [super initWithClassName:kRoleTable];
    if (self) {
        if (name) {
            _name = [name copy];
        }
    }
    return self;
}


+(instancetype)objectWithoutDataWithClassName:(NSString *)className objectId:(NSString *)objectId{
    BmobRole *role = [[[self class] alloc] initWithClassName:kRoleTable];
    role.objectId = objectId;
    return role ;
}



-(void)dealloc{
    _name = nil;
   
}

+ (instancetype)roleWithName:(NSString *)name{
    BmobRole *role = [[BmobRole alloc] initWithName:name];
    return role ;
}

+ (instancetype)roleWithName:(NSString *)name acl:(BmobACL *)acl{
    BmobRole *role = [[BmobRole alloc] initWithName:name];
    return role ;
}

+ (BmobQuery *)query{
    BmobQuery *query = [BmobQuery queryWithClassName:kRoleTable];
    return query;
}


-(void)setUpName{
    if (self.name && [self.name length] > 0) {
        [self setObject:self.name forKey:@"name"];
    }
}

-(void)saveInBackground{
    [self setUpName];
    [super saveInBackground];
}

-(void)saveInBackgroundWithResultBlock:(BmobBooleanResultBlock)block{
    [self setUpName];
    [super saveInBackgroundWithResultBlock:block];
}

-(void)updateInBackground{
    [self setUpName];
    [super updateInBackground];
}

-(void)updateInBackgroundWithResultBlock:(BmobBooleanResultBlock)block{
    [self setUpName];
    [super updateInBackgroundWithResultBlock: block];
}

-(void)addUsersRelation:(BmobRelation*)relation{
    [super addRelation:relation forKey:@"users"];
}
-(void)addRolesRelation:(BmobRelation*)relation{
    [super addRelation:relation forKey:@"roles"];
}

@end
