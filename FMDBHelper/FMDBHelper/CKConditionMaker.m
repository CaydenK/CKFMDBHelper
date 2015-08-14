//
//  CKFuckMaker.m
//  FMDBHelper
//
//  Created by caydenk on 15/5/22.
//  Copyright (c) 2015年 caydenk. All rights reserved.
//

#import "CKConditionMaker.h"
#import "NSObject+CKProperty.h"

@interface CKBaseMaker ()

@property (nonatomic, unsafe_unretained) Class cls;

@end

@implementation CKBaseMaker

+ (instancetype)newWithModelClass:(Class)cls{
    CKConditionMaker *maker = [self new];
    maker.cls = cls;
    return maker;
}
- (instancetype)initWithModelClass:(Class)cls{
    self = [super init];
    if (self) {
        _cls = cls;
    }
    return self;
}

/**
 *  sql关键字替换
 *
 *  @param item 关键字字句
 *  @param cls  类型
 *
 *  @return 替换后的语句
 */
NSString *sqlKeywordsReplace(NSString *item, Class cls){
    NSString *value = item.copy;
    NSArray *propertyArray = [cls propertyArray];
    for (NSString *property in propertyArray) {
        NSRange range = [value rangeOfString:property];
        NSRange range2 = [value rangeOfString:[NSString stringWithFormat:@"[%@]",property]];
        if (range.location != NSNotFound && range2.location == NSNotFound) {
            value = [value stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"[%@]",property]];
        }
    }
    return value;
}

/**
 *  排序枚举映射
 *
 *  @param type 类型
 *
 *  @return 正序/倒序
 */
NSString *conditionMakerMap(CKConditionMakerOrderByType type){
    if (type == CKOrderByAsc) {
        return @"asc";
    }
    else{
        return @"desc";
    }
}

- (void)dealloc
{
    _cls = nil;
}

@end

@implementation CKConditionMaker

- (CKConditionMaker * (^)(NSString *))where{
    /**
     *  where 条件
     *
     *  @param item 条件
     *
     *  @return CKConditionMaker
     */
    return ^CKConditionMaker *(NSString *item) {
        self.sqlCondition = [self.sqlCondition stringByAppendingFormat:@" where %@",sqlKeywordsReplace(item, self.cls)];
        return self;
    };
}
- (CKConditionMaker * (^)(NSString *))and{
    /**
     *  where 的 and字句
     *
     *  @param item 条件
     *
     *  @return CKConditionMaker
     */
    return ^CKConditionMaker *(NSString *item) {
        self.sqlCondition = [self.sqlCondition stringByAppendingFormat:@" and %@",sqlKeywordsReplace(item, self.cls)];
        return self;
    };
}
- (CKConditionMaker *(^)(NSString *))or{
    /**
     *  where 的or字句
     *
     *  @param item 条件
     *
     *  @return CKConditionMaker
     */
    return ^CKConditionMaker *(NSString *item) {
        self.sqlCondition = [self.sqlCondition stringByAppendingFormat:@" or %@",sqlKeywordsReplace(item, self.cls)];
        return self;
    };
}
/**
 *  包含于运算
 */
- (CKConditionMaker * (^)(NSArray *))in{
    /**
     *  where 的in字句
     *
     *  @param items 内容列表
     *
     *  @return CKConditionMaker
     */
    return ^CKConditionMaker *(NSArray *items) {
        self.sqlCondition = [self.sqlCondition stringByAppendingFormat:@" in (%@)",sqlKeywordsReplace([items componentsJoinedByString:@","], self.cls)];
        return self;
    };
}

- (CKConditionMaker *(^)(NSString *))like{
    /**
     *  模糊查询
     *
     *  @param item 模糊方式
     *
     *  @return CKConditionMaker
     */
    return ^CKConditionMaker *(NSString *item) {
        self.sqlCondition = [self.sqlCondition stringByAppendingFormat:@" like %@",sqlKeywordsReplace(item, self.cls)];
        return self;
    };
}
- (CKConditionMaker * (^)(NSString *orderKey, CKConditionMakerOrderByType orderType))orderBy{
    /**
     *  @param orderKey  排序字段
     *  @param orderType 正序/倒序
     *
     *  @return CKConditionMaker
     */
    return ^CKConditionMaker *(NSString *orderKey, CKConditionMakerOrderByType orderType) {
        self.sqlCondition = [self.sqlCondition stringByAppendingFormat:@" order by %@ %@",sqlKeywordsReplace(orderKey, self.cls),conditionMakerMap(orderType)];
        return self;
    };
}
- (CKConditionMaker * (^)(NSInteger location, NSInteger count))limit{
    /**
     *  @param location 位置
     *  @param count    个数
     *
     *  @return CKConditionMaker
     */
    return ^CKConditionMaker *(NSInteger location, NSInteger count) {
        self.sqlCondition = [self.sqlCondition stringByAppendingFormat:@" limit %ld,%ld",(long)location,(long)count];
        return self;
    };
}

#pragma mark
#pragma mark - Get
- (NSString *)sqlCondition{
    if (_sqlCondition == nil) {
        _sqlCondition = @"";
    }
    return _sqlCondition;
}

@end

@implementation CKQueryMaker

- (CKQueryMaker * (^)(NSString *))count{
    /**
     *  获取个数
     *
     *  @param alias 别名
     *
     *  @return CKQueryMaker
     */
    return ^CKQueryMaker *(NSString *alias) {
        [self.sqlQueryDict setObject:alias?:NSStringFromSelector(_cmd) forKey:@"count(0)"];
        return self;
    };
}
- (CKQueryMaker *(^)(NSString *,NSString *))max{
    /**
     *  最大值函数
     *
     *  @param column 字段名
     *  @param alias  别名
     *
     *  @return CKQueryMaker
     */
    return ^CKQueryMaker *(NSString *column,NSString *alias) {
        [self.sqlQueryDict setObject:alias?:NSStringFromSelector(_cmd) forKey:[NSString stringWithFormat:@"max(%@)",sqlKeywordsReplace(column, self.cls)]];
        return self;
    };
}
- (CKQueryMaker *(^)(NSString *,NSString *))min{
    /**
     *  最小值函数
     *
     *  @param column 字段名
     *  @param alias  别名
     *
     *  @return CKQueryMaker
     */
    return ^CKQueryMaker *(NSString *column,NSString *alias) {
        [self.sqlQueryDict setObject:alias?:NSStringFromSelector(_cmd) forKey:[NSString stringWithFormat:@"min(%@)",sqlKeywordsReplace(column, self.cls)]];
        return self;
    };
}
- (CKQueryMaker *(^)(NSString *,NSString *))avg{
    /**
     *  平均值函数
     *
     *  @param column 字段名
     *  @param alias  别名
     *
     *  @return CKQueryMaker
     */
    return ^CKQueryMaker *(NSString *column,NSString *alias) {
        [self.sqlQueryDict setObject:alias?:NSStringFromSelector(_cmd) forKey:[NSString stringWithFormat:@"avg(%@)",sqlKeywordsReplace(column, self.cls)]];
        return self;
    };
}
- (CKQueryMaker *(^)(NSString *,NSString *))sum{
    /**
     *  求和函数
     *
     *  @param column 字段名
     *  @param alias  别名
     *
     *  @return CKQueryMaker
     */
    return ^CKQueryMaker *(NSString *column,NSString *alias) {
        [self.sqlQueryDict setObject:alias?:NSStringFromSelector(_cmd) forKey:[NSString stringWithFormat:@"sum(%@)",sqlKeywordsReplace(column, self.cls)]];
        return self;
    };
}
- (CKQueryMaker *(^)(NSString *,NSString *))upper{
    /**
     *  转大写字母
     *
     *  @param column 字段名
     *  @param alias  别名
     *
     *  @return CKQueryMaker
     */
    return ^CKQueryMaker *(NSString *column,NSString *alias) {
        [self.sqlQueryDict setObject:alias?:NSStringFromSelector(_cmd) forKey:[NSString stringWithFormat:@"upper(%@)",sqlKeywordsReplace(column, self.cls)]];
        return self;
    };
}
- (CKQueryMaker *(^)(NSString *,NSString *))lower{
    /**
     *  转小写字母
     *
     *  @param column 字段名
     *  @param alias  别名
     *
     *  @return CKQueryMaker
     */
    return ^CKQueryMaker *(NSString *column,NSString *alias) {
        [self.sqlQueryDict setObject:alias?:NSStringFromSelector(_cmd) forKey:[NSString stringWithFormat:@"min(%@)",sqlKeywordsReplace(column, self.cls)]];
        return self;
    };
}
- (CKQueryMaker *(^)(NSString *,NSString *))length{
    /**
     *  长度
     *
     *  @param column 字段名
     *  @param alias  别名
     *
     *  @return CKQueryMaker
     */
    return ^CKQueryMaker *(NSString *column,NSString *alias) {
        [self.sqlQueryDict setObject:alias?:NSStringFromSelector(_cmd) forKey:[NSString stringWithFormat:@"length(%@)",sqlKeywordsReplace(column, self.cls)]];
        return self;
    };
}
/**
 *  自定义列查询
 */
- (CKQueryMaker *(^)(NSString *,...))columns {
    return ^CKQueryMaker *(NSString *column,...) {
        NSMutableArray *columnArray = @[[NSString stringWithFormat:@"[%@]",column]].mutableCopy;
        va_list list;
        va_start(list, column);
        while (1)
        {
            NSString *item = va_arg(list, NSString *);
            if (item == nil) {break;}
            [columnArray addObject:[NSString stringWithFormat:@"[%@]",item]];
        }
        va_end(list);
        NSString *columnComp = [columnArray componentsJoinedByString:@","];
        [self.sqlQueryDict setObject:columnComp forKey:@""];
        return self;
    };
}

#pragma mark
#pragma mark - Get
- (NSMutableDictionary *)sqlQueryDict{
    if (_sqlQueryDict == nil) {
        _sqlQueryDict = @{}.mutableCopy;
    }
    return _sqlQueryDict;
}

@end


