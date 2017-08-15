//
//  HZQueryBuilder.h
//  Pods
//
//  Created by xzh on 2017/8/15.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HZQueryBuilder : NSObject

+ (instancetype)queryBuilderWithTable:(NSString *)tableName;

- (HZQueryBuilder *)select:(NSArray<NSString *> *)columns;

- (HZQueryBuilder *)selectRaw:(NSString *)raw;

- (HZQueryBuilder *)where:(NSDictionary<NSString *, id> *)params;

- (HZQueryBuilder *)whereRaw:(NSString *)raw;

- (HZQueryBuilder *)orderBy:(NSString *)column desc:(BOOL)desc;

- (HZQueryBuilder *)join:(NSString *)tableName columns:(NSArray<NSString *> *)columns;

- (HZQueryBuilder *)skip:(NSInteger)skip;

- (HZQueryBuilder *)take:(NSInteger)take;

- (NSArray *)get;

- (id)first;



@end

NS_ASSUME_NONNULL_END
