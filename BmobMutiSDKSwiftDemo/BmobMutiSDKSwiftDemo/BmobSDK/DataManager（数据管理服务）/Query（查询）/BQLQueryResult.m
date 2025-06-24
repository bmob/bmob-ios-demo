//
//  BQLQueryResult.m
//  BmobSDK
//
//  Created by limao on 15/5/11.
//  Copyright (c) 2015年 donson. All rights reserved.
//

#import "BQLQueryResult.h"
#import "BmobObject.h"

@implementation BQLQueryResult

-(id)init{
    self = [super init];
    if (self) {
        _className = [[NSString alloc] init];
        _count = -1;
        _resultsAry = [[NSArray alloc] init];
    }
    return self;
}

-(NSString *)description{
    NSMutableString *bqlQueryResultDescription = [[NSMutableString alloc] initWithCapacity:1];
    NSString *className = [NSString stringWithFormat:@"className = %@;\n",self.className];
    
    NSArray *bmobObjectStr = nil;
    if (self.resultsAry) {
        NSString *bmobObjectArrayStr = [NSString stringWithFormat:@"bmobObjectArry = {\n%@\n}\n",[self.resultsAry description]];
        bmobObjectStr = [bmobObjectArrayStr componentsSeparatedByString:@"\\n"];
    }
    
    NSString *count = nil;
    if (self.count != -1) {
        count = [NSString stringWithFormat:@"count = %d\n",self.count];
    }
    
    [bqlQueryResultDescription appendString:className];
    
    if (bmobObjectStr) {
        for (int i = 0; i < [bmobObjectStr count];i++) {
            if (i == 0) {
                [bqlQueryResultDescription appendFormat:@"%@\n",bmobObjectStr[i]];
            } else if(i == [bmobObjectStr count] - 1){
                [bqlQueryResultDescription appendFormat:@"\t%@",bmobObjectStr[i]];
            } else {
                [bqlQueryResultDescription appendFormat:@"     %@\n",bmobObjectStr[i]];
            }
        }
    }
    
    if (count) {
        [bqlQueryResultDescription appendString:count];
    }
    
    return bqlQueryResultDescription;
}

- (BOOL)isEqual:(BQLQueryResult*)object{
    if (!object || !object.className || !object.resultsAry) {
        return NO;
    }
    
    if (![self.className isEqualToString:object.className]) {
        return NO;
    }
    
    if ([self.resultsAry count] != [object.resultsAry count]) {
        return NO;
    }
    
    for (int i = 0; i < [self.resultsAry count]; i++) {
        BmobObject *left = (BmobObject*)[self.resultsAry objectAtIndex:i];
        BmobObject *right = [object.resultsAry objectAtIndex:i];
        if (![left isEqual:right]) {
            return NO;
        }
    }
    
    return YES;
}

@end
