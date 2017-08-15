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

/**
 *	子类实现该方法对数据库值进行处理,然后在将新值赋给属性
 *  默认实现为返回原值
 *
 *	@param name 属性名
 *  @param originValue  原始数据库值
 *
 *  @return id,处理后的新值
 */
+ (id)getNewValueForProperty:(NSString *)name withOriginValue:(id)originValue;

@end

NS_ASSUME_NONNULL_END
