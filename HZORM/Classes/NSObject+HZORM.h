//
//  NSObject+HZORM.h
//  Pods
//
//  Created by xzh on 2016/12/8.
//
//

/****************     进行ORM操作     ****************/

#import <Foundation/Foundation.h>
#import "HZDatabaseManager.h"
#import "HZQueryBuilder.h"

@class HZModelMeta;

NS_ASSUME_NONNULL_BEGIN


@interface NSObject (HZORM)


- (BOOL)save;

- (BOOL)update;

- (BOOL)remove;

+ (BOOL)remove;

+ (BOOL)remove:(NSArray<NSNumber *> *)pks;

+ (BOOL)insert:(NSArray *)models;

+ (instancetype)find:(NSInteger)pk;

+ (instancetype)firstWithKeyValues:(NSDictionary *)keyValues;

+ (NSArray *)all;

+ (HZQueryBuilder *)search:(NSArray *)columns;

+ (HZQueryBuilder *)searchRaw:(NSString *)raw;

+ (nullable NSArray *)findWithSql:(NSString *)sql withMeta:(HZModelMeta *)meta;




@end

NS_ASSUME_NONNULL_END
