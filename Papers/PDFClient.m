//
//  PDFClient.m
//  Papers
//
//  Created by Philippe Schmid on 05.03.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import "PDFClient.h"
#import <CoreText/CoreText.h>

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

- (void)createPDF
{
    
}

#pragma mark - Helpers

- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
}

@end
