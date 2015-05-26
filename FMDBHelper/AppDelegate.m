//
//  AppDelegate.m
//  FMDBHelper
//
//  Created by tcyx on 15/5/19.
//  Copyright (c) 2015年 tcyx. All rights reserved.
//

#import "AppDelegate.h"
#import "CKFMDBHelper.h"
#import "CKTestModel.h"


@class AAModel;
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    [CKTestModel createTable];
//    [CKTestModel createIndex:@"testIndex" Unique:YES Columns:@"index",@"name",nil];
//    [CKTestModel dropIndex:@"testIndex"];
//    [CKTestModel createIndex:@"fuckIndex" Unique:YES ColumnDict:@{@"index":kCKModelIndexAsc,@"name":kCKModelIndexDesc}];
//    [CKTestModel createIndex:@"fuckindex" Unique:YES Columns:@"index",@"lastName",nil];
//    [CKTestModel updateColumn];

    NSArray *array = [CKTestModel queryWithConditions:^id(CKConditionMaker *maker) {
        return maker.where(@"index = 1").and(@"index = 1").orderBy(@"[index]",CKOrderByAsc).limit(0,1);
    }];
    NSLog(@"%@",array);
    NSLog(@"%@",[array.firstObject valueForKey:@"index"]);
    
    CKTestModel *model1 = [CKTestModel new];
    model1.index = 1;
    model1.name = @"222";
    model1.lastName = @"333";
    [CKTestModel insertWithArray:@[model1]];
    NSArray *array2 = [CKTestModel queryWithConditions:NULL];
    NSLog(@"%@",array2);
    
    model1.name = @"修改后的name";
    [CKTestModel updateWithArray:@[model1] Conditions:^id(CKConditionMaker *maker) {
        return maker.where(@"[index] = 1").and(@"lastName = 333");
    }];
    NSArray *array3 = [CKTestModel queryWithConditions:NULL];
    NSLog(@"%@",array3);
    
    
    model1.name = @"再次修改后的值";
    [CKTestModel replaceWithArray:@[model1]];
    NSArray *array4 = [CKTestModel queryWithConditions:NULL];
    NSLog(@"%@",array4);
    
    [model1 delete];
    NSArray *array5 = [CKTestModel queryWithConditions:NULL];
    NSLog(@"%@",array5);
    

    
    return YES;
}

@end
