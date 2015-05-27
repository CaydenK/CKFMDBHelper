//
//  CKModel.m
//  FMDBHelper
//
//  Created by tcyx on 15/5/19.
//  Copyright (c) 2015年 tcyx. All rights reserved.
//

#import "CKModel.h"
#import "CKFMDBHelper.h"
#import "FMDB.h"
#import "NSObject+CKProperty.h"
#import "CKManager.h"
#import "NSString+CKDB.h"


/**
 *  正序
 */
static const NSString *kCKModelIndexAsc = @"asc";
/**
 *  倒序
 */
static const NSString *kCKModelIndexDesc = @"desc";

@interface CKModel ()

@end

@implementation CKModel

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
    NSArray *propertyArray = [[self class] propertyArray];
    NSMutableString *sql = [NSMutableString stringWithFormat:@"create table if not exists '%@' ( ",tableName];
    for (NSString *property in propertyArray) {
        [sql appendFormat:@"'%@' text default '' not null,",property];
    }
    if (propertyArray.count > 0) {
        [sql deleteCharactersInRange:NSMakeRange(sql.length-1, 1)];
    }
    [sql appendFormat:@");"];
    [self executeUpdateWithSql:sql];
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
    NSMutableString *query = [NSMutableString stringWithFormat:@"PRAGMA  table_info(%@)",tableName];
    FMDatabase *db = [[CKManager shareManager] databaseWithName:CKDBNAME];
    if (![db open]) {return;}
    FMResultSet *rs=[db executeQuery:query];
    NSMutableArray *oldColumnArray=[NSMutableArray array];
    while ([rs next]) {
        [oldColumnArray addObject:[rs stringForColumn:@"name"]];
    }
    [db close];
    NSMutableArray *propertyArray = [self propertyArray].mutableCopy;
    [propertyArray removeObjectsInArray:oldColumnArray];
    NSMutableArray *sqls = @[].mutableCopy;
    for (NSString *columnNew in propertyArray) {
        NSString *sql = [NSString stringWithFormat:@"alter table %@ add column '%@' text;",tableName,columnNew];
        [sqls addObject:sql];
    }
    [self executeUpdateWithMuchSql:sqls];
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




@end

