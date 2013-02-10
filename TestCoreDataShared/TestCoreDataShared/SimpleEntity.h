//
//  SimpleEntity.h
//  TestCoreDataShared
//
//  Created by Gene Goykhman on 2013-02-10.
//  Copyright (c) 2013 Indigo Technologies Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SimpleEntity : NSManagedObject

@property (nonatomic, retain) NSString * simpleAttribute;

@end
