//
//  IRKeychainManager.m
//  IRKeychain
//
//  Created by Evadne Wu on 12/30/10.
//  Copyright 2010 Iridia Productions. All rights reserved.
//

#import "IRKeychainManager.h"


@implementation IRKeychainManager


+ (IRKeychainManager *) sharedManager {

	static dispatch_once_t predicate;
	static IRKeychainManager *sharedIRKeychainManager = nil;
	
	dispatch_once(&predicate, ^ {
		
		sharedIRKeychainManager = [[[self class] alloc] init];
	
	});
	
	return sharedIRKeychainManager;
	
}

- (id) init {
	
	self = [super init]; if (!self) return nil;
	
	return self;
	
}


- (NSArray *) keychainItemsOfKind:(IRKeychainItemKind)kind matchingPredicate:(NSDictionary *)predicateOrNil inAccessGroup:(NSString *)accessGroupOrNil {
	
	if (kind == IRKeychainItemKindAny) {
	
		NSMutableArray *results = [NSMutableArray array];
		
		NSArray* (^query)(IRKeychainItemKind) = ^ (IRKeychainItemKind queryKind) {
		
			return [self keychainItemsOfKind:queryKind matchingPredicate:predicateOrNil inAccessGroup:accessGroupOrNil];
		
		};
		
		[results addObjectsFromArray:query(IRKeychainItemKindPassword)];
		[results addObjectsFromArray:query(IRKeychainItemKindInternetPassword)];
		[results addObjectsFromArray:query(IRKeychainItemKindCertificate)];
		[results addObjectsFromArray:query(IRKeychainItemKindKey)];
		[results addObjectsFromArray:query(IRKeychainItemKindIdentity)];
		
		return results;
		
	}
	
	NSLog(@"\n\n");
	
	NSLog(@"Querying items of kind %@ matching predicate %@ in access group %@", NSStringFromIRKeychainItemKind(kind), predicateOrNil, accessGroupOrNil);
	
	NSMutableDictionary *queryDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:

		(id)SecClassFromIRKeychainItemKind(kind), (id)kSecClass,
		(id)kCFBooleanTrue, (id)kSecReturnAttributes,
		(id)kCFBooleanTrue, (id)kSecReturnRef,
		(id)kSecMatchLimitAll, (id)kSecMatchLimit,
	
	nil];
	
	NSMutableDictionary *resultsDictionary = [NSMutableDictionary dictionary];	
	
	
	if (predicateOrNil)
	for (id aKey in predicateOrNil)
	[queryDictionary setObject:[predicateOrNil objectForKey:aKey] forKey:aKey];
	
	
//	The identifier is an umbrella term for different keys, for different keychain item classes.		
//	FIXME: Add identifier support for other kinds of items
	

	OSStatus keychainServicesResults = errSecSuccess;
	keychainServicesResults = SecItemCopyMatching((CFDictionaryRef)queryDictionary, (CFTypeRef *)&resultsDictionary);
	
	NSLog(@"queryDictionary %@, resultsDictionary %@", queryDictionary, resultsDictionary);
	
	switch (keychainServicesResults) {
	
		case errSecSuccess:
			
			NSLog(@"Item found.  Now, items are %@", resultsDictionary);
			break;
		
		
	//	Other cases fall through and return an empty array.
		
		case errSecUnimplemented:
			
			NSLog(@"Error: Unimplemented.");
			return [NSArray array];
			
		case errSecParam:
			
			NSLog(@"Error: Keychain query parameters invalid.");
			return [NSArray array];

		case errSecAllocate:
			
			NSLog(@"Error: Can’t allocate memory.");
			return [NSArray array];
			
		case errSecNotAvailable:
			
			NSLog(@"Error: No keychain available.");
			return [NSArray array];
			
		case errSecDuplicateItem:
			
			NSLog(@"Error: duplicate item exists.");
			return [NSArray array];

		case errSecItemNotFound:
			
			NSLog(@"Error: Item not found");
			return [NSArray array];
			
		case errSecInteractionNotAllowed:
			
			NSLog(@"Error: User interaction is not allowed.");
			return [NSArray array];
			
		case errSecDecode:
			
			NSLog(@"Error: Unable to decode the provided data.");
			return [NSArray array];
			
		case errSecAuthFailed:
			
			NSLog(@"Error: The user name or passphrase you entered is not correct.");
			return [NSArray array];
		
	//	Fallthrough
		default:
			
			return [NSArray array];
			break;			
	
	}
	
	return [NSArray array];	
	
}

- (id) itemOfKind:(IRKeychainItemKind)kind withIdentifier:(NSString *)identifier {
	
	return nil;
	
}

- (id) newItemOfKind:(IRKeychainItemKind)kind withIdentifier:(NSString *)identifier {
	
	return nil;
	
}


@end



