//
//  Image.h
//  Papers
//
//  Created by Philippe Schmid on 02.02.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ImageDetails;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) ImageDetails *imageDetails;

@end
