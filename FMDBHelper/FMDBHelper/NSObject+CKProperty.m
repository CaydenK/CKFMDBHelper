//
//  NSObject+CKProperty.m
//  FMDBHelper
//
//  Created by tcyx on 15/5/19.
//  Copyright (c) 2015年 tcyx. All rights reserved.
//

#import "NSObject+CKProperty.h"
#import <objc/message.h>

@implementation NSObject (CKProperty)

/**
 *  获取属性列表
 *
 *  @return 属性列表
 */
+ (NSArray *)propertyArray{
    NSMutableArray *array=[NSMutableArray array];
    Class itemClass = objc_getClass(object_getClassName(self));
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(itemClass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        if ([@[@"hash",@"superclass",@"description",@"debugDescription"] containsObject:propertyName]) {
            continue;
        }
        [array addObject:propertyName];
    }
    return array;
}

/**
 *  获取属性集合
 *
 *  @return 属性集合
 */
+ (NSSet *)propertySet{
    return [NSSet setWithArray:[self propertyArray]];
}

/**
 *  属性字典，key为属性名称，value是数组，属性的编译属性列表
 *
 *  @return 属性字典
 */
+ (NSDictionary *)propertyDict{
    NSMutableDictionary *dict=@{}.mutableCopy;
    Class itemClass = objc_getClass(object_getClassName(self));
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(itemClass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        NSString *propertyAttributes = [NSString stringWithUTF8String:property_getAttributes(property)];
        if ([@[@"hash",@"superclass",@"description",@"debugDescription"] containsObject:propertyName]) {
            continue;
        }
        [dict setObject:[propertyAttributes componentsSeparatedByString:@","] forKey:propertyName];
    }
    return dict;

}

/**
 *  获取属性列表
 *
 *  @return 属性列表
 */
- (NSArray *)propertyArray{
    return [[self class] propertyArray];
}

/**
 *  获取属性集合
 *
 *  @return 属性集合
 */
- (NSSet *)propertySet{
    return [NSSet setWithArray:[self propertyArray]];
}

/**
 *  属性字典，key为属性名称，value是数组，属性的编译属性列表
 *
 *  @return 属性字典
 */
- (NSDictionary *)propertyDict{
    return [[self class] propertyDict];
}




@end
