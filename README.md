HZORM
==============

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/GeniusBrother/HZORM/master/LICENSE)&nbsp;
[![CocoaPods](https://img.shields.io/cocoapods/v/HZORM.svg?style=flat)](http://cocoapods.org/pods/HZORM)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/p/HZORM.svg?style=flat)](http://cocoadocs.org/docsets/HZORM)&nbsp;
[![Support](https://img.shields.io/badge/support-iOS%208%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/)&nbsp;

Provides a beautiful, simple ActiveRecord implementation to interact with the database.<br/>
(It's a component of [HZExtend](https://github.com/GeniusBrother/HZExtend))

Contact
==============
#### QQ Group:32272635
#### Email:zuohong_xie@163.com

Installation
==============
### CocoaPods

1. Add `pod 'HZORM` to your Podfile.
2. Run `pod install` or `pod update`.
3. Import \<HZORM/HZORM.h\>.

Documentation
==============
Full API documentation is available on [CocoaDocs](http://cocoadocs.org/docsets/HZORM/).<br/>

Requirements
==============
This library requires `iOS 8.0+` and `Xcode 8.0+`.

Usage
==============
### DB Config
```objective-c
NSString *dbPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/HZDatabase.db"];
[HZDatabaseManager sharedManager].dbPath = dbPath;
```
### Structure
```objective-c
@interface Person : NSObject
@property(nonatomic, assign) NSInteger id;
@property(nonatomic, copy) NSString *pName;
@property(nonatomic, assign) NSInteger pAge;

@property(nonatomic, copy) NSArray *pBooks;
@end

//create table
NSString *createTableSql = @"create table Person(id integer primary key autoincrement autoincremen, name text not null, age integer, books text)";
[HZDBManager executeUpdate:createTableSql withParams:nil];

//implement structure methods
@implementation Person
+ (NSString *)getTabelName
{
    return @"Person";
}

+ (NSDictionary<NSString *,NSString *> *)getColumnMap
{
    return @{
             @"id":@"id",
             @"age":@"pAge",
             @"name":@"pName",
             @"books":@"pBooks"
             };
}

+ (NSDictionary<NSString *,NSString *> *)getCasts
{
    return @{
             @"pBooks":@"NSArray"
             };
}

+ (NSArray<NSString *> *)getPrimaryKeys
{
    return @[@"id"];
}
@end
```

### ORM Operation
```objective-c
//insert or update
Person *p = [[Person alloc] init];
p.pName = @"GeniusBrother";
p.pAge = 23;
p.pBooks = @[@"IOS",@"PHP",@"JAVA"];
[p save];

//remove
[p remove];

//insert multiple models
[Person insert:@[p1,p2,p3]];

//Removes all models in table
[Person remove];
```

### Search
```objective-c
//Retrieves a model by its primary key.
Person *p = [Person find:@1];

//Get the first record matching the attributes.
Person *p = [Person firstWithKeyValues:@{@"name":@"GeniusBrother"}];

//Gets the all ORM models in table
NSArray *models = [Person all];
```

### Query builder
```objective-c
//Gets eligible models containing all columns
NSArray *models = [[[Person search:@[@"*"]] where:@{@"age",@23}] get];

//Gets first 10 eligible models.
NSArray *models = [[[[Person search:@[@"name",@"age"]] whereRaw:@"age > 23"] take:10] get];

//Order By
NSArray *models = [[[[Person search:@[@"*"]] where:@{@"age",@23}] orderby:@"name" desc:YES] get];

//join
NSArray *models = [[[Person search:@[@"*"]] where:@{@"age",@23}] join:@"Role" withFirstColumn:@"Person.id" operator:@"=" secondColumn:@"Role.uid"];
```
