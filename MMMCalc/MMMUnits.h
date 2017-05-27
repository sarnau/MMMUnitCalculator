//
//  MMMUnits.h
//  UnitParser
//
//  Created by Markus Fritze on 2/7/06.
//  Copyright 2006 Markus Fritze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMMUnits : NSObject

/// This allows loading a custom unit table via a NSURL
- (instancetype)initWithURL:(NSURL *)unitURL;
/// This allows loading a custom unit table from a string
- (instancetype)initWithString:(NSString *)unitDataString NS_DESIGNATED_INITIALIZER;

/// This will load a units.dat from the main bundle. A singleton, because we only want to load this file once.
@property (readonly, class) MMMUnits *sharedUnits;

/// Any parsing errors. This is typically only necessary for unit tests
@property NSString *parseError;

/// Resolve a unit
- (NSString *)findUnit:(NSString *)theUnit;

/// character set with all special characters from units to allow the parser to detect them without knowing them
@property (readonly) NSCharacterSet *unitCharacterset;

@end
