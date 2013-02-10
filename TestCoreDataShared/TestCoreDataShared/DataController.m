//
//  DataController.m
//  TestCoreDataShared
//
//  Created by Gene Goykhman on 2013-02-10.
//  Copyright (c) 2013 Indigo Technologies Ltd. All rights reserved.
//

#import "DataController.h"
#import "SimpleEntity.h"

NSString * kiCloudPersistentStoreFilename = @"iCloudStore.sqlite";

@interface DataController ()

- (BOOL)iCloudAvailable;
- (BOOL)loadiCloudStore:(NSError * __autoreleasing *)error;
- (void)dropStores;
- (NSURL *)iCloudStoreURL;
- (NSString *)applicationDocumentsDirectory;

@end

@implementation DataController

- (id)initWithDelegate:(id)delegate
{
	self = [super init];
	if (!self) return nil;
	[self setDelegate:delegate];
	
	_ubiquityURL = nil;
	_currentUbiquityToken = nil;
	
	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
	_psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
	_mainThreadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	[_mainThreadContext setPersistentStoreCoordinator:_psc];
	
	_currentUbiquityToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
	
	// Set ourselves up to observe iCloud changes
	
	[[NSNotificationCenter defaultCenter] addObserver:self
														  selector:@selector(mergeiCloudChangeNotification)
																name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
															 object:_psc];
	
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)iCloudAvailable {
	BOOL available = (_currentUbiquityToken != nil);
	return available;
}

- (void)report:(NSString *)info
{
	[[self delegate] report:info];
}

- (void)loadPersistentStores
{
	NSError *error;
	if (![self loadiCloudStore:&error])
		[self report:[NSString stringWithFormat:@"Could not load iCloud store: %@", error]];
}

- (BOOL)loadiCloudStore:(NSError * __autoreleasing *)error {
	BOOL success = YES;
	NSError *localError = nil;
	
	NSFileManager *fm = [[NSFileManager alloc] init];
	_ubiquityURL = [fm URLForUbiquityContainerIdentifier:nil];
	
	NSURL *iCloudStoreURL = [self iCloudStoreURL];
	NSURL *iCloudDataURL = [self.ubiquityURL URLByAppendingPathComponent:@"iCloudData"];
	NSDictionary *options = @{ NSPersistentStoreUbiquitousContentNameKey : @"iCloudStore",
									 NSPersistentStoreUbiquitousContentURLKey : iCloudDataURL };
	_iCloudStore = [self.psc addPersistentStoreWithType:NSSQLiteStoreType
													  configuration:nil
																	URL:iCloudStoreURL
															  options:options
																 error:&localError];
	success = (_iCloudStore != nil);
	if (!success) {
		if (localError  && (error != NULL)) {
			*error = localError;
		}
	}
	
	return success;
}

- (void)dropStores
{
	NSError *error = nil;
	if (_iCloudStore) {
		if ([_psc removePersistentStore:_iCloudStore error:&error]) {
			[self report:@"Removed iCloud Store"];
			_iCloudStore = nil;
		} else {
			[self report:[NSString stringWithFormat:@"Error removing iCloud Store: %@", error]];
		}
	}
}

- (void)mergeiCloudChangeNotification:(NSNotification *)note
{
	[self report:@"Received update from iCloud"];
	[_mainThreadContext mergeChangesFromContextDidSaveNotification:note];
	[_delegate performSelector:@selector(refreshEntityCount:)];
}

- (void)nukeAndPave {
	//disconnect from the various stores
	[self dropStores];
	
	NSFileCoordinator *fc = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
	NSError *error = nil;
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *path = [self.ubiquityURL path];
	NSArray *subPaths = [fm subpathsAtPath:path];
	for (NSString *subPath in subPaths) {
		NSString *fullPath = [NSString stringWithFormat:@"%@/%@", path, subPath];
		[fc coordinateWritingItemAtURL:[NSURL fileURLWithPath:fullPath]
									  options:NSFileCoordinatorWritingForDeleting
										 error:&error
								  byAccessor:^(NSURL *newURL) {
									  NSError *blockError = nil;
									  if ([fm removeItemAtURL:newURL error:&blockError]) {
										  [self report:[NSString stringWithFormat:@"Deleted file: %@", newURL]];
									  } else {
										  [self report:[NSString stringWithFormat:@"Error deleting file: %@\nError: %@", newURL, blockError]];
									  }
									  
								  }];
	}
	
	fc = nil;
}

- (NSString *)folderForUbiquityToken:(id)token {
	NSURL *tokenURL = [[self applicationSandboxStoresDirectory] URLByAppendingPathComponent:@"TokenFoldersData"];
	NSData *tokenData = [NSData dataWithContentsOfURL:tokenURL];
	NSMutableDictionary *foldersByToken = nil;
	if (tokenData) {
		foldersByToken = [NSKeyedUnarchiver unarchiveObjectWithData:tokenData];
	} else {
		foldersByToken = [NSMutableDictionary dictionary];
	}
	NSString *storeDirectoryUUID = [foldersByToken objectForKey:token];
	if (storeDirectoryUUID == nil) {
		NSUUID *uuid = [[NSUUID alloc] init];
		storeDirectoryUUID = [uuid UUIDString];
		[foldersByToken setObject:storeDirectoryUUID forKey:token];
		tokenData = [NSKeyedArchiver archivedDataWithRootObject:foldersByToken];
		[tokenData writeToFile:[tokenURL path] atomically:YES];
	}
	return storeDirectoryUUID;
}

- (NSURL *)iCloudStoreURL {
	NSURL *iCloudStoreURL = [self applicationSandboxStoresDirectory];
	NSAssert1(self.currentUbiquityToken, @"No ubiquity token? Why you no use fallback store? %@", self);
	
	NSString *storeDirectoryUUID = [self folderForUbiquityToken:self.currentUbiquityToken];
	
	iCloudStoreURL = [iCloudStoreURL URLByAppendingPathComponent:storeDirectoryUUID];
	NSFileManager *fm = [[NSFileManager alloc] init];
	if (NO == [fm fileExistsAtPath:[iCloudStoreURL path]]) {
		NSError *error = nil;
		BOOL createSuccess = [fm createDirectoryAtURL:iCloudStoreURL withIntermediateDirectories:YES attributes:nil error:&error];
		if (NO == createSuccess) {
			[self report:[NSString stringWithFormat:@"Unable to create iCloud store directory: %@", error]];
		}
	}
	
	iCloudStoreURL = [iCloudStoreURL URLByAppendingPathComponent:kiCloudPersistentStoreFilename];
	return iCloudStoreURL;
}

- (NSURL *)applicationSandboxStoresDirectory {
	NSURL *storesDirectory = [NSURL fileURLWithPath:[self applicationDocumentsDirectory]];
	storesDirectory = [storesDirectory URLByAppendingPathComponent:@"SharedCoreDataStores"];
	
	NSFileManager *fm = [[NSFileManager alloc] init];
	if (NO == [fm fileExistsAtPath:[storesDirectory path]]) {
		//create it
		NSError *error = nil;
		BOOL createSuccess = [fm createDirectoryAtURL:storesDirectory
								withIntermediateDirectories:YES
													  attributes:nil
															 error:&error];
		if (createSuccess == NO) {
			[self report:[NSString stringWithFormat:@"Unable to create application sandbox stores directory: %@\n\tError: %@", storesDirectory, error]];
		}
	}
	return storesDirectory;
}

- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)insertSimpleEntity
{
	NSManagedObject *newEntity = [NSEntityDescription insertNewObjectForEntityForName:@"SimpleEntity"
																				  inManagedObjectContext:_mainThreadContext];
	SimpleEntity *entity = (SimpleEntity *)newEntity;
	[entity setSimpleAttribute:@"Simple String"];
	
	// Save the context
	
	NSError *error = nil;
	if (![_mainThreadContext save:&error])
		[self report:[NSString stringWithFormat:@"Could not save entity: %@", error]];
	else {
		[self report:[NSString stringWithFormat:@"Entity successfully added"]];
		[_delegate performSelector:@selector(refreshEntityCount:)];
	}
}

- (void)deleteAllEntities
{
	NSError *error = nil;
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"SimpleEntity" inManagedObjectContext:_mainThreadContext]];
	[request setIncludesSubentities:NO];
	NSArray *results  = [_mainThreadContext executeFetchRequest:request error:&error];
	if (!results) {
		[self report:[NSString stringWithFormat:@"Could not fetch list of entities %@", error]];
		return;
	}
	for (NSManagedObject *obj in results) {
		[_mainThreadContext deleteObject:obj];
	}
	
	// Save
	
	if (![_mainThreadContext save:&error])
		[self report:[NSString stringWithFormat:@"Could not delete entities %@", error]];
	[_delegate performSelector:@selector(refreshEntityCount:)];
}

- (NSUInteger)countEntities
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"SimpleEntity" inManagedObjectContext:_mainThreadContext]];
	[request setIncludesSubentities:NO];
	
	NSError *error = nil;
	NSUInteger count = [_mainThreadContext countForFetchRequest:request error:&error];
	if (count == NSNotFound) {
		[self report:[NSString stringWithFormat:@"Could not count entities: %@", error]];
	}
	return count;
}

@end
