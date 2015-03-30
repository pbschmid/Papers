//
//  PDFClient.h
//  Papers
//
//  Created by Philippe Schmid on 05.03.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^Callback)(BOOL success, NSError *error);

@interface PDFClient : NSObject

+ (PDFClient *)sharedPDFClient;
- (void)createPDFForTitle:(NSString *)title withImages:(NSArray *)images callback:(Callback)callback;

@end
