//
//  MMMFunctions.mm
//  UnitParser
//
//  Created by Markus Fritze on 2/17/06.
//  Copyright 2006 Markus Fritze. All rights reserved.
//

#import "MMMValuePrivate.h"
#import "MMMFunctions.h"


#define ALLOW_ADD_UNIT_PLUS_NO_UNITS            0    // This allows adding/subtracting a value without a unit from a unit with a value

@implementation MMMValue (InternalFunctions)

// ####################################################################################
/// value = value + n
- (MMMValue*)add:(MMMValue*)theValue
{
	// for the + operation the units have to be identical
	if(![self equalUnits:theValue])
	{
#if ALLOW_ADD_UNIT_PLUS_NO_UNITS
		if(self.hasUnits || theValue.hasUnits)
		{
#endif
		self.error = [NSString stringWithFormat:@"Term '%@' and '%@' can't be added", self, theValue];
		return self;
#if ALLOW_ADD_UNIT_PLUS_NO_UNITS
	}
#endif
	}

	self.doubleValue = self.doubleValue + theValue.doubleValue;
#if ALLOW_ADD_UNIT_PLUS_NO_UNITS
	if(!self.hasUnits)
		self.units = theValue.units;
#endif
	[self mergeError:theValue];
	return self;
}


/// value = value - n
- (MMMValue*)sub:(MMMValue*)theValue
{
	// for the - operation the units have to be identical
	if(![self equalUnits:theValue])
	{
#if ALLOW_ADD_UNIT_PLUS_NO_UNITS
		if(self.hasUnits || theValue.hasUnits)
		{
#endif
		self.error = [NSString stringWithFormat:@"Term '%@' and '%@' can't be subtracted", self, theValue];
		return self;
#if ALLOW_ADD_UNIT_PLUS_NO_UNITS
	}
#endif
	}

	self.doubleValue = self.doubleValue - theValue.doubleValue;
#if ALLOW_ADD_UNIT_PLUS_NO_UNITS
	if(!self.hasUnits)
		self.units = theValue.units;
#endif
	[self mergeError:theValue];
	return self;
}

/// value = value * n
- (MMMValue*)mul:(MMMValue*)theValue
{
	self.doubleValue = self.doubleValue * theValue.doubleValue;

	// m^2 * m^3 = m^5
	for(NSString *key in theValue.units)
		self.units[key] = @(self.units[key].integerValue + theValue.units[key].integerValue);

	[self mergeError:theValue];
	return self;
}

/// value = value / n
- (MMMValue*)div:(MMMValue*)theValue
{
	if(theValue.doubleValue == 0)
	{
		self.error = @"Division by zero";
	} else {
		self.doubleValue = self.doubleValue / theValue.doubleValue;

		// m^2 / m^3 = m^-1
		for(NSString *key in theValue.units)
			self.units[key] = @(self.units[key].integerValue - theValue.units[key].integerValue);
	}
	[self mergeError:theValue];
	return self;
}

/// value = value ^ n
- (MMMValue*)pow:(MMMValue*)theValue
{
	if(theValue.hasUnits)
	{
		self.error = [NSString stringWithFormat:@"Error: power '%@' can not have a unit", theValue];
		return self;
	}

	double power = theValue.doubleValue;

	// n^0 = 1
	if(power == 0)
	{
		self.doubleValue = 1.0;
		[self removeUnits];
		return self;
	}

	if(floor(power) != power && floor(1.0 / power) != (1.0 / power))
	{
		self.error = [NSString stringWithFormat:@"Error: power %g is not an integer", theValue.doubleValue];
	}
	self.doubleValue = pow(self.doubleValue, power);

	for(NSString *key in self.units)
		self.units[key] = @((NSInteger)(self.units[key].doubleValue * power));

	[self mergeError:theValue];
	return self;
}

// ####################################################################################
/// value = sin(value)
- (MMMValue*)sin
{
	if(self.hasUnits)
	{
		self.error = [NSString stringWithFormat:@"Error: sin '%@' can not have a unit", self];
		return self;
	}
	self.doubleValue = sin(self.doubleValue);
	return self;
}

/// value = cos(value)
- (MMMValue*)cos
{
	if(self.hasUnits)
	{
		self.error = [NSString stringWithFormat:@"Error: cos '%@' can not have a unit", self];
		return self;
	}
	self.doubleValue = cos(self.doubleValue);
	return self;
}

/// value = tan(value)
- (MMMValue*)tan
{
	if(self.hasUnits)
	{
		self.error = [NSString stringWithFormat:@"Error: tan '%@' can not have a unit", self];
		return self;
	}
	self.doubleValue = tan(self.doubleValue);
	return self;
}

/// value = asin(value)
- (MMMValue*)asin
{
	if(self.hasUnits)
	{
		self.error = [NSString stringWithFormat:@"Error: asin '%@' can not have a unit", self];
		return self;
	}
	self.doubleValue = asin(self.doubleValue);
	return self;
}

/// value = acos(value)
- (MMMValue*)acos
{
	if(self.hasUnits)
	{
		self.error = [NSString stringWithFormat:@"Error: acos '%@' can not have a unit", self];
		return self;
	}
	self.doubleValue = acos(self.doubleValue);
	return self;
}

/// value = atan(value)
- (MMMValue*)atan
{
	if(self.hasUnits)
	{
		self.error = [NSString stringWithFormat:@"Error: atan '%@' can not have a unit", self];
		return self;
	}
	self.doubleValue = atan(self.doubleValue);
	return self;
}

/// value = sinh(value)
- (MMMValue*)sinh
{
	if(self.hasUnits)
	{
		self.error = [NSString stringWithFormat:@"Error: sinh '%@' can not have a unit", self];
		return self;
	}
	self.doubleValue = sinh(self.doubleValue);
	return self;
}

/// value = cosh(value)
- (MMMValue*)cosh
{
	if(self.hasUnits)
	{
		self.error = [NSString stringWithFormat:@"Error: cosh '%@' can not have a unit", self];
		return self;
	}
	self.doubleValue = cosh(self.doubleValue);
	return self;
}

/// value = tanh(value)
- (MMMValue*)tanh
{
	if(self.hasUnits)
	{
		self.error = [NSString stringWithFormat:@"Error: tanh '%@' can not have a unit", self];
		return self;
	}
	self.doubleValue = tanh(self.doubleValue);
	return self;
}

/// value = asinh(value)
- (MMMValue*)asinh
{
	if(self.hasUnits)
	{
		self.error = [NSString stringWithFormat:@"Error: asinh '%@' can not have a unit", self];
		return self;
	}
	self.doubleValue = asinh(self.doubleValue);
	return self;
}

/// value = acosh(value)
- (MMMValue*)acosh
{
	if(self.hasUnits)
	{
		self.error = [NSString stringWithFormat:@"Error: acosh '%@' can not have a unit", self];
		return self;
	}
	self.doubleValue = acosh(self.doubleValue);
	return self;
}

/// value = atanh(value)
- (MMMValue*)atanh
{
	if(self.hasUnits)
	{
		self.error = [NSString stringWithFormat:@"Error: atanh '%@' can not have a unit", self];
		return self;
	}
	self.doubleValue = atanh(self.doubleValue);
	return self;
}

/// value = atan2(val1, val2)
- (MMMValue*)atan2:(MMMValue*)val2
{
	if(self.hasUnits)
	{
		self.error = [NSString stringWithFormat:@"Error: atan2 '%@' can not have a unit", self];
		return self;
	}
	if(val2.hasUnits)
	{
		val2.error = [NSString stringWithFormat:@"Error: atan2 '%@' can not have a unit", val2];
		return self;
	}
	self.doubleValue = atan2(self.doubleValue, val2.doubleValue);
	return self;
}

/////////////////////////////////

/// value = value ^ 0.5
- (MMMValue*)sqrt
{
	return [self pow:[MMMValue valueWithFactor:0.5]];
}

/// value = ln(value)
- (MMMValue*)ln
{
	if(self.hasUnits)
	{
		self.error = [NSString stringWithFormat:@"Error: ln '%@' can not have a unit", self];
		return self;
	}

	double f = self.doubleValue;
	if(f <= 0)
	{
		self.error = [NSString stringWithFormat:@"ln <= 0 not allowed"];
	}
	self.doubleValue = log(f);
	return self;
}

/// value = log2(value)
- (MMMValue*)log2
{
	if(self.hasUnits)
	{
		self.error = [NSString stringWithFormat:@"Error: log2 '%@' can not have a unit", self];
		return self;
	}

	double f = self.doubleValue;
	if(f <= 0)
	{
		self.error = [NSString stringWithFormat:@"log2 <= 0 not allowed"];
	}
	self.doubleValue = log2(f);
	return self;
}

/// value = log(value)
- (MMMValue*)log
{
	if(self.hasUnits)
	{
		self.error = [NSString stringWithFormat:@"Error: log '%@' can not have a unit", self];
		return self;
	}

	double f = self.doubleValue;
	if(f <= 0)
	{
		self.error = [NSString stringWithFormat:@"log <= 0 not allowed"];
	}
	self.doubleValue = log10(f);
	return self;
}

/// value = exp(value)
- (MMMValue*)exp
{
	if(self.hasUnits)
	{
		self.error = [NSString stringWithFormat:@"Error: exp '%@' can not have a unit", self];
		return self;
	}

	self.doubleValue = pow(M_E, self.doubleValue);  // e^factor
	return self;
}

/// value = value without the sign
- (MMMValue*)abs
{
	self.doubleValue = fabs(self.doubleValue);
	return self;
}

/// round to largest integral value not greater than x
- (MMMValue*)floor
{
	self.doubleValue = floor(self.doubleValue);
	return self;
}

/// round to smallest integral value not less than x
- (MMMValue*)ceil
{
	self.doubleValue = ceil(self.doubleValue);
	return self;
}

/// round to integral value
- (MMMValue*)round
{
	self.doubleValue = rint(self.doubleValue);
	return self;
}

/// minimum value out of 2
- (MMMValue*)min:(MMMValue*)theValue
{
	if(![self equalUnits:theValue])
	{
		self.error = [NSString stringWithFormat:@"Term '%@' and '%@' can't be compared via min", self, theValue];
		return self;
	}
	if(self.doubleValue < theValue.doubleValue)
		return self;
	else
		return theValue;
}

/// maximum value out of 2
- (MMMValue*)max:(MMMValue*)theValue
{
	if(![self equalUnits:theValue])
	{
		self.error = [NSString stringWithFormat:@"Term '%@' and '%@' can't be compared via max", self, theValue];
		return self;
	}
	if(self.doubleValue > theValue.doubleValue)
		return self;
	else
		return theValue;
}

// ####################################################################################
/// compare two values for equal, returns 0, if not equal, 1 if equal
- (MMMValue*)compareEqual:(MMMValue*)theValue
{
	self.doubleValue = [self equalUnits:theValue] && self.doubleValue == theValue.doubleValue;
	[self removeUnits];
	return self;
}

// ####################################################################################
/// Weight Watcher Points (TM and Patented)
/// P = Calories / 50kcal + Fat / 12g - MIN(Fiber,4g) / 5g
- (MMMValue*)wwp:(MMMValue*)theFat :(MMMValue*)theDietaryFiberGrams
{
	MMMValue        *theValue = [self div:[[MMMValue valueWithFactor:50.0] mul:[MMMValue valueWithString:@"kcal"]]];
	[theValue add:[theFat div:[MMMValue valueWithString:@"12 g"]]];
	[theValue sub:[[theDietaryFiberGrams min:[MMMValue valueWithString:@"4 g"]] div:[MMMValue valueWithString:@"5 g"]]];
	return [theValue ceil];
}

// ####################################################################################
#pragma mark -
#pragma mark NSArray functions

/// sum value out of n
- (MMMValue*)sum_A:(NSArray<MMMValue *> *)theValues
{
	for(MMMValue *aValue in theValues)
		[self add:aValue];
	return self;
}

/// average value out of n
- (MMMValue*)avg_A:(NSArray<MMMValue *> *)theValues
{
	MMMValue *theValue = [self sum_A:theValues];
	[theValue div:[MMMValue valueWithFactor:theValues.count+1]];
	return theValue;
}

/// min value out of n
- (MMMValue*)min_A:(NSArray<MMMValue *> *)theValues
{
	MMMValue *theValue = self;
	for(MMMValue *aValue in theValues)
		theValue = [theValue min:aValue];
	return theValue;
}

/// max value out of n
- (MMMValue*)max_A:(NSArray<MMMValue *> *)theValues
{
	MMMValue *theValue = self;
	for(MMMValue *aValue in theValues)
		theValue = [theValue max:aValue];
	return theValue;
}

@end
