//
//  NSObject+HZORMModel.m
//  Pods
//
//  Created by xzh on 2017/8/15.
//
//

#import "NSObject+HZORMModel.h"

@implementation NSObject (HZORMModel)

+ (NSString *)getTabelName { return @"";}

+ (NSDictionary<NSString *,NSString *> *)getColumnMap { return @{@"id":@"id"}; }

+ (NSArray<NSString *> *)getPrimaryKeys { return @[@"id"]; }

+ (NSDictionary<NSString *,NSString *> *)getCasts { return @{}; }

+ (BOOL)isIncrementing { return YES; }

+ (id)getNewValueForProperty:(NSString *)name withOriginValue:(id)originValue { return originValue; }


@end
