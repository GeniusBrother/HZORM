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


#pragma mark - CallBack
- (void)beforeInsert {}
- (void)sucessInsert {}
- (void)beforeUpdate {}
- (void)sucessUpdate {}
- (void)beforeRemove {}
- (void)sucessRemove {}
@end
