//
//  PDFClient.m
//  Papers
//
//  Created by Philippe Schmid on 05.03.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import "PDFClient.h"

@implementation PDFClient

#pragma mark - Initializers

+ (PDFClient *)sharedPDFClient
{
    static PDFClient *_sharedPDFClient = nil;
    static dispatch_once_t oncePredicate = 0;
    dispatch_once(&oncePredicate, ^{
        _sharedPDFClient = [[PDFClient alloc] init];
    });
    return _sharedPDFClient;
}

#pragma mark - PDF Creation

- (void)createPDFForTitle:(NSString *)title withImages:(NSArray *)images callback:(Callback)callback
{
    // Create the PDF context using the default page size of 612 x 792
    UIGraphicsBeginPDFContextToFile(title, CGRectZero, nil);
    
    // Prepare the frame for the images
    CGRect frame = CGRectMake(0, 0, 612, 792);
    
    // Iterate over the images array
    for (UIImage *image in images) {
        // Begin a new PDF page
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
        
        // Draw every image to the PDF context
        [image drawInRect:frame];
    }
    
    // Close the PDF context and write the contents out
    UIGraphicsEndPDFContext();
    
    callback(YES, nil);
}

@end
