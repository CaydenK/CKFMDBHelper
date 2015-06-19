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
- (NSArray *)propertyArray{
    NSMutableArray *array=[NSMutableArray array];
    id itemClass = objc_getClass(object_getClassName([self class]));
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(itemClass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        [array addObject:propertyName];
    }
    return array;
}

/**
 *  获取属性集合
 *
 *  @return 属性集合
 */
- (NSSet *)propertySet{
    return [NSSet setWithArray:[self propertyArray]];
}


@end
