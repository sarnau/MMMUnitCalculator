//
//  MMMValue.h
//  UnitParser
//
//  Created by Markus Fritze on 2/8/06.
//  Copyright 2006 Markus Fritze. All rights reserved.
//

#import "MMMValue.h"

@interface MMMValue ()

@property (readwrite,nonatomic) double doubleValue;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSNumber *> *units; // a directory of units: key = unit, value = power (can be negative! => NSCountedSet does not work)
@property (readonly) BOOL hasUnits;

- (BOOL)equalUnits:(MMMValue*)theValue;
- (void)removeUnits;

- (void)mergeError:(MMMValue*)theValue;

@end
