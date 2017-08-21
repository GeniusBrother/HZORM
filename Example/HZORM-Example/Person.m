//
//  Person.m
//  HZORM-Example
//
//  Created by xzh on 2017/8/17.
//  Copyright © 2017年 GeniusBrother. All rights reserved.
//

#import "Person.h"
#import <HZORM/NSObject+HZORMModel.h>

@implementation Person

+ (NSString *)getTabelName
{
    return @"Person";
}

+ (NSDictionary<NSString *,NSString *> *)getColumnMap
{
    return @{
             @"id":@"id",
             @"age":@"pAge",
             @"name":@"pName",
             @"books":@"pBooks"
             };
}

+ (NSDictionary<NSString *,NSString *> *)getCasts
{
    return @{
             @"pBooks":@"NSArray"
             };
}

+ (NSArray<NSString *> *)getPrimaryKeys
{
    return @[@"id"];
}

@end
