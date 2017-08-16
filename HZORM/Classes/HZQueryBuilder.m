//
//  HZQueryBuilder.m
//  Pods
//
//  Created by xzh on 2017/8/15.
//
//

#import "HZQueryBuilder.h"
#import <NSObject+HZORM.h>
#import "HZModelMeta.h"
@interface HZQueryBuilder ()

@property(nonatomic, strong) HZModelMeta *meta;

@property(nonatomic, copy) NSString *select;
@property(nonatomic, copy) NSString *where;
@property(nonatomic, copy) NSString *orderBy;
@property(nonatomic, copy) NSString *join;
@property(nonatomic, copy) NSString *limit;

@end

@implementation HZQueryBuilder

#pragma mark - Initialization
+ (instancetype)queryBuilderWithMeta:(HZModelMeta *)meta
{
    HZQueryBuilder *builder = [[HZQueryBuilder alloc] init];
    builder.meta = meta;

    return builder;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _select = @"";
    _where = @"";
    _orderBy = @"";
    _join = @"";
    _limit = @"";
}

#pragma mark - Public Method
- (HZQueryBuilder *)select:(NSArray<NSString *> *)columns
{
    if (!(columns.count > 0)) return self;
    
    self.select = [columns componentsJoinedByString:@","];
    
    return self;
}

- (HZQueryBuilder *)selectRaw:(NSString *)raw
{
    if (!(raw.length > 0)) return self;
    
    self.select = raw;
    
    return self;
}

- (HZQueryBuilder *)where:(NSDictionary<NSString *,id> *)params
{
    if (!(params.count > 0)) return self;
    
    NSMutableString *whereMutable = [NSMutableString string];
    [params enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [whereMutable appendFormat:@"%@ = '%@' and",key,obj];
    }];
    
    NSRange lastAnd = [whereMutable rangeOfString:@"and" options:NSBackwardsSearch];
    [whereMutable deleteCharactersInRange:lastAnd];
    self.where = [whereMutable copy];
    
    return self;
}

- (HZQueryBuilder *)whereRaw:(NSString *)raw
{
    if (!(raw.length > 0)) return self;
    
    self.where = raw;
    
    return self;
}

- (NSArray *)get
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select %@ from %@",self.select,self.meta.tableName];
    
    if (self.where.length > 0) {
        [sql appendFormat:@" where %@",self.where];
    }
    
    if (self.orderBy.length > 0) {
        [sql appendFormat:@" order by %@",self.orderBy];
    }
    
    
    return [NSObject findWithSql:sql withMeta:self.meta];
}


@end
