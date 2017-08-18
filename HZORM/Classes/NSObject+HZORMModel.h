//
//  NSObject+HZORMModel.h
//  Pods
//
//  Created by xzh on 2017/8/15.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (HZORMModel)

+ (NSString *)getTabelName;

+ (NSDictionary<NSString *, NSString *> *)getColumnMap;

+ (NSArray<NSString *> *)getPrimaryKeys;

+ (BOOL)isIncrementing;

+ (NSDictionary<NSString *, NSString *> *)getCasts;

- (void)beforeInsert;

- (void)sucessInsert;

- (void)beforeUpdate;

- (void)sucessUpdate;

- (void)beforeRemove;

- (void)sucessRemove;



@end

NS_ASSUME_NONNULL_END
