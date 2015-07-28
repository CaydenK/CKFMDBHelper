//
//  NSDictionary+CKExternal.m
//  GameCenter
//
//  Created by caydenk on 15/6/19.
//  Copyright (c) 2015年 CaydenK. All rights reserved.
//

#import "NSDictionary+CKExternal.h"

@implementation NSDictionary (CKExternal)

- (id)ckObjectForKey:(id)aKey{
    id item = [self objectForKey:aKey];
    if (item == nil || [[NSNull null] isEqual:item]) {
        return @"";
    }
    return item;
}

@end
