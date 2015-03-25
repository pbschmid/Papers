//
//  DropboxClient.m
//  Papers
//
//  Created by Philippe Schmid on 25.03.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import "DropboxClient.h"

@implementation DropboxClient

#pragma mark - Initializers

+ (DropboxClient *)sharedDropboxClient
{
    static DropboxClient *_sharedDropboxClient = nil;
    static dispatch_once_t oncePredicate = 0;
    dispatch_once(&oncePredicate, ^{
        _sharedDropboxClient = [[DropboxClient alloc] init];
    });
    return _sharedDropboxClient;
}

@end
