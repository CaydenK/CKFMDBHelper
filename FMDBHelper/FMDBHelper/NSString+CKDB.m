//
//  NSString+CKDB.m
//  FMDBHelper
//
//  Created by caydenk on 15/5/22.
//  Copyright (c) 2015年 caydenk. All rights reserved.
//

#import "NSString+CKDB.h"

@implementation NSString (CKDB)

/**
 *  处理插入/更新数据库字段中存在引号插入失败
 *
 *  @param string 待处理字符串
 *
 *  @return 处理后的字符串
 */
- (NSString *)chuliyinhao{
    NSRange range=[self rangeOfString:@"'"];
    if (range.length>0){
        NSMutableString *mValue = self.mutableCopy;
        for (NSInteger i = mValue.length-1; i>=0; i--) {
            NSString *charValue = [mValue substringWithRange:NSMakeRange(i, 1)];
            if ([charValue isEqualToString:@"'"]) {
                [mValue replaceCharactersInRange:NSMakeRange(i, 1) withString:@"''"];
            }
        }
        return [NSString stringWithFormat:@"'%@'",mValue];
    }
    else{
        return [NSString stringWithFormat:@"'%@'",self];
    }
}

@end
