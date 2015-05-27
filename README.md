# CKFMDBHelper
---

##这是什么

基于Mantle的Model，简化FMDB操作，可以通过面向对象的方式操作数据库

##如何使用
###表操作
```
	//创建表
    [CKTestModel createTable];
    //创建索引
    [CKTestModel createIndex:@"testIndex" unique:YES columns:@"index",@"name",nil];
    //删除索引
    [CKTestModel dropIndex:@"testIndex"];
    //创建索引
    [CKTestModel createIndex:@"testIndex" unique:YES columnDict:@{@"index":kCKModelIndexAsc,@"lastName":kCKModelIndexDesc}];
    //表结构更新，更新到最新结构
    [CKTestModel updateColumn];

```
###数据库操作
##### 查询语句 
```
    NSArray *array = [CKTestModel queryWithConditions:^id(CKConditionMaker *maker) {
        return maker.where(@"index = 1").and(@"index = 1").orderBy(@"[index]",CKOrderByAsc).limit(0,1);
    }];
    NSLog(@"%@",array);
    
	NSArray *_array = [CKTestModel query:^id(CKQueryMaker *maker) {
        return maker.count(nil).max(@"index",nil).min(@"lastName",nil);
    } withConditions:^id(CKConditionMaker *maker) {
        return maker.where(@"index = 1").and(@"index = 1").orderBy(@"[index]",CKOrderByAsc).limit(0,1);
    }];
    NSLog(@"%@",_arra);
```
##### 插入语句
```
    CKTestModel *model1 = [CKTestModel new];
    model1.index = 1;
    model1.name = @"222";
    model1.lastName = @"333";
    [CKTestModel insertWithArray:@[model1]];
    NSArray *array2 = [CKTestModel queryWithConditions:NULL];
    NSLog(@"%@",array2);
```
或者

```
    CKTestModel *model1 = [CKTestModel new];
    model1.index = 1;
    model1.name = @"222";
    model1.lastName = @"333";
    [model1 insert];
    NSArray *array2 = [CKTestModel queryWithConditions:NULL];
    NSLog(@"%@",array2);

```
同理，还有删、改、replace等，操作基本相同
