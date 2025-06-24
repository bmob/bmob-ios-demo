//
//  BmobObject+Subclass.m
//  PushDemo
//
//  Created by Bmob on 15/5/27.
//  Copyright (c) 2015年 unknown. All rights reserved.
//

#import "BmobObject+Subclass.h"
#import <objc/runtime.h>
#import "BmobQuery.h"
#import "Bmob.h"
#import <CoreData/CoreData.h>




static const void *sub_selectedArrayKey      = &sub_selectedArrayKey;

static const void *sub_ignoreArrayKey        = &sub_ignoreArrayKey;

 

@implementation BmobObject (Subclass)
@dynamic selectedKeyArray;
@dynamic ignoredKeyArray;


-(NSArray *)selectedKeyArray{
    NSArray *array = objc_getAssociatedObject(self,sub_selectedArrayKey);
    if (!array) {
        array = [[NSArray alloc] init];
        objc_setAssociatedObject(self, sub_selectedArrayKey, array, OBJC_ASSOCIATION_COPY);
    }
    return array;
}

-(void)setSelectedKeyArray:(NSArray *)selectedKeyArray{
    objc_setAssociatedObject(self, sub_selectedArrayKey, selectedKeyArray, OBJC_ASSOCIATION_COPY);
}


-(NSArray *)ignoredKeyArray{
    NSArray *array = objc_getAssociatedObject(self,sub_ignoreArrayKey);
    if (!array) {
        array = [[NSArray alloc] init];
        objc_setAssociatedObject(self, sub_ignoreArrayKey, array, OBJC_ASSOCIATION_COPY);
    }
    return array;
}

-(void)setIgnoredKeyArray:(NSArray *)ignoredKeyArray{
    objc_setAssociatedObject(self, sub_ignoreArrayKey, ignoredKeyArray, OBJC_ASSOCIATION_COPY);
}





+(BmobQuery *)query{
    
    NSString *classname = NSStringFromClass([[self class] getOriginClass:[self class]]);
    BmobQuery *query    = [BmobQuery queryWithClassName:classname];
    return query;
}



/**
 *  获取属性，将其放入dic中
 */
-(void)change{
    if (self.className.length == 0) {
        self.className = [[[self class] getOriginClass:[self class]] description];
    }
    NSArray *properties      = [self allProperties:YES];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    if (self.selectedKeyArray && self.selectedKeyArray.count > 0) {
        for (NSString *property in self.selectedKeyArray) {
            //屏蔽BmobUser的userDic
//            if ([self.className isEqualToString:@"_User"]) {
//                if (![property isEqualToString:@"userDic"]) {
//                    if ([self valueForKey:property]) {
//                        [dic setObject:[self valueForKey:property] forKey:property];
//                    }
//                }
//            }else{
                if ([self valueForKey:property]) {
                    [dic setObject:[self valueForKey:property] forKey:property];
                }
//            }
        }
    }else{
        for (NSString *property in properties) {
            //屏蔽BmobUser的userDic
//            if ([self.className isEqualToString:@"_User"]) {
//                if (![property isEqualToString:@"userDic"]) {
//                    if ([self valueForKey:property] && ![self.ignoredKeyArray containsObject:property]) {
//                        [dic setObject:[self valueForKey:property] forKey:property];
//                    }
//                }
//            }else{
                if ([self valueForKey:property] && ![self.ignoredKeyArray containsObject:property]) {
                    [dic setObject:[self valueForKey:property] forKey:property];
                }
//            }

        }
    }
    
    
    [self saveAllWithDictionary:dic];
}







//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

//更新和添加时需要将继承的子类的属性添加至data中
-(void)sub_saveInBackground{
    
    [self change];
    [self saveInBackground];
}

-(void)sub_saveInBackgroundWithResultBlock:(BmobBooleanResultBlock)block{
    [self change];
    [self saveInBackgroundWithResultBlock:block];
}

-(void)sub_updateInBackground{
    [self change];
    [self updateInBackground];
}

-(void)sub_updateInBackgroundWithResultBlock:(BmobBooleanResultBlock)block{
    [self change];
    [self updateInBackgroundWithResultBlock:block];
}

//初始化
-(instancetype)initFromBmobObject:(BmobObject *)obj {
    self=[super init];
    if (self) {
        NSMutableArray *properties = [self allProperties:NO];
        for (NSString *property in properties) {
            if (![property isEqualToString:@"updatedAt"] && ![property isEqualToString:@"createdAt"] && ![property isEqualToString:@"ACL"]) {
                if ([obj objectForKey:property]) {
                    [self setValue:[obj objectForKey:property] forKey:property];
                }
            }
        }
    }

    if ([obj objectForKey:@"ACL"]) {
        self.ACL = [BmobACL ACL];
        [self.ACL setValue:[obj valueForKey:kDataDicKey] [@"ACL"] forKey:@"aclDictionary"];
    }

    //这些值在[obj objectForKey:property]中被移除了
    self.objectId = obj.objectId;
    self.className = obj.className;
    self.updatedAt = obj.updatedAt;
    self.createdAt = obj.createdAt;
    return self;
}


+(instancetype)convertWithObject:(BmobObject *)obj;{
    return [[self alloc] initFromBmobObject:obj];
}

# pragma mark - 获取子类属性方法
/**
 *  获取类的属性
 *
 *  @param c 类名
 *
 *  @return 类的属性名称数组数组
 */
+ (NSArray *)classPropsFor:(Class)c
{
    if (c == NULL) {
        return nil;
    }
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    unsigned int outCount = 0;
    //获得一个类的所有属性的一个数组
    objc_property_t *properties = class_copyPropertyList(c, &outCount);
    NSArray *specialAttrs = [self specialTypeArray];

    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const  char *propName = property_getName(property);
        const  char *att = property_getAttributes(property);
        NSString *attrs = nil;
        if (att) {
            attrs = [NSString stringWithUTF8String:att];
        }


        NSUInteger dotLoc = [attrs rangeOfString:@","].location;
        NSString *code = nil;
        NSUInteger loc = 1;
        if (dotLoc == NSNotFound) { // 没有,
            code = [attrs substringFromIndex:loc];
        } else {
            code = [attrs substringWithRange:NSMakeRange(loc, dotLoc - loc)];
        }

        if(code && ![specialAttrs containsObject:code] && propName) {
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            [results addObject:propertyName];
        }

    }
    free(properties);
    return results;
}

/**
 *  获取所有的属性
 *
 *  @param isBmobObject 是否只取到BmobObject(不含BmobObject),
 *
 *  @return 返回属性数组
 */
-(NSMutableArray *)allProperties:(BOOL)isBmobObject{
    NSMutableArray *properties = [NSMutableArray array];
    [self getPropertiesWithClass:[self class] mutableArray:properties isBmobObject:isBmobObject];
    return properties;
}

/**
 *  获取一个类包括其子类所有的属性名称
 *
 *  @param class        类名
 *  @param array        属性名称存放的数组
 *  @param isBmobObject 是否只取到BmobObject（不含BmobObject）
 */
-(void)getPropertiesWithClass:(Class)class mutableArray:(NSMutableArray *)array isBmobObject:(BOOL)isBmobObject{
    
    if (isBmobObject) {
        if ([[self class] isClassFromBmobObject:class]) {
            return;
        }
    } else if ([[self class] isClassFromFoundation:class]) {
        return ;
    }
    
    NSMutableArray *pArray =[NSMutableArray arrayWithArray:[[self class] classPropsFor: class]] ;
    Class sclass1 = class_getSuperclass( class);
    [array addObjectsFromArray:pArray];
    
    [self getPropertiesWithClass:sclass1 mutableArray:array isBmobObject:isBmobObject];
}

/**
 *  判断某个类是否继承于BmobObject
 *
 *  @param c <#c description#>
 *
 *  @return <#return value description#>
 */
+ (BOOL)isClassFromBmobObject:(Class)c{
    NSSet *foundationClasses = [NSSet setWithObjects:
                                [BmobObject class],
                                nil];
    return [foundationClasses containsObject:c];
}

/**
 *  判断某个类是否继承于Foundation框架中的某个类
 *
 *  @param c <#c description#>
 *
 *  @return <#return value description#>
 */
+ (BOOL)isClassFromFoundation:(Class)c
{
    NSSet *foundationClasses = [NSSet setWithObjects:
                                [NSObject class],
                                [NSURL class],
                                [NSDate class],
                                [NSNumber class],
                                [NSDecimalNumber class],
                                [NSData class],
                                [NSMutableData class],
                                [NSArray class],
                                [NSMutableArray class],
                                [NSDictionary class],
                                [NSMutableDictionary class],
                               // [NSManagedObject class],
                                [NSString class],
                                [NSMutableString class], nil];
    return [foundationClasses containsObject:c];
}

/**
 *  多重继承的情况下，获取最先继承BmobObject的类的名称，因为往后的继承，其操作的表的表名应该是最先继承BmobObject的类的名称
 *
 *  @param c 当前类
 *
 *  @return 最先继承BmobObject的类
 */
+ (Class) getOriginClass:(Class)c{
    if ([[self class] isClassFromBmobObject:class_getSuperclass([c class])]) {
        return c;
    } else {
        return [[self class] getOriginClass:class_getSuperclass([c class])];
    }
}

+(NSArray *)specialTypeArray{
    NSArray *typeArray = @[@"^{objc_ivar=}",@"^{objc_method=}",@"@?",@"#",@":",@"@"];
    return typeArray;
}

@end
