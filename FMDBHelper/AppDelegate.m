//
//  AppDelegate.m
//  FMDBHelper
//
//  Created by caydenk on 15/5/19.
//  Copyright (c) 2015年 caydenk. All rights reserved.
//

#import "AppDelegate.h"
#import "CKFMDBHelper.h"
#import "CKTestModel.h"
#import "CKManager.h"
#import "CKTestSubModel.h"

@class AAModel;
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[CKManager shareManager].dbPath] == NO) {
        [CKTestModel createTable];
        [CKTestModel createIndex:@"testIndex" unique:YES columns:@"index",@"name",nil];
        [CKTestModel dropIndex:@"testIndex"];
        [CKTestModel createIndex:@"testIndex" unique:YES columnDict:@{@"index":kCKModelIndexAsc,@"name":kCKModelIndexDesc}];
//        [CKTestModel createIndex:@"testIndex" unique:YES columns:@"index",@"lastName",nil];
        [CKTestModel updateColumn];
    }

    NSArray *array = [CKTestModel queryWithConditions:^id(CKConditionMaker *maker) {
        return maker.where(@"index = 1").and(@"index = 1").orderBy(@"[index]",CKOrderByAsc).limit(0,1);
    }];
    NSLog(@"%@",array);
    
    CKTestModel *model1 = [CKTestModel new];
    model1.index = (id)@1;
    model1.name = @"222";
    model1.lastName = @"333";
    [model1 insert];
    
    [model1 setValuesFromDictionary:@{@"ind":@1234,@"ac":@"nameValue",@"bbb":@"lastNameValue",@"ccc":@"indexValue"}];
    NSLog(@"%@",[CKTestSubModel propertyDict]);
    
    [CKTestModel insertWithArray:@[model1]];
    NSArray *array2 = [CKTestModel queryWithConditions:NULL];
    NSLog(@"%@",array2);
    
    model1.name = @"修改后的name";
    [CKTestModel updateWithArray:@[model1] conditions:^id(CKConditionMaker *maker) {
        return maker.where(@"[index] = 1").and(@"lastName = 333");
    }];
    NSArray *array3 = [CKTestModel queryWithConditions:NULL];
    NSLog(@"%@",array3);
    
    
    model1.name = @"再次修改后的值";
    [CKTestModel replaceWithArray:@[model1]];
    NSArray *array4 = [CKTestModel queryWithConditions:NULL];
    NSLog(@"%@",array4);
    
    NSArray *_array = [CKTestModel query:^id(CKQueryMaker *maker) {
        return maker.count(nil).max(@"index",nil).min(@"lastName",nil);
    } withConditions:^id(CKConditionMaker *maker) {
        return maker.where(@"index = 1").and(@"index = 1").orderBy(@"[index]",CKOrderByAsc).limit(0,1);
    }];
    NSLog(@"%@",_array);
    
    [model1 delete];
    NSArray *array6 = [CKTestModel queryWithConditions:NULL];
    NSLog(@"%@",array6);
    
    NSArray *array7 = [CKTestModel queryDictArrayWithSql:@"select * from CKTestModel"];
    NSLog(@"%@",array7);
    
    
    return YES;
}

//- (void)aaa:(NSString *)a,... bbb:(NSString *)b,...{
//    
//}

@end
