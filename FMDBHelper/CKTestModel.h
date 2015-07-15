//
//  CKTestModel.h
//  FMDBHelper
//
//  Created by tcyx on 15/5/22.
//  Copyright (c) 2015年 tcyx. All rights reserved.
//

#import "CKModel.h"
#import "CKTest.h"

@interface CKTestModel : CKModel<CKFmdbJsonSerializing>

@property (nonatomic, copy) NSNumber<CKPrimaryKey> *index;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) CKTest   *test;

@end
