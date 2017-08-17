//
//  NSObject+HZModel.m
//  Pods
//
//  Created by xzh on 2016/12/8.
//
//

#import "NSObject+HZORM.h"
#import <objc/runtime.h>
#import <FMDB/FMDB.h>
#import "HZModelMeta.h"
#import "HZQueryBuilder.h"
static const char kPrimaryKey = '\0';
static const char kIsInDBKey = '\0';
NSString *const kPrimaryKeyName = @"primaryKey";
@interface NSObject ()

@property(nonatomic, assign) BOOL isInDB;

@end

@implementation NSObject (HZORM)
#pragma mark - Initialization
+ (instancetype)modelInDBWithKeys:(NSArray<NSString *> *)keys values:(NSArray *)values
{
    return [[self findByColumns:keys values:values] firstObject];
}

#pragma mark - Private Method


+ (NSString *)jsonStringWithObject:(id)jsonObj
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObj options:0 error:&error];
    if (error) return @"";
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (id)jsonObjWithJsonString:(NSString *)jsonStr
{
    return [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
}

//将属性值转化成适合数据存储的值
- (id)validDBValueForProperty:(NSString *)name
{
    id originalValue = [self valueForKey:name];
    
    if (!originalValue) return [NSNull null];
    
    if ([originalValue isKindOfClass:[NSArray class]] || [originalValue isKindOfClass:[NSDictionary class]]) {
        return [NSObject jsonStringWithObject:originalValue];
    }else if([originalValue isKindOfClass:[NSString class]] || [originalValue isKindOfClass:[NSNumber class]]){
        return originalValue;
    }else { //originalValue为其它对象类型
        return @"";
    }
}

- (NSArray *)validDBValuesForPropertys:(NSArray *)propertyNames;
{
    if (!(propertyNames.count > 0)) return nil;
    
    NSMutableArray *values = [NSMutableArray array];
    
    for (NSString *propertyName in propertyNames) {
        id value = [self validDBValueForProperty:propertyName];
        [values addObject:value];
    }
    return values;
}


- (BOOL)existInDB
{
    HZModelMeta *meta = [self meta];
    NSString *tableName = meta.tableName;
    
    if ([HZDBManager open]) {
    
        NSInteger count = [HZDBManager longForQuery:[NSString stringWithFormat:@"select count(*) from %@ where %@",tableName, [self wherePKWithMeta:meta]]];
        [HZDBManager close];
        
        return count;
    }
    
    return NO;
}


- (HZModelMeta *)meta
{
    return [[HZModelMeta alloc] initWithClass:[self class]];
}

- (BOOL)insert
{
    //get table structure.
    HZModelMeta *meta = [self meta];
    NSArray *columns = meta.columnMap.allKeys;
    NSString *tableName = meta.tableName;
    BOOL incrementing = meta.incrementing;
    if (incrementing) {
        NSString *primaryKey = [meta.primaryKeys firstObject];
        NSMutableArray *columnsWithoutPK = [NSMutableArray arrayWithArray:columns];
        [columnsWithoutPK removeObject:primaryKey];
        columns = columnsWithoutPK;
    }
    
    //call back
    [self beforeInsert];
    
    //construct sql and params.
    NSMutableArray *parameterList = [NSMutableArray arrayWithCapacity:columns.count];
    for (NSInteger i = 0; i < columns.count; i++) {
        [parameterList addObject:@"?"];
    }
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) values(%@)", tableName, [columns componentsJoinedByString:@","], [parameterList componentsJoinedByString:@","]];
    NSArray *propertyNames = [meta.columnMap dictionaryWithValuesForKeys:columns].allValues;
    
    //execute
    if ([HZDBManager executeUpdate:sql withParams:[self validDBValuesForPropertys:propertyNames]]) {

        if (incrementing) { [self setValue:@([HZDBManager lastInsertRowId]) forKey:[meta.primaryKeys firstObject]]; }
        
        [self sucessInsert];
        return YES;
    }
    
    return NO;
}

- (BOOL)update
{
    //get table structure.
    HZModelMeta *meta = [self meta];
    NSString *tableName = meta.tableName;
    NSMutableDictionary *columnsMapWithoutPK = [NSMutableDictionary dictionaryWithDictionary:meta.columnMap];
    [columnsMapWithoutPK removeObjectsForKeys:meta.primaryKeys];


    [self beforeUpdate];
    
    NSMutableString *setValues = [NSMutableString string];
    NSMutableArray *parameters = [NSMutableArray arrayWithCapacity:columnsMapWithoutPK.count];
    [columnsMapWithoutPK enumerateKeysAndObjectsUsingBlock:^(NSString  *_Nonnull column, NSString  *_Nonnull property, BOOL * _Nonnull stop) {
        [setValues appendFormat:@"%@ = ?,",column];
        id data = [self validDBValueForProperty:property];
        if (data) [parameters addObject:data];
    }];
    [setValues deleteCharactersInRange:NSMakeRange(setValues.length - 1, 1)];

    
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@", tableName, setValues, [self wherePKWithMeta:meta]];
    if ([HZDBManager executeUpdate:sql withParams:parameters]) {
        
        [self sucessUpdate];
        return YES;
    }
    return NO;
}

- (BOOL)remove
{
    //get table structure.
    HZModelMeta *meta = [self meta];
    NSString *tableName = meta.tableName;
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", tableName, [self wherePKWithMeta:meta]];
    if ([HZDBManager executeUpdate:sql withParams:nil]) {
        return YES;
    }
    return NO;
}

- (NSString *)wherePKWithMeta:(HZModelMeta *)meta
{
    NSArray *pks = meta.primaryKeys;
    NSDictionary *maps = meta.columnMap;
    
    NSMutableString *wherePK = [NSMutableString string];
    [pks enumerateObjectsUsingBlock:^(NSString  *_Nonnull column, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *propertyName = [maps objectForKey:column];
        if (propertyName) {
            [wherePK appendFormat:@" %@ = '%@' AND",column,[self validDBValueForProperty:propertyName]];
        }
    }];
    
    NSAssert(wherePK.length > 0, @"map of column-property don't containe pk");
    
    [wherePK deleteCharactersInRange:NSMakeRange(wherePK.length - 4, 4)];
    
    return wherePK;
}



+ (NSString *)whereStrWithKeys:(NSArray *)keys values:(NSArray *)values
{
    NSAssert(keys.count == values.count, @"key's count not equal value's count");
    
    NSMutableString *str = [NSMutableString stringWithString:@"where "];
    for (int i=0; i<[keys count]; i++) {
        NSString *key = [keys objectAtIndex:i];
        [str appendFormat:@"%@=? AND ",key];
    }
    
    [str deleteCharactersInRange:NSMakeRange(str.length-4, 4)];
    return str;
}


#pragma mark - Public Method
//+ (NSInteger)modelExistDBWithKeys:(NSArray<NSString *> *)keys values:(NSArray *)values
//{
//    if (!([keys isKindOfClass:[NSArray class]] && keys.count > 0) || !(values.count > 0)) return NO;
//    
//    NSMutableString *sql = [NSMutableString stringWithFormat:@"select primaryKey from %@ %@",[self getTabelName],[self whereStrWithKeys:keys values:values]];
//    NSObject *obj = [[[self class] findWithSql:sql withParameters:values] firstObject];
//    return obj.primaryKey;
//}

//- (BOOL)checkExistWithKeys:(NSArray<NSString *> *)keys values:(NSArray *)values
//{
//    NSInteger key = [[self class] modelExistDBWithKeys:keys values:values];
//    BOOL rs = NO;
//    if (key) {
//        self.isInDB = rs = YES;
//        self.primaryKey = key;
//    }
//    
//    return rs;
//}

- (BOOL)save
{
    BOOL rs = NO;
    if ([HZDBManager open]) {
        
        if (![self existInDB]) {
            rs = [self insert];
        }else {
            rs = [self update];
        }
        [HZDBManager close];
        return rs;
    }
    return NO;
}

//+ (BOOL)deleteWithKeys:(NSArray <NSString *> *)keys values:(NSArray *)values
//{
//    if (!([keys isKindOfClass:[NSArray class]] && keys.count > 0) || !([values isKindOfClass:[NSArray class]] && values.count > 0)) return NO;
//    if ([HZDBManager open]) {
//        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ %@", [self getTabelName],[self whereStrWithKeys:keys values:values]];
//        BOOL rs = [HZDBManager executeUpdate:sql withParams:values];
//        [HZDBManager close];
//        return rs;
//    }
//    
//    return NO;
//}
//
//+ (BOOL)deleteAll
//{
//    if ([HZDBManager open]) {
//        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", [self getTabelName]];
//        BOOL rs = [HZDBManager executeUpdate:sql withParams:nil];
//        [HZDBManager close];
//        return rs;
//    }
//    
//    return NO;
//}

+ (BOOL)saveArray:(NSArray *)modelArray
{
    if (!([modelArray isKindOfClass:[NSArray class]] && modelArray.count > 0)) return NO;
    
    if ([HZDBManager open]) {
        [HZDBManager beginTransactionWithBlock:^BOOL(HZDatabaseManager * _Nonnull db) {
            for (NSObject *obj in modelArray) {
                if (![obj save]) {
                    return NO;
                }
            }
            return YES;
        }];

        [HZDBManager close];
        return YES;
    }
    
    return NO;
}

//+ (BOOL)deleteWithArray:(NSArray *)array
//{
//    if (!([array isKindOfClass:[NSArray class]] && array.count > 0)) return NO;
//    
//    if ([HZDBManager open]) {
//        NSMutableString *collection = [NSMutableString stringWithString:@"("];
//        for (NSObject *model in array) {
//            [collection appendFormat:@"%lu,",(unsigned long)model.primaryKey];
//        }
//        [collection deleteCharactersInRange:NSMakeRange(collection.length-1, 1)];
//        [collection appendString:@")"];
//        NSString *sql = [NSString stringWithFormat:@"delete from %@ where primaryKey in %@",[self getTabelName],collection];
//        BOOL rs = NO;
//        if ([HZDBManager executeUpdate:sql withParams:nil]) {
//            [array setValue:@0 forKey:@"primaryKey"];
//            [array setValue:@(NO) forKey:@"isInDB"];
//            rs =  YES;
//        }
//        [HZDBManager close];
//        return rs;
//    }
//    
//    return NO;
//}

//- (BOOL)delete
//{
//    if ([HZDBManager open]) {
//        BOOL rs = [self deleteSelf];
//        [HZDBManager close];
//        return rs;
//    }
//    
//    return NO;
//}

+ (HZQueryBuilder *)search:(NSArray *)columns
{
    return [[HZQueryBuilder queryBuilderWithMeta:[[HZModelMeta alloc] initWithClass:[self class]]] select:columns];
}

+ (HZQueryBuilder *)searchRaw:(NSString *)raw
{
    return [[HZQueryBuilder queryBuilderWithMeta:[[HZModelMeta alloc] initWithClass:[self class]]] selectRaw:raw];
}

+ (NSArray *)findWithSql:(NSString *)sql withMeta:(nonnull HZModelMeta *)meta
{
    if(!(sql.length > 0 && meta)) return nil;
    
    NSArray *modelArray = nil;
    if ([HZDBManager open]) {
        NSArray *results= [HZDBManager executeQuery:sql withParams:nil];
        
        NSMutableArray *objArray = [NSMutableArray arrayWithCapacity:results.count];
        Class modelClass = meta.cla;
        
        [results enumerateObjectsUsingBlock:^(NSDictionary  *_Nonnull dic, NSUInteger idx, BOOL * _Nonnull stop) {
            NSObject *obj = [[modelClass alloc] init];
            [self configPropertyWithData:dic meta:meta forObj:obj];
            [objArray addObject:obj];
        }];
        modelArray = objArray;
        [HZDBManager close];
    }
    
    return modelArray;
    
}

+ (void)configPropertyWithData:(NSDictionary *)data meta:(HZModelMeta *)meta forObj:(NSObject *)obj
{
    NSDictionary *columnPropertyDic = meta.columnMap;
    NSDictionary *casts = meta.casts;
    
    [data enumerateKeysAndObjectsUsingBlock:^(NSString  *_Nonnull columnName, id  _Nonnull value, BOOL * _Nonnull stop) {
        NSString *propertyName = [columnPropertyDic objectForKey:columnName];
        if ([propertyName isKindOfClass:[NSString class]] && propertyName.length > 0) {
            
            NSString *type = [casts objectForKey:propertyName];
            id convertedValue = [self converteValue:value withType:type];
            
            NSAssert(convertedValue, @"HZORM 装换的值不能为nil");
            if (convertedValue && ![convertedValue isKindOfClass:[NSNull class]]) [obj setValue:convertedValue forKey:propertyName];
        }
        
    }];
}

+ (id)converteValue:(id)value withType:(NSString *)type
{
    id convertedValue = value;
    if (type) {
        if ([type isEqualToString:@"NSArray"] || [type isEqualToString:@"NSDictionary"]) {
            convertedValue = [NSObject jsonObjWithJsonString:convertedValue];
        }else if ([type isEqualToString:@"NSMutableArray"] || [type isEqualToString:@"NSMutableDictionary"]) {
            convertedValue = [NSObject jsonObjWithJsonString:convertedValue];
            convertedValue = [convertedValue isKindOfClass:[NSArray class]]?[NSMutableArray arrayWithArray:convertedValue]:[NSMutableDictionary dictionaryWithDictionary:convertedValue];
        }
    }
    
    return convertedValue;
}

//+ (NSArray *)findWithSql:(NSString *)sql withParameters:(NSArray *)parameters
//{
//    NSArray *modelArray = nil;
//    if ([HZDBManager open]) {
//        NSArray *results= [HZDBManager executeQuery:sql withParams:parameters];
//        NSMutableArray *objArray = [NSMutableArray arrayWithCapacity:results.count];
//        NSDictionary *columnPropertyDic = [self getColumnNames];
//        [results enumerateObjectsUsingBlock:^(NSDictionary  *_Nonnull json, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSObject *obj = [[self alloc] init];
//            [json enumerateKeysAndObjectsUsingBlock:^(NSString  *_Nonnull columnName, id  _Nonnull value, BOOL * _Nonnull stop) {
//                if ([columnName isEqualToString:kPrimaryKeyName]) {
//                    [obj setValue:value forKey:columnName];
//                }else {
//                    NSString *propertyName = [columnPropertyDic objectForKey:columnName];
//                    if ([propertyName isKindOfClass:[NSString class]] && propertyName.length > 0) {
//                        id convertedValue =  [self getNewValueForProperty:propertyName withOriginValue:value];
//                        NSAssert(convertedValue, @"HZORM 装换的值不能为nil");
//                        if (convertedValue && ![convertedValue isKindOfClass:[NSNull class]]) [obj setValue:convertedValue forKey:propertyName];
//                    }
//                }
//            }];
//            [obj setValue:@(YES) forKey:@"isInDB"];
//            [objArray addObject:obj];
//        }];
//        modelArray = objArray;
//        [HZDBManager close];
//    }
//
//    return modelArray;
//}


//
//+ (NSArray *)findByColumns:(NSArray *)columns values:(NSArray *)values
//{
//    if (!columns || !values) return nil;
//    
//    NSMutableString *sql = [NSMutableString stringWithFormat:@"select * from %@ %@",[self getTabelName],[self whereStrWithKeys:columns values:values]];
//
//    
//    return [self findWithSql:sql withParameters:values];
//}
//
//+ (NSArray *)findAll
//{
//    return [self findWithSql:[NSString stringWithFormat:@"SELECT * FROM %@", [self getTabelName]] withParameters:nil];
//}

#pragma mark - CallBack
- (void)beforeInsert {}
- (void)sucessInsert {}
- (void)beforeUpdate {}
- (void)sucessUpdate {}
- (void)beforeDelete {}
- (void)sucessDelete {}

#pragma mark - Override


#pragma mark - Property

//
//- (NSUInteger)primaryKey
//{
//    NSNumber *primaryKey = objc_getAssociatedObject(self, &kPrimaryKey);
//    return [primaryKey unsignedIntegerValue];
//}
//
//- (void)setPrimaryKey:(NSUInteger)primaryKey
//{
//    [self willChangeValueForKey:@"primaryKey"];
//    objc_setAssociatedObject(self, &kPrimaryKey, @(primaryKey), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    [self didChangeValueForKey:@"primaryKey"];
//}

@end
