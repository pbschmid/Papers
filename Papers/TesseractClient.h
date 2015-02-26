//
//  TesseractClient.h
//  Papers
//
//  Created by Philippe Schmid on 02.02.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionBlock)(BOOL success, NSString *response, NSError *error);

@interface TesseractClient : NSObject

+ (TesseractClient *)sharedTesseractClient;
- (void)startScanningImage:(UIImage *)image withCallback:(CompletionBlock)block;
- (NSString *)documentsPathForFileName:(NSString *)name;

@end
