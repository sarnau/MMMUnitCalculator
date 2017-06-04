//
//  MMMCalc.mm
//  UnitParser
//
//  Created by Markus Fritze on 2/8/06.
//  Copyright 2006 Markus Fritze. All rights reserved.
//

#import "MMMValuePrivate.h"
#import "MMMFunctions.h"
#import "MMMUnits.h"

// for our dynamic functions
#import <objc/objc-runtime.h>
// explicity tying of object_msgSend() is required
typedef MMMValue *(*objc_msgSendTyped7Objects)(id, SEL, MMMValue *, MMMValue *, MMMValue *, MMMValue *, MMMValue *, MMMValue *, MMMValue *);
typedef MMMValue *(*objc_msgSendTypedNSArray)(id, SEL, NSArray<MMMValue *> *);


@interface MMMValue ()
@property (getter=isUsed) BOOL used;    // flag to avoid recursion
@end


@implementation MMMValue
{
	NSDictionary<NSString *, MMMValue *> *_variables;
	NSString        *_requestedUnit; // != nil => wanted unit
	NSString        *_error;         // error message, if != nil
	NSScanner       *_scanner;
    MMMUnits        *_unitInfo;
}

// ####################################################################################
#pragma mark -
#pragma mark units

- (void)setUnits:(NSDictionary<NSString *, NSNumber *> *)theUnits
{
	// Forcing units to be an empty dictionary simplifies the -equalUnits:
	// further down, because nil is equal to an empty dictionary (no unit)
	if(!theUnits) theUnits = [@{} mutableCopy];
	_units = [theUnits mutableCopy];
}

/// Remove all units which have a power of 0, because they are no longer necessary
- (void)removeRedundantUnits
{
	for(NSString *theKey in [self.units copy])    // copy, because we modify during the loop
	{
		NSInteger thePower = self.units[theKey].integerValue;
		if(thePower == 0)
			[self.units removeObjectForKey:theKey];
	}
}

- (BOOL)hasUnits
{
	[self removeRedundantUnits];
	return self.units.count != 0;    // if any units are left, we do have units
}

- (BOOL)equalUnits:(MMMValue*)theValue
{
	[self removeRedundantUnits];
	[theValue removeRedundantUnits];
	return [self.units isEqualToDictionary:theValue.units];
}

- (void)removeUnits
{
	[self.units removeAllObjects];
}

// ####################################################################################
#pragma mark -
#pragma mark simple value initializer

- (instancetype)initWithFactor:(double)theFactor units:(NSDictionary<NSString *, NSNumber *>*)theUnits
{
	if(self = [self init])
	{
		self.doubleValue = theFactor;
		self.units = [theUnits mutableCopy];
	}
	return self;
}

- (instancetype)initWithValue:(MMMValue*)theValue
{
	return [self initWithFactor:theValue.doubleValue units:theValue.units];
}

+ (instancetype)value
{
	return [[MMMValue alloc] init];
}

+ (instancetype)valueWithFactor:(double)theFactor
{
	return [[MMMValue alloc] initWithFactor:theFactor units:nil];
}

+ (instancetype)valueWithFactor:(double)theFactor units:(NSDictionary*)theUnits
{
	return [[MMMValue alloc] initWithFactor:theFactor units:theUnits];
}

+ (instancetype)valueWithValue:(MMMValue*)theValue
{
	return [[MMMValue alloc] initWithValue:theValue];
}


// ####################################################################################
#pragma mark -
#pragma mark error handling

- (void)mergeError:(MMMValue*)theValue
{
	if(_error != nil || theValue == nil)
		return;
	_error = theValue->_error;
}

// ####################################################################################
#pragma mark -
#pragma mark return values

/// return the value with the wanted unit (if set) merged together
- (MMMValue*)value
{
	// no special unit wanted? => we have nothing special to do!
	if(_requestedUnit == nil || _requestedUnit.length == 0)
		return self;

	// copy our value, because we might have to modify it
	MMMValue    *theValue = [MMMValue valueWithValue:self];

	// search for FROMUNIT>WANTEDUNIT, to see if we have a special back-conversion function
	NSMutableString    *theConvertUnitStr = [theValue normalizedUnitString];
	[theConvertUnitStr appendString:@">"];
	[theConvertUnitStr appendString:_requestedUnit];
	NSString    *theConvertUnitTerm = [_unitInfo findUnit:theConvertUnitStr];
	if(theConvertUnitTerm != nil)
	{
		// call that one! This is for a F=>C, etc. conversion, where a simple multiplication does not work
		theValue = [MMMValue valueWithString:theConvertUnitTerm variables:@{@"value": theValue}];

	} else {

		// otherwise just divide our unit value by the wanted unit value
		[theValue div:[MMMValue valueWithString:_requestedUnit]];

	}

	// we now multiply our wanted unit into the value
	[theValue mul:[MMMValue valueWithFactor:1.0 units:@{_requestedUnit: @1}]];

	return theValue;
}

// get a printable description of the unit
- (NSMutableString*)normalizedUnitString
{
	NSMutableString *theNumerator = [NSMutableString string];
	NSMutableString *theDenominator = [NSMutableString string];
	for(NSString *theKey in self.units)
	{
		NSInteger thePower = self.units[theKey].integerValue;
		if(thePower == 0)       // unit ^ 0 == 1
			continue;
		if(thePower > 0)        // in the numerator
		{
			if(theNumerator.length != 0)
				[theNumerator appendString:@"*"];
			[theNumerator appendString:theKey];
			if(thePower > 1)
				[theNumerator appendFormat:@"^%ld", thePower];
		} else {                // in the theDenominator
			if(theDenominator.length != 0)
				[theDenominator appendString:@"*"];
			[theDenominator appendString:theKey];
			if(thePower < -1)
				[theDenominator appendFormat:@"^%ld", -thePower];
		}
	}
	if(theDenominator.length != 0)
	{
		if(theNumerator.length == 0)
			[theNumerator appendString:@"1"];
		[theNumerator appendString:@"/"];
		[theNumerator appendString:theDenominator];
	}
	return theNumerator;
}

- (double)factor
{
	return self.value.doubleValue;
}

- (NSString*)unit
{
	return [self.value normalizedUnitString];
}

- (NSString*)description
{
	NSString        *theResponse = [NSString stringWithFormat:@"%g", self.factor];
	NSString        *theUnit = self.unit;
	if(theUnit.length)
		theResponse = [theResponse stringByAppendingFormat:@" %@", theUnit];
	return theResponse;
}

// ####################################################################################
- (MMMValue*)_calcVar
{
	// start with a default value: 1.0 without a unit. This allows a unit without a number. I am aware of this, but
    // there are many cases where a unit is a complex term, which needs to be implicitly multiplied by the value.
    // By assuming it is 1, if there is none, it solves issues around this.
	MMMValue        *theValue = [MMMValue valueWithFactor:1.0];
	BOOL foundValue = NO;                   // we should keep track if we actually found a value and/or a unit, otherwise => error
	// this avoids () being accepted as 1.0

	if([_scanner scanString:@"(" intoString:nil])
	{
		// a term in () (can be followed by a unit!)
		theValue = [self _calcTerm];
		if(![_scanner scanString:@")" intoString:nil])
		{
			self.error = @"Error: ')' missing";
		}
		foundValue = YES;

	} else if([_scanner scanString:@"[" intoString:nil])
	{
		// [value] = value without the unit (can be followed by a unit!)
		theValue = [self _calcTerm];
		if(![_scanner scanString:@"]" intoString:nil])
		{
			self.error = @"Error: ']' missing";
		}
		[theValue removeUnits];
		foundValue = YES;

	} else {
		// do we have a value? (can be followed by a unit!)
		double theNumber;
		if([_scanner scanDouble:&theNumber])
		{
			theValue = [MMMValue valueWithFactor:theNumber];
			foundValue = YES;

			// parsing hex numbers starting with $ bzw. $0x
//        } else if([_scanner scanString:@"$" intoString:nil])
//        {
//            unsigned long long theHexNumber;
//            if([_scanner scanHexLongLong:&theHexNumber])
//            {
//                theValue = [MMMValue valueWithFactor:theHexNumber];
//                foundValue = YES;
//            }
            
		} else {

			// first scan for functions and parameters
			NSUInteger theCurrentScanLocation = _scanner.scanLocation;
			NSString        *theString;
			while([_scanner scanCharactersFromSet:NSCharacterSet.alphanumericCharacterSet intoString:&theString])
			{
				if([theString isEqual:@"constE"])            // e (2.71828) as a constant
				{
					theValue = [MMMValue valueWithFactor:M_E];
					foundValue = YES;

				} else if([theString isEqual:@"constPI"])    // Pi (3.14159) as a constant
				{
					theValue = [MMMValue valueWithFactor:M_PI];
					foundValue = YES;

				} else if(_variables[theString] != nil)      // variables supplied?
				{
					// do we have a parameter with that name?
					theValue = _variables[theString];       // take that value

					theValue.used = YES;    // mark it as "used", so we don't force an implicit multiply

					// copy the variable, so we don't touch the original one!
					// This is important for the used-flag, because we check it a few lines down from here
					theValue = [MMMValue valueWithValue:theValue];

					foundValue = YES;

				} else {
					// search if we have a function (can not be followed by a unit!)
					if([_scanner scanString:@"(" intoString:nil])
					{
                        MMMValue        *v[8];// up to 8 parameters are allowed
						NSMutableArray<MMMValue *>      *av = [NSMutableArray array];
                        NSInteger vCount = 0;
                        memset(v, 0, sizeof(v));
                        NSMutableString *theParameterStr = [NSMutableString string];
						while(![_scanner scanString:@")" intoString:nil])
						{
							MMMValue        *vv = [self _calcTerm];
                            if(vCount < sizeof(v)/sizeof(v[0]))
                            {
                                if(vCount > 0)
                                    [av addObject:vv];
                                v[vCount++] = vv;
                            }
							[_scanner scanString:@"," intoString:nil];
                            if(vCount > 1)
                                [theParameterStr appendString:@":"];    // append a ':' for every parameter, but the first (which is self)
						}
						// try to find the function in our class
                        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@%@", theString, theParameterStr]);
						if(selector && [self respondsToSelector:selector])
						{
							theValue = ((objc_msgSendTyped7Objects)objc_msgSend)(v[0], selector, v[1], v[2], v[3], v[4], v[5], v[6], v[7]);
						} else {
							// search for a function that accepts an NSArray
							SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@_A:", theString]);
							if(selector && [self respondsToSelector:selector])
							{
								theValue = ((objc_msgSendTypedNSArray)objc_msgSend)(v[0], selector, av);
							} else {
								self.error = [NSString stringWithFormat:@"Function %@() not found", theString];
							}
						}
						return theValue;
					}
				}
			}
			// we might have found a string, but not a function => we have to reset our scan location to try again with the units
			if(!foundValue)
				_scanner.scanLocation = theCurrentScanLocation;
		}
	}

	// now we scan for possible units following the variable or term
	NSString        *theString;

	// we scan with the units character set, instead of NSCharacterSet.letterCharacterSet, to get all legal unit characters
	// (like degrees, micro, etc)
	while([_scanner scanCharactersFromSet:_unitInfo.unitCharacterset intoString:&theString])
	{
		foundValue = YES;

		// expect units
		MMMValue        *theUnitValue = nil;
		NSString        *theUnit = [_unitInfo findUnit:theString];
		if(theUnit == nil)
		{
			self.error = [NSString stringWithFormat:@"Unit '%@' not fully defined", theString];
		} else {
			if([theUnit isEqual:theString]) // unit stayed the same => we found an SI-unit
			{
				theUnitValue = [MMMValue valueWithFactor:1.0];
				theUnitValue.units = [@{theString: @1} mutableCopy];
			} else {
				// evaluate the unit, provide the current value as a parameter
				theUnitValue = [MMMValue valueWithString:theUnit variables:@{@"value": theValue}];
			}
			// the ^ binds strong to the unit, but not to the numeric value! We want 9 m^2 to be 9 m^2 and _NOT_ 81 m^2
			if([_scanner scanString:@"^" intoString:nil])
			{
				[theUnitValue pow:[self _calcVar]];
			}
			if(theValue.isUsed)             // if the value was consumed by the unit (via a formula) we don't multiply it in
			{                                               // this is useful for the C => K and F => K conversions!
				theValue = theUnitValue;
			} else {
				[theValue mul:theUnitValue];    // standard case: just multiply the factor and unit into our value
			}
		}
	}
	if(!foundValue)
	{
		self.error = @"Expected a value and/or a unit";
	}
	return theValue;
}

- (MMMValue*)_calcSign
{
	BOOL foundNegativeSign = NO;
	if([_scanner scanString:@"-" intoString:nil])
	{
		foundNegativeSign = YES;
	} else if([_scanner scanString:@"+" intoString:nil])
	{
		// just ignore the '+'
	}
	MMMValue        *theValue = [self _calcVar];
    if(foundNegativeSign) {
        // transfer the units to allow the subtraction from 0
		theValue = [[MMMValue valueWithFactor:0.0 units:theValue.units] sub:theValue];
    }
	return theValue;
}

- (MMMValue*)_calcPot
{
	MMMValue        *theValue = [self _calcSign];
	do {
		if([_scanner scanString:@"^" intoString:nil])
		{
			[theValue pow:[self _calcSign]];
		} else {
			break;
		}
	} while(1);
	return theValue;
}

- (MMMValue*)_calcMultiplication
{
	MMMValue        *theValue = [self _calcPot];
	do {
		if([_scanner scanString:@"*" intoString:nil])
		{
			[theValue mul:[self _calcPot]];
		} else if([_scanner scanString:@"/" intoString:nil])
		{
			[theValue div:[self _calcPot]];
		} else {
			break;
		}
	} while(1);
	return theValue;
}

- (MMMValue*)_calcAdd
{
	MMMValue        *theValue = [self _calcMultiplication];
	do {
		if([_scanner scanString:@"+" intoString:nil])
		{
			[theValue add:[self _calcMultiplication]];
		} else if([_scanner scanString:@"-" intoString:nil])
		{
			[theValue sub:[self _calcMultiplication]];
		} else {
			break;
		}
	} while(1);
	return theValue;
}

- (MMMValue*)_calcCompare
{
	MMMValue        *theValue = [self _calcAdd];
	do {
		if([_scanner scanString:@"=" intoString:nil])
		{
			[theValue compareEqual:[self _calcAdd]];
		} else {
			break;
		}
	} while(1);
	return theValue;
}

- (MMMValue*)_calcTerm
{
	return [self _calcCompare];
}

- (instancetype)initWithString:(NSString*)theTerm variables:(NSDictionary<NSString *, MMMValue *> *)theVariables requestedUnit:(NSString*)theUnit unitInfo:(MMMUnits *)unitInfo
{
	if(self = [super init])
	{
		_scanner = [NSScanner scannerWithString:theTerm];
		_scanner.charactersToBeSkipped = NSCharacterSet.whitespaceCharacterSet;

		_variables = theVariables;
		_requestedUnit = theUnit;
        _unitInfo = unitInfo ?: MMMUnits.sharedUnits;    // default to the units.dat file

		MMMValue        *theValue = [self _calcTerm];
        self.doubleValue = theValue.doubleValue;
        self.units = theValue.units;
        [self mergeError:theValue];

		if(!_scanner.atEnd)
		{
			self.error = [NSString stringWithFormat:@"Error: end expected, but not reached: %@", _scanner.string];
		}

		// we no longer need these objects
		_variables = nil;
		_scanner = nil;
	}
	return self;
}

// ####################################################################################
#pragma mark -
#pragma mark class methods to construct the value

+ (instancetype)valueWithString:(NSString*)theTerm
{
	return [[MMMValue alloc] initWithString:theTerm variables:nil requestedUnit:nil unitInfo:nil];
}

+ (instancetype)valueWithString:(NSString*)theTerm variables:(NSDictionary<NSString *, MMMValue *>*)theVariables
{
	return [[MMMValue alloc] initWithString:theTerm variables:theVariables requestedUnit:nil unitInfo:nil];
}

+ (instancetype)valueWithString:(NSString*)theTerm variables:(NSDictionary<NSString *, MMMValue *>*)theVariables requestedUnit:(NSString*)theUnit
{
	return [[MMMValue alloc] initWithString:theTerm variables:theVariables requestedUnit:theUnit unitInfo:nil];
}

+ (nullable instancetype)valueWithString:(nonnull NSString*)theTerm variables:(nullable NSDictionary<NSString *, MMMValue *> *)theVariables requestedUnit:(nullable NSString*)theUnit unitInfo:(nullable MMMUnits *)unitInfo
{
    return [[MMMValue alloc] initWithString:theTerm variables:theVariables requestedUnit:theUnit unitInfo:unitInfo];
}

+ (instancetype)valueWithFactor:(double)theValue unit:(NSString*)theUnit;
{
	MMMValue        *valueWithFactor = [MMMValue valueWithString:theUnit];
	[valueWithFactor mul:[MMMValue valueWithFactor:theValue]];
	return valueWithFactor;
}
@end
