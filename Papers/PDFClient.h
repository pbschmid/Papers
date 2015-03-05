//
//  PDFClient.h
//  Papers
//
//  Created by Philippe Schmid on 05.03.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFClient : NSObject

+ (PDFClient *)sharedPDFClient;
- (void)createPDF;
- (NSString *)documentsPathForFileName:(NSString *)name;

@end
