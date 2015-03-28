//
//  PDF.h
//  Papers
//
//  Created by Philippe Schmid on 28.03.15.
//  Copyright (c) 2015 Philippe Schmid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Image;

@interface PDF : NSManagedObject

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSSet *images;
@end

@interface PDF (CoreDataGeneratedAccessors)

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
