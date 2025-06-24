//
//  BmobTableScheme.m
//  BmobSDK
//
//  Created by limao on 15/7/24.
//  Copyright (c) 2015年 donson. All rights reserved.
//

#import "BmobTableSchema.h"

@implementation BmobTableSchema

-(instancetype)init{
    
    return [self initWithBmobTableSchemaDic:nil];
}

-(instancetype)initWithBmobTableSchemaDic:(NSDictionary*)bmobTableSchemaDic{
    self = [super init];
    if (self) {
        _className = [bmobTableSchemaDic objectForKey:@"className"];
        NSMutableDictionary *fieldsFromBmobTableSchemas = [bmobTableSchemaDic objectForKey:@"fields"];
        _fields = fieldsFromBmobTableSchemas;
    }
    return self;
}

-(NSString *)description{
    NSMutableString *bmobObjectDescription = [[NSMutableString alloc] initWithCapacity:1];
    NSString *className = [NSString stringWithFormat:@"\nclassName = %@;\n",self.className];
    NSString *fields = [NSString stringWithFormat:@"fields = %@;\n",self.fields];

    
    [bmobObjectDescription appendString:className];
    [bmobObjectDescription appendString:fields];
    return bmobObjectDescription;
}



@end
