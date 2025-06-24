//
//  BmobRelation.m
//  BmobSDK
//
//  Created by Bmob on 14-4-16.
//  Copyright (c) 2014年 Bmob. All rights reserved.
//

#import "BmobRelation.h"



@interface BmobRelation(){
    
    BOOL                _isAddObject;
    NSMutableString     *_key;

}


@property (nonatomic,strong) NSMutableArray*  relationArray;

@end;


@implementation BmobRelation
@synthesize relationArray = _relationArray;

-(id)init{
    self = [super init];
    if (self) {
        _isAddObject = YES;
    }
    
    return self;
}

+(instancetype)relation{
    BmobRelation *reltaion = [[[self class] alloc] init];
    return reltaion;
}

-(NSMutableArray *)relationArray{
    if (!_relationArray) {
        _relationArray = [[NSMutableArray alloc] init];
    }
    
    return _relationArray;
}


-(NSArray*)bRelationArray{
    return self.relationArray;
}

-(BOOL)addOrRemoveRelation{
    return _isAddObject;
}


-(void)addObject:(BmobObject *)object{
    
    if (!_isAddObject) {
        [self.relationArray removeAllObjects];
    }
    
    NSDictionary   *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer", @"__type",object.className,@"className",object.objectId,@"objectId", nil];
    [self.relationArray addObject:dic];
    
     _isAddObject = YES;
}


-(void)removeObject:(BmobObject *)object{
    
    if (_isAddObject) {
        [self.relationArray removeAllObjects];
    }
    
    NSDictionary   *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer", @"__type",object.className,@"className",object.objectId,@"objectId", nil];
    [self.relationArray addObject:dic];
    _isAddObject = NO;
}

-(void)dealloc{
    
    _relationArray = nil;
    
}

@end
