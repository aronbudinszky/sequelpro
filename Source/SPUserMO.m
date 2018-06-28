//
//  SPUserMO.m
//  sequel-pro
//
//  Created by Mark Townsend on January 1, 2009.
//  Copyright (c) 2009 Mark Townsend. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//
//  More info at <https://github.com/sequelpro/sequelpro>

#import "SPUserMO.h"
#import "SPUserManager.h"

static NSString *SPUserMOParentKey   = @"parent";
static NSString *SPUserMOUserKey     = @"user";
static NSString *SPUserMOHostKey     = @"host";
static NSString *SPUserMOChildrenKey = @"children";
static NSString *SPUserMOPluginKey   = @"plugin";

static NSString *SPUserMOPluginLegacy  = @"mysql_native_password";
static NSString *SPUserMOPluginSecure  = @"caching_sha2_password";

@implementation SPUserMO

@dynamic user;
@dynamic host;
@dynamic parent;
@dynamic children;

- (NSString *)displayName
{
	if ([self valueForKey:SPUserMOParentKey] == nil) {
		return self.user;
	}
	if ([self.host length]) {
		return self.host;
	}
	return @"%";
}

- (void)setDisplayName:(NSString *)value
{
    if ([self valueForKey:SPUserMOParentKey] == nil) {
		[self setValue:value forKey:SPUserMOUserKey];
	}
    else
    {
		[self setValue:(value == nil) ? @"%" : value forKey:SPUserMOHostKey];
    }
}

- (BOOL)legacyPassword
{
	currentPlugin = [self valueForKey:SPUserMOPluginKey];
	return [currentPlugin isEqualToString:SPUserMOPluginLegacy];
}

- (void)setLegacyPassword:(BOOL)value
{
	return;
	// Problem: if we temporarily set to legacy plugin then we lose the original currentPlugin value

	// When setting to secure encryption (non-legacy) we need to make sure we use the current value (might be custom plugin)
	if(!value){
		// If the current is legacy, then set to current to secure
		if([currentPlugin isEqualToString:SPUserMOPluginLegacy]){
			currentPlugin = SPUserMOPluginSecure;
			[self setValue:currentPlugin forKey:SPUserMOPluginKey];
		}
		[self setValue:currentPlugin forKey:SPUserMOPluginKey];
	}
	else{
		[self setValue:SPUserMOPluginLegacy forKey:SPUserMOPluginKey];
	}
}

- (void)addChildrenObject:(SPUserMO *)value
{    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];

    [self willChangeValueForKey:SPUserMOChildrenKey withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:SPUserMOChildrenKey] addObject:value];
    [self didChangeValueForKey:SPUserMOChildrenKey withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
	
	value.user = self.user;
}

- (void)removeChildrenObject:(SPUserMO *)value
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:SPUserMOChildrenKey withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:SPUserMOChildrenKey] removeObject:value];
    [self didChangeValueForKey:SPUserMOChildrenKey withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (BOOL)validateForInsert:(NSError **)error
{
	if(![super validateForInsert:error]) return NO;

	SPUserManager *mgr = [self valueForKey:@"userManager"];
	
	return [mgr insertUser:self];
}

- (BOOL)validateForDelete:(NSError **)error
{
	if(![super validateForDelete:error]) return NO;
	
	SPUserManager *mgr = [self valueForKey:@"userManager"];
	
	return [mgr deleteUser:self];
}

- (BOOL)validateForUpdate:(NSError **)error
{
	if(![super validateForUpdate:error]) return NO;
	
	SPUserManager *mgr = [self valueForKey:@"userManager"];
	
	return [mgr updateUser:self];
}

@end
