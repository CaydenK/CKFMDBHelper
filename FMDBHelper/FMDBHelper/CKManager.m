//
//  CKManager.m
//  FMDBHelper
//
//  Created by caydenk on 15/5/19.
//  Copyright (c) 2015年 caydenk. All rights reserved.
//

#import "CKManager.h"
#import "FMDB.h"
#import <objc/runtime.h>

#import "NSObject+CKProperty.h"
#import "CKFMDBHelper.h"

#define PATH_OF_APP_HOME    NSHomeDirectory()
#define PATH_OF_TEMP        NSTemporaryDirectory()
#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define PATH_OF_CACHES      [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

static NSString const *sqliteType = @"sqlite";
static NSString const *sqliteGroup = @"Archive";

@interface CKManager (){
    NSMutableDictionary *_customerIvarDict;
}
@end

@implementation CKManager

- (NSString *)dbPath{
    return sqlitePathWithName(CKDBNAME);
}

/**
 *  获取当前单例
 *
 *  @return 当前单例
 */
+ (CKManager *)shareManager{
    static CKManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self class] new];
        instance->_customerIvarDict = @{}.mutableCopy;
    });
    return instance;
}


/**
 *  根据库名获取FMDatabase
 *
 *  @param dbName 数据库名称
 *
 *  @return FMDatabase
 */
- (FMDatabase *)databaseWithName:(NSString *)dbName{
    if (dbName.length == 0) {return nil;}
    NSString *propertyName = [NSString stringWithFormat:@"db%@",dbName];
    //propertyName 的值中，不要出现下划线 "_"，会导致set方法合成失败,crash
    [self addPropertyName:propertyName Class:[FMDatabase class]];
    FMDatabase *db = [self valueForKey:propertyName];
    if (db == nil) {
        db = [FMDatabase databaseWithPath:sqlitePathWithName(dbName)];
        [self->_customerIvarDict setObject:db forKey:propertyName];
//        [self setValue:db forKey:propertyName];
    }
    return db;
}
/**
 *  根据库名获取FMDatabaseQueue
 *
 *  @param dbName 数据库名称
 *
 *  @return FMDatabaseQueue
 */
- (FMDatabaseQueue *)databaseQueueWithName:(NSString *)dbName{
    if (dbName.length == 0) {return nil;}
    //此处请无视  //propertyName 的值中，不要出现下划线 "_"，会导致set方法合成失败,crash
    NSString *propertyName = [NSString stringWithFormat:@"queue%@",dbName];
    [self addPropertyName:propertyName Class:[FMDatabaseQueue class]];
    FMDatabaseQueue *queue = [self valueForKey:propertyName];
    if (queue == nil) {
        queue = [FMDatabaseQueue databaseQueueWithPath:sqlitePathWithName(dbName)];
        [self->_customerIvarDict setObject:queue forKey:propertyName];
//        [self setValue:queue forKey:propertyName];
    }
    return queue;
}

/**
 *  增加属性（get/set）
 *
 *  @param propertyName 属性名称
 *  @param cls          属性类型
 */
- (void)addPropertyName:(NSString *)propertyName Class:(Class)cls{
    objc_property_attribute_t type = { "T", [[NSString stringWithFormat:@"@\"%@\"",cls] UTF8String] };
    objc_property_attribute_t ownership = { "&", "N" };
    objc_property_attribute_t backingivar  = { "V", [[NSString stringWithFormat:@"_%@", propertyName] UTF8String] };
    objc_property_attribute_t attrs[] = { type, ownership, backingivar };
    if (class_addProperty([self class], [propertyName UTF8String], attrs, 3)) {
        //添加get和set方法
        class_addMethod([self class], NSSelectorFromString(propertyName), (IMP)getter, "@@:");
//        class_addMethod([self class], NSSelectorFromString([NSString stringWithFormat:@"set%@:",[propertyName capitalizedString]]), (IMP)setter, "v@:@");
    }
}


//处理get方法
id getter(id self1, SEL _cmd1) {
    NSString *key = NSStringFromSelector(_cmd1);
    Ivar ivar = class_getInstanceVariable([self1 class], "_customerIvarDict");
    NSMutableDictionary *dictCustomerProperty = object_getIvar(self1, ivar);
    return [dictCustomerProperty objectForKey:key];
}

//处理set方法
void setter(id self1, SEL _cmd1, id newValue) {
    //移除set
    NSString *key = [NSStringFromSelector(_cmd1) stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
    //首字母小写
    NSString *head = [key substringWithRange:NSMakeRange(0, 1)];
    head = [head lowercaseString];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:head];
    //移除后缀 ":"
    key = [key stringByReplacingCharactersInRange:NSMakeRange(key.length - 1, 1) withString:@""];
    Ivar ivar = class_getInstanceVariable([self1 class], "_customerIvarDict");
    NSMutableDictionary *dictCustomerProperty = object_getIvar(self1, ivar);
    object_setIvar(self1, ivar, dictCustomerProperty);
    [dictCustomerProperty setObject:newValue forKey:key];
}

//创建路径
NSString* sqlitePathWithName(NSString* name){
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *group = [NSString stringWithFormat:@"%@/%@",document,sqliteGroup];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:group]) {
        // 文件夹不存在
        // 创建文件夹
        [fm createDirectoryAtPath:group withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *path = [NSString stringWithFormat:@"%@/%@.%@",group,name,sqliteType];
    return path;
}



//以下代码暂时废弃，多库支持时，再使用

/*
+ (void)executeUpdateWithName:(NSString *)dbName
                      Operate:(void(^)(FMDatabaseQueue *queue, FMDatabase *db))operate
                   Completion:(void (^)(void))completion {
    CKManager *manager = [self  shareManager];
    NSMutableDictionary *blocks = @{}.mutableCopy;
    if (operate) {
        [blocks setObject:operate forKeyedSubscript:@"operate"];
    }
    if (completion) {
        [blocks setObject:completion forKeyedSubscript:@"completion"];
    }
    NSThread *thread = [[NSThread alloc]initWithTarget:manager selector:@selector(executeUpdateInThreadOperate:) object:blocks];
    thread.name = dbName;
    [thread start];
}
//*/

/**
 *  支线程中回调block执行任务
 *
 *  @param blocks 任务回调block/任务完成回调block
 */
/*
- (void)executeUpdateInThreadOperate:(NSDictionary *)blocks{
    void(^operate)(FMDatabaseQueue *queue, FMDatabase *db) = blocks[@"operate"];
    void (^completion)(void) = blocks[@"completion"];
    
    CKManager *manager = [CKManager  shareManager];
    NSThread *thread = [NSThread currentThread];
    NSString *dbName = thread.name;
    FMDatabase *db = [manager databaseWithName:dbName];
    FMDatabaseQueue *queue = [manager databaseQueueWithName:dbName];
    if (operate) {
        operate(queue,db);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (completion) {
            completion();
        }
    });
}
//*/
 
@end
