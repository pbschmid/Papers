//
//  ImageProcessor.h
//  Papers
//
//  Created by Philippe Schmid on 25.03.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompletionBlock)(BOOL success, NSArray *results, NSError *error);

@interface ImageProcessor : NSObject

+ (ImageProcessor *)sharedImageProcessor;
- (void)preprocessImages:(NSArray *)imagesToProcess withCallback:(CompletionBlock)callback;

@end
