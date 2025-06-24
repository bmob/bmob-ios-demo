//
//  UPHTTPBodyPart.m
//  UpYunSDK Demo
//
//  Created by 林港 on 16/1/19.
//  Copyright © 2016年 upyun. All rights reserved.
//

#import "BmobUPHTTPBodyPart.h"

@implementation BmobUPHTTPBodyPart{

    NSInputStream *_inputStream;
    unsigned long long _phaseReadOffset;
}


- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSString *)stringForHeaders {
    NSMutableString *headerString = [NSMutableString string];
    for (NSString *field in [self.headers allKeys]) {
        [headerString appendString:[NSString stringWithFormat:@"%@: %@%@", field, [self.headers valueForKey:field], kBmobAFMultipartFormCRLF]];
    }
    [headerString appendString:kBmobAFMultipartFormCRLF];
    
    return [NSString stringWithString:headerString];
}


@end
