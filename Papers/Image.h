//
//  Image.h
//  Papers
//
//  Created by Philippe Schmid on 28.03.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PDF;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) PDF *pdf;

@end
