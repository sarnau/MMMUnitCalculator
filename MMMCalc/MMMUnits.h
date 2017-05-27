//
//  MMMUnits.h
//  UnitParser
//
//  Created by Markus Fritze on 2/7/06.
//  Copyright 2006 Markus Fritze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMMUnits : NSObject

@property (readonly, class) MMMUnits *sharedUnits;     // A singleton, because we only want to load the unit file once
@property (readonly) NSCharacterSet *unitCharacterset; // character set with all special characters from units to allow the parser to detect them without knowing them

- (instancetype)initWithString:(NSString *)unitDataString NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithURL:(NSURL *)unitURL;

@property NSString *parseError;

// Resolve a unit
- (NSString *)findUnit:(NSString *)theUnit;

@end
