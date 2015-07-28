//
//  NSString+CKDB.h
//  FMDBHelper
//
//  Created by caydenk on 15/5/22.
//  Copyright (c) 2015年 caydenk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CKDB)

/**
 *  处理插入/更新数据库字段中存在引号插入失败
 *
 *  @param string 待处理字符串
 *
 *  @return 处理后的字符串
 */
- (NSString *)chuliyinhao;

@end
