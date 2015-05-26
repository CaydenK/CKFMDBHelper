//
//  CKFuckMaker.h
//  FMDBHelper
//
//  Created by tcyx on 15/5/22.
//  Copyright (c) 2015年 tcyx. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CKConditionMakerOrderByType) {
    CKOrderByAsc = 1,
    CKOrderByDesc = 0,
};

@interface CKBaseMaker : NSObject

+ (instancetype)newWithModelClass:(Class)cls;
- (instancetype)initWithModelClass:(Class)cls;

@end

@interface CKConditionMaker : CKBaseMaker

@property (nonatomic, copy) NSString *sqlCondition;

- (CKConditionMaker * (^)(NSString *))where;
- (CKConditionMaker * (^)(NSString *))and;
- (CKConditionMaker * (^)(NSString *))or;
- (CKConditionMaker * (^)(NSString *))like;
- (CKConditionMaker * (^)(NSString *orderKey, CKConditionMakerOrderByType orderType))orderBy;
- (CKConditionMaker * (^)(NSInteger location, NSInteger count))limit;

@end

@interface CKQueryMaker : CKBaseMaker

@property (nonatomic, strong) NSMutableDictionary *sqlQueryDict;

- (CKQueryMaker * (^)(NSString *))count;
- (CKQueryMaker * (^)(NSString *,NSString *))max;
- (CKQueryMaker *(^)(NSString *,NSString *))min;
- (CKQueryMaker *(^)(NSString *,NSString *))avg;
- (CKQueryMaker *(^)(NSString *,NSString *))sum;
- (CKQueryMaker *(^)(NSString *,NSString *))upper;
- (CKQueryMaker *(^)(NSString *,NSString *))lower;
- (CKQueryMaker *(^)(NSString *,NSString *))length;

@end
