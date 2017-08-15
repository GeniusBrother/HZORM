//
//  HZModelMeta.h
//  Pods
//
//  Created by xzh on 2017/8/15.
//
//

#import <Foundation/Foundation.h>

@interface HZModelMeta : NSObject

@property(nonatomic, copy, readonly) NSString *tableName;

@property(nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *columnMap;

@property(nonatomic, copy, readonly) NSArray<NSString *> *primaryKeys;

@property(nonatomic, assign, readonly) BOOL incrementing;

@end
