//
//  CKFuckMaker.h
//  FMDBHelper
//
//  Created by caydenk on 15/5/22.
//  Copyright (c) 2015年 caydenk. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  条件排序
 */
typedef NS_ENUM(NSUInteger, CKConditionMakerOrderByType){
    /**
     *  正序
     */
    CKOrderByAsc = 1,
    /**
     *  倒序
     */
    CKOrderByDesc = 0,
};

/**
 *  条件基类
 */
@interface CKBaseMaker : NSObject

/**
 *  创建对象
 *
 *  @param cls model类型
 *
 *  @return 条件Maker
 */
+ (instancetype)newWithModelClass:(Class)cls;
/**
 *  初始化对象
 *
 *  @param cls model类型
 *
 *  @return 条件maker
 */
- (instancetype)initWithModelClass:(Class)cls;

@end


/**
 *  查询条件
 */
@interface CKConditionMaker : CKBaseMaker

/**
 *  组合的条件语句
 */
@property (nonatomic, copy) NSString *sqlCondition;

/**
 *  where子句
 */
- (CKConditionMaker * (^)(NSString *))where;
/**
 *  与运算
 */
- (CKConditionMaker * (^)(NSString *))and;
/**
 *  或运算
 */
- (CKConditionMaker * (^)(NSString *))or;
/**
 *  包含于运算
 */
- (CKConditionMaker * (^)(NSArray *))in;
/**
 *  模糊查询
 */
- (CKConditionMaker * (^)(NSString *))like;
/**
 *  排序
 */
- (CKConditionMaker * (^)(NSString *orderKey, CKConditionMakerOrderByType orderType))orderBy;
/**
 *  界限
 */
- (CKConditionMaker * (^)(NSInteger location, NSInteger count))limit;

@end

@interface CKQueryMaker : CKBaseMaker

@property (nonatomic, strong) NSMutableDictionary *sqlQueryDict;

/**
 *  个数
 */
- (CKQueryMaker * (^)(NSString *))count;
/**
 *  最大值
 */
- (CKQueryMaker * (^)(NSString *,NSString *))max;
/**
 *  最小值
 */
- (CKQueryMaker *(^)(NSString *,NSString *))min;
/**
 *  平均值
 */
- (CKQueryMaker *(^)(NSString *,NSString *))avg;
/**
 *  求和
 */
- (CKQueryMaker *(^)(NSString *,NSString *))sum;
/**
 *  字母转大写
 */
- (CKQueryMaker *(^)(NSString *,NSString *))upper;
/**
 *  字母转小写
 */
- (CKQueryMaker *(^)(NSString *,NSString *))lower;
/**
 *  字段长度
 */
- (CKQueryMaker *(^)(NSString *,NSString *))length;
/**
 *  自定义列查询
 */
- (CKQueryMaker *(^)(NSString *,...))columns;

@end
