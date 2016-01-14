//
//  UserInfoModel.h
//  shanghaiditie
//
//  Created by 21k on 15/4/8.
//  Copyright (c) 2015年 21k. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserInfoModel : NSManagedObject

@property (nonatomic, retain) NSString * loginimgurl;
@property (nonatomic, retain) NSString * companyname;
@property (nonatomic, retain) NSString * signature;
@property (nonatomic, retain) NSString * fullname;
@property (nonatomic, retain) NSString * loginid;
@property (nonatomic, retain) NSString * companyid;
@property (nonatomic, retain) NSString * departmentname;
@property (nonatomic, retain) NSString * postname;
@property (nonatomic, retain) NSString * departmentid;

@end
