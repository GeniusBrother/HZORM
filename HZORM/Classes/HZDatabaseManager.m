//
//  HZDatabaseManager.m
//  Pods
//
//  Created by xzh on 2016/12/8.
//
//

#import "HZDatabaseManager.h"
#import <FMDB/FMDB.h>

#import "sqlite3.h"
@interface HZDatabaseManager ()

@property(nonatomic, strong) FMDatabase *database;

@end

@implementation HZDatabaseManager
#pragma mark - Initialization
static id _instance;
+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return _instance;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self setup];
        });
    }
    return self;
}

- (void)setup
{
    _shouldControlConnection = YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark - Private Method
- (BOOL)isOpen
{
    return [self.database goodConnection];
}

- (void)checkConnection
{
    if (self.shouldControlConnection) {
        [self.database open];
    }else {
        NSAssert([self isOpen], @"请先打开数据库");
    }
}

#pragma mark - Public Method
- (BOOL)open
{
    NSAssert(self.dbPath, @"请先设置db path ");
    
    return [self.database open];
}

- (BOOL)close
{
    if (self.shouldControlConnection) return NO;
    
    return [self.database close];
}

- (BOOL)executeUpdate:(NSString *)sql withParams:(NSArray *)data
{
    [self checkConnection];
    
    if (!([sql isKindOfClass:[NSString class]] && sql.length > 0)) {
        NSAssert(NO, @"%s SQL语句为空",__FUNCTION__);
        return NO;
    }
    
    BOOL result = NO;
    if ([data isKindOfClass:[NSArray class]] && data.count > 0) {
        result = [self.database executeUpdate:sql withArgumentsInArray:data];
    }else {
        result = [self.database executeUpdate:sql];
    }
    
#if DEBUG
    if (!result) {
        NSLog(@"update 失败 错误信息-----%@",self.database.lastErrorMessage);
    }
#endif
    
    return result;
}

- (NSArray *)executeQuery:(NSString *)sql withParams:(NSArray *)data
{
    [self checkConnection];
    
    if (!([sql isKindOfClass:[NSString class]] && sql.length > 0)) {
        NSAssert(NO, @"%s SQL语句为空",__FUNCTION__);
        return nil;
    }
    
    FMResultSet *rs = nil;
    NSMutableArray *array = [NSMutableArray array];
    if ([data isKindOfClass:[NSArray class]] && data.count > 0) {
        rs = [self.database executeQuery:sql withArgumentsInArray:data];
    }else {
        rs = [self.database executeQuery:sql];
    }
    
#if DEBUG
    if (!rs) {
        NSLog(@"sql 查询失败:%@",self.database.lastErrorMessage);
        return nil;
    }
#endif
    

    while ([rs next]) {
        NSMutableDictionary *dic = (NSMutableDictionary *)rs.resultDictionary;
        if (dic) [array addObject:dic];
    }
    [rs close];
    
    return array;
}

- (BOOL)executeStatements:(NSString *)sql withResultBlock:(HZDBExecuteStatementsCallbackBlock)block
{
    [self checkConnection];
    if (!([sql isKindOfClass:[NSString class]] && sql.length > 0)) {
        NSAssert(NO, @"%s SQL语句为空",__FUNCTION__);
        return NO;
    }

    return [self.database executeStatements:sql withResultBlock:block];
}

- (void)beginTransactionWithBlock:(BOOL (^)(HZDatabaseManager * _Nonnull obj))completion
{
    if (!completion) return;
    
    [self checkConnection];
    [self.database beginTransaction];
    BOOL rs = completion(self);
    if (rs) {
        [self.database commit];
    }else {
        [self.database rollback];
    }
}

- (double)doubleForQuery:(NSString *)sql
{
    [self checkConnection];
    
    if (!([sql isKindOfClass:[NSString class]] && sql.length > 0)) {
        NSAssert(NO, @"%s SQL语句为空",__FUNCTION__);
        return MAXFLOAT;
    }
    
    return [self.database doubleForQuery:sql];
}

- (long)longForQuery:(NSString *)sql
{
    [self checkConnection];
    
    if (!([sql isKindOfClass:[NSString class]] && sql.length > 0)) {
        NSAssert(NO, @"%s SQL语句为空",__FUNCTION__);
        return NSNotFound;
    }
    
    return [self.database longForQuery:sql];
}

- (NSUInteger)lastInsertRowId
{
    [self checkConnection];
    
    return (NSUInteger)[self.database lastInsertRowId];
}

#pragma mark - Notification
- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    if(self.shouldControlConnection)  [self.database close];
}

#pragma mark - Setter
- (void)setDbPath:(NSString *)dbPath
{
    if (!([dbPath isKindOfClass:[NSString class]] && dbPath.length > 0) && ![dbPath isEqualToString:_dbPath]) {
        [self.database close];
        
        NSString *directory = [dbPath stringByDeletingLastPathComponent];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:directory]) {
            NSError *error;
            [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
        }
        
        self.database = [FMDatabase databaseWithPath:dbPath];   //用到的时候去连接数据库
    }
    _dbPath = dbPath;
}

@end
