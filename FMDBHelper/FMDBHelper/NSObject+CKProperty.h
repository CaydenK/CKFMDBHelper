//
//  NSObject+CKProperty.h
//  FMDBHelper
//
//  Created by caydenk on 15/5/19.
//  Copyright (c) 2015年 caydenk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (CKProperty)

/**
 *  获取属性列表
 *
 *  @return 属性列表
 */
+ (NSArray *)propertyArray;

/**
 *  获取属性集合
 *
 *  @return 属性集合
 */
+ (NSSet *)propertySet;
/**
 *  属性字典，key为属性名称，value是数组，属性的编译属性列表
 *
 *  @return 属性字典
 */
+ (NSDictionary *)propertyDict;

/**
 *  获取属性列表
 *
 *  @return 属性列表
 */
- (NSArray *)propertyArray;

/**
 *  获取属性集合
 *
 *  @return 属性集合
 */
- (NSSet *)propertySet;
/**
 *  属性字典，key为属性名称，value是数组，属性的编译属性列表
 *
 *  @return 属性字典
 */
- (NSDictionary *)propertyDict;

@end
