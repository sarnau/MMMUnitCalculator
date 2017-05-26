//
//  MMMValue.h
//  UnitParser
//
//  Created by Markus Fritze on 2/8/06.
//  Copyright 2006 Markus Fritze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMMValue : NSObject

/// 0.0 with no unit
+ (instancetype)value;
/// factor with no unit
+ (instancetype)valueWithFactor:(double)theFactor;
/// factor and unit
+ (instancetype)valueWithFactor:(double)theValue unit:(NSString*)theUnit;

+ (instancetype)valueWithString:(NSString*)theTerm;
+ (instancetype)valueWithString:(NSString*)theTerm variables:(NSDictionary<NSString *, MMMValue *> *)theVariables;
+ (instancetype)valueWithString:(NSString*)theTerm variables:(NSDictionary<NSString *, MMMValue *> *)theVariables requestedUnit:(NSString*)theUnit;


/// the full value with the unit normalized and converted into the optional requested unit
@property (readonly,nonatomic) MMMValue *value;

/// factor of the value
@property (readonly,nonatomic) double factor;

/// the unit string
@property (readonly,nonatomic) NSString *unit;

/// Full value plus unit string separated by a space
@property (readonly,nonatomic) NSString *description;


/// returns nil, if no error occurred
@property (nonatomic) NSString *error;

@end
