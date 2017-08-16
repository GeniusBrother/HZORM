//
//  HZModelMeta.h
//  Pods
//
//  Created by xzh on 2017/8/15.
//
//

#import <Foundation/Foundation.h>

/**
 存储ORM模型元数据
 */
@interface HZModelMeta : NSObject

- (instancetype)initWithClass:(Class)cla;

@property(nonatomic, readonly) Class cla;

@property(nonatomic, readonly) NSString *tableName;

@property(nonatomic, readonly) NSDictionary<NSString *, NSString *> *casts;

@property(nonatomic, readonly) NSDictionary<NSString *, NSString *> *columnMap;

@property(nonatomic, readonly) NSArray<NSString *> *primaryKeys;

@property(nonatomic, readonly) BOOL incrementing;

@end
