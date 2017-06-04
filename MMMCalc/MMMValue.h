//
//  MMMValue.h
//  UnitParser
//
//  Created by Markus Fritze on 2/8/06.
//  Copyright 2006 Markus Fritze. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMMUnits;

@interface MMMValue : NSObject

/// 0.0 with no unit
+ (nullable instancetype)value;
/// factor with no unit
+ (nullable instancetype)valueWithFactor:(double)theFactor;
/// factor and unit
+ (nullable instancetype)valueWithFactor:(double)theValue unit:(nonnull NSString*)theUnit;

+ (nullable instancetype)valueWithString:(nonnull NSString*)theTerm;
+ (nullable instancetype)valueWithString:(nonnull NSString*)theTerm variables:(nullable NSDictionary<NSString *, MMMValue *> *)theVariables;
+ (nullable instancetype)valueWithString:(nonnull NSString*)theTerm variables:(nullable NSDictionary<NSString *, MMMValue *> *)theVariables requestedUnit:(nullable NSString*)theUnit;
+ (nullable instancetype)valueWithString:(nonnull NSString*)theTerm variables:(nullable NSDictionary<NSString *, MMMValue *> *)theVariables requestedUnit:(nullable NSString*)theUnit unitInfo:(nullable MMMUnits *)unitInfo;


/// the full value with the unit normalized and converted into the optional requested unit
@property (nullable,readonly,nonatomic) MMMValue *value;

/// factor of the value
@property (readonly,nonatomic) double factor;

/// the unit string
@property (nullable,readonly,nonatomic) NSString *unit;

/// Full value plus unit string separated by a space
@property (nullable,readonly,nonatomic) NSString *description;


/// returns nil, if no error occurred
@property (nullable,nonatomic) NSString *error;

@end
