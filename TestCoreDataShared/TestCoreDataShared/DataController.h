//
//  DataController.h
//  TestCoreDataShared
//
//  Created by Gene Goykhman on 2013-02-10.
//  Copyright (c) 2013 Indigo Technologies Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataController : NSObject


@property (nonatomic, weak) id delegate;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *psc;
@property (nonatomic, readonly) NSManagedObjectContext *mainThreadContext;
@property (nonatomic, readonly) NSPersistentStore *iCloudStore;
@property (nonatomic, readonly) NSPersistentStore *fallbackStore;
@property (nonatomic, readonly) NSPersistentStore *localStore;

@property (nonatomic, readonly) NSURL *ubiquityURL;
@property (nonatomic, readonly) id currentUbiquityToken;

- (id)initWithDelegate:(id)delegate;
- (void)loadPersistentStores;
- (void)nukeAndPave;

@end
