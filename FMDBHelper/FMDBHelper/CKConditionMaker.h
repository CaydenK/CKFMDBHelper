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

@interface CKConditionMaker : NSObject

@property (nonatomic, copy) NSString *sqlCondition;
+ (instancetype)newWithModelClass:(Class)cls;
- (instancetype)initWithModelClass:(Class)cls;

- (CKConditionMaker * (^)(NSString *))where;
- (CKConditionMaker * (^)(NSString *))and;
- (CKConditionMaker * (^)(NSString *))or;
- (CKConditionMaker * (^)(NSString *))like;
- (CKConditionMaker * (^)(NSString *orderKey, CKConditionMakerOrderByType orderType))orderBy;
- (CKConditionMaker * (^)(NSInteger location, NSInteger count))limit;



@end
