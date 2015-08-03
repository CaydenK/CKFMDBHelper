//
//  CKModel.m
//  FMDBHelper
//
//  Created by caydenk on 15/5/19.
//  Copyright (c) 2015年 caydenk. All rights reserved.
//

#import "CKModel.h"
#import "CKFMDBHelper.h"
#import "FMDB.h"
#import "NSObject+CKProperty.h"
#import "CKManager.h"
#import "NSString+CKDB.h"
#import "NSDictionary+CKExternal.h"
#import <objc/runtime.h>

/**
 *  正序
 */
NSString * const kCKModelIndexAsc = @"asc";
/**
 *  倒序
 */
NSString * const kCKModelIndexDesc = @"desc";

@interface CKModel ()

@end

@implementation CKModel

#pragma mark
#pragma mark - CKFmdbOperate
#pragma mark
#pragma mark - Query Update
/*
 *拼装好SQL 语句，就能完成查询
 */
+ (NSMutableArray *)queryArrayWithSQL:(NSString *)sql{
    FMDatabase *db = [[CKManager shareManager] databaseWithName:CKDBNAME];
    if (![db open]) {return nil;}
    FMResultSet *rs=[db executeQuery:sql];
    NSArray *propertys=[self propertyArray];
    NSMutableArray *result=[NSMutableArray array];
    while ([rs next]) {
        id item=[[[self class] alloc]init];
        for ( NSString *key in propertys) {
            [item setValue:[rs stringForColumn:key]?:@"" forKey:key];
        }
        [result addObject:item];
    }
    [db close];
    return result;
}
/**
 *  拼装好SQL 语句，并传入Model类型就能完成查询
 *
 *  @param aQueryDict 查询字典
 *  @param sql        sql语句
 *
 *  @return 查询到的字典
 */
+ (NSArray *)queryDict:(NSDictionary *)aQueryDict withSQL:(NSString *)sql{
    FMDatabase *db = [[CKManager shareManager] databaseWithName:CKDBNAME];
    if (![db open]) {return nil;}
    FMResultSet *rs=[db executeQuery:sql];
    NSArray *keys=aQueryDict.allKeys;
    NSMutableArray *result = @[].mutableCopy;
    while ([rs next]) {
        NSMutableDictionary *resultDict=@{}.mutableCopy;
        for ( NSString *key in keys) {
            NSString *alias = [aQueryDict objectForKey:key];
            NSString *finalKey = alias.length>0?alias:key;
            [resultDict setObject:[rs stringForColumn:finalKey]?:@"" forKey:finalKey];
        }
        [result addObject:resultDict];
    }
    [db close];
    return result;
}

/*
 *拼装好SQL 语句，并传入Model类型就能完成查询
 */
+ (id)queryWithSQL:(NSString *)sql{
    FMDatabase *db = [[CKManager shareManager] databaseWithName:CKDBNAME];
    if (![db open]) {return nil;}
    FMResultSet *rs=[db executeQuery:sql];
    NSArray *propertys=[self propertyArray];
    id item;
    while ([rs next]) {
        item=[[self alloc]init];
        for ( NSString *key in propertys) {
            [item setValue:[rs stringForColumn:key]?:@"" forKey:key];
        }
    }
    [db close];
    return item;
}

/**
 *  单sql语句更新
 *
 *  @param sql sql语句
 */
+ (void)executeUpdateWithSql:(NSString *)sql{
    FMDatabaseQueue *queue = [[CKManager shareManager] databaseQueueWithName:CKDBNAME];
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:sql];
    }];
}
/**
 *  多sql语句更新
 *
 *  @param sqls sql语句数组
 */
+ (void)executeUpdateWithMuchSql:(NSArray *)sqls{
    FMDatabaseQueue *queue = [[CKManager shareManager] databaseQueueWithName:CKDBNAME];
    // 如果要支持事务
    if (!queue) {return ;}
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSString *sql in sqls) {
            [db executeUpdate:sql];
        }
    }];
}

#pragma mark
#pragma mark - get Sql
/**
 *  replace语句拼装
 *
 *  @param table 表名称
 *
 *  @return replace语句
 */
+ (NSString *)replaceSqlFromItem:(id)item{
    NSString *tableName = NSStringFromClass([self class]);
    NSArray *propertys=[item propertyArray];
    NSMutableArray *pArray = @[].mutableCopy;
    for (NSString *property in propertys) {
        [pArray addObject:[NSString stringWithFormat:@"[%@]",property]];
    }
    NSString *columsStr=[pArray componentsJoinedByString:@","];
    NSMutableArray *columnValueArray=[NSMutableArray array];
    for (NSString *property in propertys) {
        NSString *value=[NSString stringWithFormat:@"%@",[item valueForKey:property]?:@""];
        [columnValueArray addObject:[value chuliyinhao]];
    }
    NSString *columnValueStr=[columnValueArray componentsJoinedByString:@","];
    NSString *replaceSql=[NSString stringWithFormat:@"replace into %@ (%@ ) VALUES (%@)",tableName,columsStr,columnValueStr];
    return replaceSql;
}
/**
 *  insert语句拼装
 *
 *  @param item  Model
 *
 *  @return insert语句
 */
+ (NSString *)insertSqlFromItem:(id)item{
    NSString *tableName = NSStringFromClass([self class]);
    NSArray *propertys=[item propertyArray];
    NSMutableArray *pArray = @[].mutableCopy;
    for (NSString *property in propertys) {
        [pArray addObject:[NSString stringWithFormat:@"[%@]",property]];
    }
    NSString *columsStr=[pArray componentsJoinedByString:@","];
    NSMutableArray *columnValueArray=[NSMutableArray array];
    for (NSString *property in propertys) {
        NSString *value=[NSString stringWithFormat:@"%@",[item valueForKey:property]?:@""];
        [columnValueArray addObject:[value chuliyinhao]];
    }
    NSString *columnValueStr=[columnValueArray componentsJoinedByString:@","];
    NSString *replaceSql=[NSString stringWithFormat:@"insert into %@ (%@ ) VALUES (%@)",tableName,columsStr,columnValueStr];
    return replaceSql;
}
/**
 *  update语句拼装
 *
 *  @param table 表名称
 *
 *  @return update语句
 */
+ (NSString *)updateSqlFromItem:(id)item{
    NSString *tableName = NSStringFromClass([self class]);
    NSArray *propertys=[item propertyArray];
    NSMutableArray *columnArray=[NSMutableArray array];
    for (NSString *property in propertys) {
        NSString *value=[NSString stringWithFormat:@"%@",[item valueForKey:property]?:@""];
        [columnArray addObject:[NSString stringWithFormat:@"[%@] = %@",property,[value chuliyinhao]]];
    }
    NSString *columnStr=[columnArray componentsJoinedByString:@","];
    NSString *replaceSql=[NSString stringWithFormat:@"update %@ set %@",tableName,columnStr];
    return replaceSql;
}
/**
 *  delete语句拼装
 *
 *  @param table 表名称
 *
 *  @return delete语句
 */
+ (NSString *)deleteSqlFromItem:(id)item{
    NSString *tableName = NSStringFromClass([self class]);
    NSArray *propertys=[item propertyArray];
    NSMutableArray *columnArray=[NSMutableArray array];
    for (NSString *property in propertys) {
        NSString *value=[NSString stringWithFormat:@"%@",[item valueForKey:property]?:@""];
        [columnArray addObject:[NSString stringWithFormat:@"[%@] = %@",property,[value chuliyinhao]]];
    }
    NSString *columnStr=[columnArray componentsJoinedByString:@" and "];
    NSString *replaceSql=[NSString stringWithFormat:@"delete from %@ where %@",tableName,columnStr];
    return replaceSql;
}

#pragma mark
#pragma mark - Create
/**
 *  创建表
 *
 *  @return 成功/失败
 */
+ (void)createTable{
    NSString *tableName = NSStringFromClass([self class]);
    NSDictionary *propertyDict = [[self class] propertyDict];
    NSArray *propertyArray = [propertyDict allKeys];
    NSMutableString *sql = [NSMutableString stringWithFormat:@"create table if not exists '%@' ( ",tableName];
    for (NSString *property in propertyArray) {
        NSArray *attributes = [propertyDict objectForKey:property];
        [sql appendFormat:@"'%@' %@ not null,",property,[self isPrimaryKey:attributes]?@"integer primary key default 0":@"text default ''"];
    }
    if (propertyArray.count > 0) {
        [sql deleteCharactersInRange:NSMakeRange(sql.length-1, 1)];
    }
    [sql appendFormat:@");"];
    [self executeUpdateWithSql:sql];
}
+ (BOOL)isPrimaryKey:(NSArray *)attributes{
    for (NSString *str in attributes) {
        if ([str rangeOfString:@"<CKPrimaryKey>"].length>0) {
            return YES;
        }
    }
    return NO;
}

/**
 *  创建索引
 *
 *  @param indexName 索引名称
 *  @param isUnique  是否唯一
 *  @param column    字段列表
 *
 *  @return 是否成功
 */
+ (void)createIndex:(NSString *)indexName unique:(BOOL)isUnique columns:(NSString *)column,...{
    if (column == nil) {return;}
    NSString *tableName = NSStringFromClass([self class]);
    NSMutableString *sql = [NSMutableString stringWithFormat:@"create %@ index '%@' on '%@' (",isUnique?@"unique":@"",indexName,tableName];
    
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
    [sql appendFormat:@"%@);",columnComp];
    [self executeUpdateWithSql:sql];
}
/**
 *  创建索引
 *
 *  @param indexName   索引名称
 *  @param isUnique  是否唯一
 *  @param aColumnDict 字段列表、是否排序格式如下：
 *  @{"column1":@"asc",@"column2":@"desc"}
 *
 *  @return 是否成功
 */
+ (void)createIndex:(NSString *)indexName unique:(BOOL)isUnique columnDict:(NSDictionary *)aColumnDict{
    if (aColumnDict.count == 0) {return;}
    NSString *tableName = NSStringFromClass([self class]);
    NSMutableString *sql = [NSMutableString stringWithFormat:@"create %@ index '%@' on '%@' (",isUnique?@"unique":@"",indexName,tableName];
    NSMutableArray *columnArray = @[].mutableCopy;
    
    NSArray *keyArray = aColumnDict.allKeys;
    for (NSString *key in keyArray) {
        NSString *item = [NSString stringWithFormat:@"'%@' %@",key,[aColumnDict objectForKey:key]];
        if (item == nil) {break;}
        [columnArray addObject:item];
    }
    NSString *columnComp = [columnArray componentsJoinedByString:@","];
    [sql appendFormat:@"%@);",columnComp];
    [self executeUpdateWithSql:sql];
}

#pragma mark
#pragma mark - Drop
/**
 *  删除表
 *
 *  @return 是否成功
 */
+ (void)dropTable{
    NSString *tableName = NSStringFromClass([self class]);
    NSMutableString *sql = [NSMutableString stringWithFormat:@"drop table if exists '%@';",tableName];
    [self executeUpdateWithSql:sql];
}

/**
 *  删除索引
 *
 *  @param indexName 索引名称
 *
 *  @return 是否成功
 */
+ (void)dropIndex:(NSString *)indexName{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"drop index if exists '%@';",indexName];
    [self executeUpdateWithSql:sql];
}

#pragma mark
#pragma mark - Alert
/**
 *  修改表名
 *
 *  @param oldName 旧表名
 *
 *  @return 是否修改成功
 */
+ (void)renameTableWithOldName:(NSString *)oldName{
    NSString *tableName = NSStringFromClass([self class]);
    NSMutableString *sql = [NSMutableString stringWithFormat:@"alter table %@ rename to '%@';",oldName,tableName];
    [self executeUpdateWithSql:sql];
}
/**
 *  表结构更新到最新
 *
 *  @return 是否成功
 */
+ (void)updateColumn{
    //    一下两种方式可以获取当前表结构，当前只需知道字段列表，所以采用第二种
    //    select * from sqlite_master
    //    PRAGMA  table_info(tableName)
    NSString *tableName = NSStringFromClass([self class]);
    NSMutableArray *propertyArray = [self propertyArray].mutableCopy;
    NSArray *oldColumnArray = [self columnArrayWithTable:tableName];
    [propertyArray removeObjectsInArray:oldColumnArray];
    NSMutableArray *sqls = @[].mutableCopy;
    for (NSString *columnNew in propertyArray) {
        NSString *sql = [NSString stringWithFormat:@"alter table %@ add column '%@' text;",tableName,columnNew];
        [sqls addObject:sql];
    }
    [self executeUpdateWithMuchSql:sqls];
}

+ (NSArray *)columnArrayWithTable:(NSString *)tableName {
    NSMutableString *query = [NSMutableString stringWithFormat:@"PRAGMA  table_info(%@)",tableName];
    FMDatabase *db = [[CKManager shareManager] databaseWithName:CKDBNAME];
    if (![db open]) {return nil;}
    FMResultSet *rs=[db executeQuery:query];
    NSMutableArray *oldColumnArray=[NSMutableArray array];
    while ([rs next]) {
        [oldColumnArray addObject:[rs stringForColumn:@"name"]];
    }
    [db close];
    return oldColumnArray;
}

#pragma mark
#pragma mark - Select
/**
 *  条件查询单表
 *
 *  @param block 查询条件
 *
 *  @return Model列表
 */
+ (NSArray *)queryWithConditions:(id (^)(CKConditionMaker * maker))block{
    NSString *sqlCondition;
    if (block) {
        CKConditionMaker *make = block([CKConditionMaker newWithModelClass:[self class]]);
        sqlCondition = make.sqlCondition;
    }
    NSString *tableName = NSStringFromClass([self class]);
    NSString *sql = [NSString stringWithFormat:@"select * from '%@' %@",tableName,sqlCondition?:@""];
    return [self queryArrayWithSQL:sql];
}
/**
 *  函数查询（count()、max()等）
 *
 *  @param aQuery 函数语句
 *  @param block  条件语句
 *
 *  @return 查询结果
 */
+ (NSArray *)query:(id (^)(CKQueryMaker* maker))aQuery withConditions:(id (^)(CKConditionMaker * maker))block{
    NSString *sqlQuery,*sqlCondition;
    NSDictionary *sqlQueryDict;
    if (aQuery) {
        CKQueryMaker *make = aQuery([CKQueryMaker newWithModelClass:[self class]]);
        sqlQueryDict = make.sqlQueryDict;
        NSMutableArray *tmpQueryArray = @[].mutableCopy;
        NSArray *keys = sqlQueryDict.allKeys;
        for (NSString *key in keys) {
            NSString *value = sqlQueryDict[key];
            NSString *query = [NSString stringWithFormat:@"%@ %@",key,value];
            [tmpQueryArray addObject:query];
        }
        sqlQuery = [tmpQueryArray componentsJoinedByString:@","];
    }
    if (block) {
        CKConditionMaker *make = block([CKConditionMaker newWithModelClass:[self class]]);
        sqlCondition = make.sqlCondition;
    }
    NSString *tableName = NSStringFromClass([self class]);
    NSString *sql = [NSString stringWithFormat:@"select %@ from '%@' %@",sqlQuery?:@"*",tableName,sqlCondition?:@""];
    return [self queryDict:sqlQueryDict withSQL:sql];
}

/**
 *  查询任意自定义语句
 *
 *  @param sql 查询语句
 *
 *  @return 查询到的字典数组
 */
+ (NSArray *)queryDictArrayWithSql:(NSString *)sql{
    FMDatabase *db = [[CKManager shareManager] databaseWithName:CKDBNAME];
    if (![db open]) {return nil;}
    FMResultSet *rs=[db executeQuery:sql];
    NSArray *keys=rs.columnNameToIndexMap.allKeys;
    NSMutableArray *result = @[].mutableCopy;
    while ([rs next]) {
        NSMutableDictionary *resultDict=@{}.mutableCopy;
        for ( NSString *key in keys) {
            [resultDict setObject:[rs stringForColumn:key]?:@"" forKey:key];
        }
        [result addObject:resultDict];
    }
    [db close];
    return result;
}

#pragma mark
#pragma mark - insert
/**
 *  多条数据插入
 *
 *  @param array 数据数组
 */
+ (void)insertWithArray:(NSArray *)array{
    NSMutableArray *sqls = @[].mutableCopy;
    for (id item in array) {
        NSString *sql = [self insertSqlFromItem:item];
        [sqls addObject:sql];
    }
    [self executeUpdateWithMuchSql:sqls];
}
/**
 *  单条数据插入
 */
- (void)insert{
    NSString *sql = [[self class] insertSqlFromItem:self];
    [[self class] executeUpdateWithSql:sql];
}
#pragma mark
#pragma mark - update
/**
 *  多数据条件更新（可设置唯一索引做唯一标识）
 *
 *  @param array 数据数组
 *  @param block 条件语句
 */
+ (void)updateWithArray:(NSArray *)array conditions:(id (^)(CKConditionMaker * maker))block{
    NSString *sqlCondition;
    if (block) {
        CKConditionMaker *make = block([CKConditionMaker newWithModelClass:[self class]]);
        sqlCondition = make.sqlCondition;
    }
    NSMutableArray *sqls = @[].mutableCopy;
    for (id item in array) {
        NSString *sql = [[[self class] updateSqlFromItem:item] stringByAppendingString:sqlCondition?:@""];
        [sqls addObject:sql];
    }
    [self executeUpdateWithMuchSql:sqls];
    
}
/**
 *  单条数据更新
 *
 *  @param block 条件语句
 */
- (void)updateWithConditions:(id (^)(CKConditionMaker * maker))block{
    NSString *sqlCondition;
    if (block) {
        CKConditionMaker *make = block([CKConditionMaker newWithModelClass:[self class]]);
        sqlCondition = make.sqlCondition;
    }
    NSString *sql = [[[self class] updateSqlFromItem:self] stringByAppendingString:sqlCondition?:@""];
    return [[self class]executeUpdateWithSql:sql];
}

#pragma mark
#pragma mark - replace
/**
 *  有则更新/无则插入语句 （多条数据）
 *
 *  @param array 数据数组
 */
+ (void)replaceWithArray:(NSArray *)array{
    NSMutableArray *sqls = @[].mutableCopy;
    for (id item in array) {
        NSString *sql = [self replaceSqlFromItem:item];
        [sqls addObject:sql];
    }
    [self executeUpdateWithMuchSql:sqls];
}
/**
 *  有则更新/无则插入语句 （单条数据）
 */
- (void)replace{
    NSString *sql = [[self class] replaceSqlFromItem:self];
    [[self class] executeUpdateWithSql:sql];
}
#pragma mark
#pragma mark - delete
/**
 *  删除多条数据（每个字段都唯一对应）
 *
 *  @param array 数据数组
 */
+ (void)deleteWithArray:(NSArray *)array{
    NSMutableArray *sqls = @[].mutableCopy;
    for (id item in array) {
        NSString *sql = [self deleteSqlFromItem:item];
        [sqls addObject:sql];
    }
    [self executeUpdateWithMuchSql:sqls];
}
/**
 *  条件删除数据
 *
 *  @param block 条件语句
 */
+ (void)deleteWithConditions:(id (^)(CKConditionMaker * maker))block{
    NSString *sqlCondition;
    if (block) {
        CKConditionMaker *make = block([CKConditionMaker newWithModelClass:[self class]]);
        sqlCondition = make.sqlCondition;
    }
    NSString *tableName = NSStringFromClass([self class]);
    NSString *sql = [[NSString stringWithFormat:@"delete from %@",tableName] stringByAppendingString:sqlCondition?:@""];
    return [[self class]executeUpdateWithSql:sql];
    
}
/**
 *  单条数据删除
 */
- (void)delete{
    NSString *sql = [[self class] deleteSqlFromItem:self];
    [[self class] executeUpdateWithSql:sql];
}

#pragma mark
#pragma mark - CKFmdbJsonOperate
/**
 *  字典转换model
 *
 *  @param dict model字典
 *
 *  @return model
 */
+ (id<CKFmdbJsonOperate>)modelWithDictionary:(NSDictionary *)dict{
    id<CKFmdbJsonOperate> item = [[self alloc]init];
    [item setValuesFromDictionary:dict];
    return item;
}
/**
 *  字典转换为数组模型
 *
 *  @param dicts 字典数组
 *
 *  @return 模型数组
 */
+ (NSArray *)modelsWithDictionarys:(NSArray *)dicts{
    NSMutableArray *array = @[].mutableCopy;
    for (NSDictionary *dict in dicts) {
        id item = [self modelWithDictionary:dict];
        [array addObject:item];
    }
    return array.copy;
}
/**
 *  模型数组转换为字典数组
 *
 *  @param models 模型数组
 *
 *  @return 字典数组
 */
+ (NSArray *)modelDictnarysWithModels:(NSArray *)models{
    NSMutableArray *array = @[].mutableCopy;
    for (id item in models) {
        [array addObject:[item modelDictionary]];
    }
    return array.copy;
}
/**
 *  模型数组转换为json
 *
 *  @param models 模型数组
 *
 *  @return json
 */
+ (NSString *)modelsJsonWithModels:(NSArray *)models{
    NSArray *array = [self modelDictnarysWithModels:models];
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}
/**
 *  根据字典赋值
 *
 *  @param dicts 模型字典
 */
- (void)setValuesFromDictionary:(NSDictionary *)dicts{
    if ([self conformsToProtocol:@protocol(CKFmdbJsonSerializing)]&&[self.class respondsToSelector:@selector(jsonKeyPathMapping)]) {
        NSDictionary *jsonKeyPathMapping = [self.class jsonKeyPathMapping];
        NSSet *propertyKeys = [self propertySet];
        for (NSString *mappedPropertyKey in jsonKeyPathMapping.allKeys) {
            id value = jsonKeyPathMapping[mappedPropertyKey];

            if ([mappedPropertyKey rangeOfString:@"."].location != NSNotFound) {
                NSArray *array = [mappedPropertyKey componentsSeparatedByString:@"."];
                if (![propertyKeys containsObject:array.firstObject]) {
                    NSAssert(NO, @"%@ is not a property of %@.", array.firstObject, self.class);
                }
            }else if (![propertyKeys containsObject:mappedPropertyKey]) {
                NSAssert(NO, @"%@ is not a property of %@.", mappedPropertyKey, self.class);
            }
            
            if ([value isKindOfClass:NSArray.class]) {
                for (NSString *keyPath in value) {
                    if ([keyPath isKindOfClass:NSString.class]) continue;
                    NSAssert(NO, @"%@ must either map to a JSON key path or a JSON array of key paths, got: %@.", mappedPropertyKey, value);
                }
            } else if (![value isKindOfClass:NSString.class]) {
                NSAssert(NO, @"%@ must either map to a JSON key path or a JSON array of key paths, got: %@.",mappedPropertyKey, value);
            }
            [self setValue:dicts[value] forKeyPath:mappedPropertyKey];
        }
    }
    else{
        NSSet *propertySet = [self propertySet];
        for (NSString *property in propertySet) {
            [self setValue:[dicts objectForKey:property] forKey:property];
        }
    }
}
/**
 *  获取模型字典
 *
 *  @return 模型字典
 */
- (NSDictionary *)modelDictionary{
    NSSet *propertySet = [self propertySet];
    NSMutableDictionary *dict = @{}.mutableCopy;
    for (NSString *property in propertySet) {
        [dict setObject:[self valueForKey:property]?:@"" forKey:property];
    }
    return dict;
}
/**
 *  获取模型json
 *
 *  @return 模型json
 */
- (NSString *)modelJson{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self modelDictionary]
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

#pragma mark
#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone{
    return [[[self class] allocWithZone:zone] initWithDictionary:self.modelDictionary];
}


#pragma mark
#pragma mark - Method

- (instancetype)initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    if (self) {
        [self setValuesFromDictionary:dict];
    }
    return self;
}

- (BOOL)isEqual:(id)object{
    if (self == object) return YES;
    if (![object isMemberOfClass:self.class]) return NO;
    
    for (NSString *key in self.class.propertyArray) {
        id selfValue = [self valueForKey:key];
        id modelValue = [object valueForKey:key];
        BOOL valuesEqual = ((selfValue == nil && modelValue == nil) || [selfValue isEqual:modelValue]);
        if (!valuesEqual) return NO;
    }
    return YES;
}

- (NSString *)description{
    return [self modelJson];
}
- (NSString *)debugDescription{
    return [NSString stringWithFormat:@"<%@:%p,%@>",[self class],self,[self modelJson]];
}
- (NSUInteger)hash {
    NSUInteger value = 0;
    for (NSString *key in self.class.propertyArray) {
        value ^= [[self valueForKey:key] hash];
    }
    return value;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ((value == nil || [[NSNull null] isEqual:value])) {
        objc_property_t property = class_getProperty([self class], [key UTF8String]);
        NSString *propertyAttribute = [NSString stringWithUTF8String:property_getAttributes(property)];
        NSArray *array = [propertyAttribute componentsSeparatedByString:@","];
        NSString *firstItem = array.firstObject;
        if ([@[@"Tq",@"Td",@"Tf",@"Ti",@"Ts",@"TQ",@"TD",@"TF",@"TI",@"TS"] containsObject:firstItem]) {
            [super setValue:@0 forKey:key];
        }
        else if ([@"Tc" isEqualToString:firstItem] || [@"TC" isEqualToString:firstItem]) {
            [super setValue:[NSNumber numberWithChar:' '] forKey:key];
        }
        else {
            Class cls = NSClassFromString([firstItem substringWithRange:NSMakeRange(3, firstItem.length - 4)]);
            id aValue = [[cls alloc]init];
            [super setValue:aValue?:@"" forKey:key];
        }
    }
    else {
        [super setValue:value forKey:key];
    }
    
}

@end

