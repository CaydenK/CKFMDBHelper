//
//  CKTestModel.m
//  FMDBHelper
//
//  Created by caydenk on 15/5/22.
//  Copyright (c) 2015年 caydenk. All rights reserved.
//

#import "CKTestModel.h"

@implementation CKTestModel

+ (NSDictionary *)jsonKeyPathMapping{
    return @{
             @"index":@"ind",
             @"name":@"ac",
             @"lastName":@"bbb",
             @"test.index":@"ccc",
             };
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _test = [CKTest new];
    }
    return self;
}

@end
