//
//  CKFuckMaker.m
//  FMDBHelper
//
//  Created by tcyx on 15/5/22.
//  Copyright (c) 2015年 tcyx. All rights reserved.
//

#import "CKConditionMaker.h"
#import "NSObject+CKProperty.h"

@interface CKConditionMaker ()

@property (nonatomic, copy) Class cls;

@end

@implementation CKConditionMaker

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
- (CKConditionMaker * (^)(NSString *))where{
    return ^CKConditionMaker *(NSString *item) {
        self.sqlCondition = [self.sqlCondition stringByAppendingFormat:@" where %@",sqlKeywordsReplace(item, self.cls)];
        return self;
    };
}
- (CKConditionMaker * (^)(NSString *))and{
    return ^CKConditionMaker *(NSString *item) {
        self.sqlCondition = [self.sqlCondition stringByAppendingFormat:@" and %@",sqlKeywordsReplace(item, self.cls)];
        return self;
    };
}
- (CKConditionMaker *(^)(NSString *))or{
    return ^CKConditionMaker *(NSString *item) {
        self.sqlCondition = [self.sqlCondition stringByAppendingFormat:@" or %@",sqlKeywordsReplace(item, self.cls)];
        return self;
    };
}
- (CKConditionMaker *(^)(NSString *))like{
    return ^CKConditionMaker *(NSString *item) {
        self.sqlCondition = [self.sqlCondition stringByAppendingFormat:@" like %@",sqlKeywordsReplace(item, self.cls)];
        return self;
    };
}
- (CKConditionMaker * (^)(NSString *orderKey, CKConditionMakerOrderByType orderType))orderBy{
    return ^CKConditionMaker *(NSString *orderKey, CKConditionMakerOrderByType orderType) {
        self.sqlCondition = [self.sqlCondition stringByAppendingFormat:@" order by %@ %@",sqlKeywordsReplace(orderKey, self.cls),conditionMakerMap(orderType)];
        return self;
    };
}
- (CKConditionMaker * (^)(NSInteger location, NSInteger count))limit{
    return ^CKConditionMaker *(NSInteger location, NSInteger count) {
        self.sqlCondition = [self.sqlCondition stringByAppendingFormat:@" limit %ld,%ld",(long)location,(long)count];
        return self;
    };
}

NSString *sqlKeywordsReplace(NSString *item, Class cls){
    NSString *value = item.copy;
    NSArray *propertyArray = [cls propertyArray];
    for (NSString *property in propertyArray) {
        NSRange range = [value rangeOfString:property];
        NSRange range2 = [value rangeOfString:[NSString stringWithFormat:@"[%@]",property]];
        if (range.length > 0 && range2.length == 0) {
            value = [value stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"[%@]",property]];
        }
    }
    return value;
}

NSString *conditionMakerMap(CKConditionMakerOrderByType type){
    if (type == CKOrderByAsc) {
        return @"asc";
    }
    else{
        return @"desc";
    }
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
