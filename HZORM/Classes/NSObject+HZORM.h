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

+ (BOOL)insert:(NSArray *)models;

+ (instancetype)find:(NSInteger)pk;


/**
 *  根据值删除元组
 */
+ (BOOL)deleteWithKeys:(NSArray <NSString *> *)keys values:(NSArray *)values;

/**
 *	查找数据模型
 *
 *	@param column  作为查询条件的属性名
 *  @param value  作为查询条件的属性值
 *
 *  @return 数据模型数组,无结果返回nil
 */
+ (nullable NSArray *)findByColumns:(NSArray *)columns values:(NSArray *)values;

/**
 *	查找数据模型
 *
 *	@param sql  查找sql语句,参数用?占位
 *  @param parameters  参数数组
 *
 *  @return 数据模型数组,无结果返回nil
 */
+ (nullable NSArray *)findWithSql:(NSString *)sql withParameters:(nullable NSArray *)parameters;

+ (nullable NSArray *)findWithSql:(NSString *)sql withMeta:(HZModelMeta *)meta;


+ (HZQueryBuilder *)search:(NSArray *)columns;

+ (HZQueryBuilder *)searchRaw:(NSString *)raw;

/**
 *	查找该表下的所有数据模型
 *
 *  @return 数据模型数组,无结果返回nil
 */
+ (nullable NSArray *)findAll;

#pragma mark - CallBack
/**
 *  向数据库插入数据之前调用
 */
- (void)beforeInsert;

/**
 *  向数据库插入数据后调用
 */
- (void)sucessInsert;

/**
 *  向数据库更新数据之前调用
 */
- (void)beforeUpdate;

/**
 *  向数据库更新数据后调用
 */
- (void)sucessUpdate;

/**
 *  从数据库删除数据之前调用
 */
- (void)beforeDelete;

/**
 *  从数据库删除数据后调用
 */
- (void)sucessDelete;



@end

NS_ASSUME_NONNULL_END
