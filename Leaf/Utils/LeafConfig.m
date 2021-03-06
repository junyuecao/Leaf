//
//  LeafConfig.m
//  Leaf
//
//  Created by roger qian on 13-3-13.
//  Copyright (c) 2013年 Mobimtech. All rights reserved.
//

#import "LeafConfig.h"
#import "LeafHelper.h"
#import "Reachability.h"

#define kSimpleMode @"SimpleMode"
#define kOfflineState @"OfflineState"

@implementation LeafConfig
@synthesize simple = _simple;
@synthesize offline = _offline;

static LeafConfig *_instance;

+ (id)sharedInstance
{
    @synchronized(self){
        if (!_instance) {
            _instance = [[self alloc] init];
        }
    }
    
    return _instance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self){
        if (!_instance) {
            _instance = [super allocWithZone:zone];
            return _instance;
        }
    }
    return nil;
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}



#pragma mark - 
#pragma mark - Leaf Config Stuff

- (BOOL)showPicture
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    return !(([reachability currentReachabilityStatus] != ReachableViaWiFi)&&_simple);
}

- (void)setSimple:(BOOL)simple
{
    _simple = simple;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:_simple forKey:kSimpleMode];
}

- (void)setOffline:(BOOL)offline
{
    _offline = offline;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:offline forKey:kOfflineState];
}

- (void)refreshConfig
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    _simple = [ud boolForKey:kSimpleMode];
    _offline = [ud boolForKey:kOfflineState];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self refreshConfig];
    }
    
    return self;
}



@end
