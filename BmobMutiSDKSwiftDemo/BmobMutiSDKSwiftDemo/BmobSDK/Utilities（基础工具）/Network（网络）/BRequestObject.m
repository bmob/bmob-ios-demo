//
//  BRequestObject.m
//  BmobSDK
//
//  Created by Bmob on 15-2-3.
//  Copyright (c) 2015年 Bmob. All rights reserved.
//

#import "BRequestObject.h"




@implementation BRequestObject
@synthesize success = _success;
@synthesize fail    = _fail;
@synthesize url     = _url;
@synthesize para    = _para;
@synthesize state   = _state;
@synthesize rid     = _rid;

//返回BrequestObject方法，这里似乎没必要这么写
+(instancetype)requestObject{
    BRequestObject *request = [[BRequestObject alloc] init];
    return request;
}

@end
