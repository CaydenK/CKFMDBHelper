# CKFMDBHelper
---

##这是什么

对FMDB的封装，以面向对象的方式操作数据库，并且对服务器model的支持，模型、字典、json相互转换，并提供字段映射

##如何使用

###Model创建
```
#import "CKModel.h"

@interface CKTestModel : CKModel

@property (nonatomic, copy) NSNumber<CKPrimaryKey> *index;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *lastName;

@end
```

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
    model1.index = (id)@1;
    model1.name = @"222";
    model1.lastName = @"333";
    [model1 insert];
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

##### mapping
```
#import "CKModel.h"
#import "CKTest.h"

@interface CKTestModel : CKModel<CKFmdbJsonSerializing>

@property (nonatomic, copy) NSNumber<CKPrimaryKey> *index;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) CKTest   *test;

@end


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

    CKTestModel *model1 = [CKTestModel new];    
    [model1 setValuesFromDictionary:@{@"ind":@1234,@"ac":@"nameValue",@"bbb":@"lastNameValue",@"ccc":@"indexValue"}];


```

####字典表的支持
表是否已经创建不用在意，直接赋值，就会自动创建，然后尽管取值就行了，而且不用担心速度慢，都会直接异步操作好数据库

```
    CKDictionary *dict = [CKDictionary shareInstance];
    if (!dict[@"key"]) {
        [dict setObject:@"value" forKey:@"key"];
    }
    NSLog(@"%@",dict[@"key"]);

```
