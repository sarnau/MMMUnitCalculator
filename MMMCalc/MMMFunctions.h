/*
 *  MMMFunctions.h
 *  UnitParser
 *
 *  Created by Markus Fritze on 2/17/06.
 *  Copyright 2006 Markus Fritze. All rights reserved.
 *
 */

@interface MMMValue (PrivateFunctions)

// value = value + n
- (MMMValue*)add:(MMMValue*)theValue;

// value = value - n
- (MMMValue*)sub:(MMMValue*)theValue;

// value = value * n
- (MMMValue*)mul:(MMMValue*)theValue;

// value = value / n
- (MMMValue*)div:(MMMValue*)theValue;

// value = value ^ n
- (MMMValue*)pow:(MMMValue*)theValue;

// value = value ^ 0.5
- (MMMValue*)sqrt;

// value = ln(value)
- (MMMValue*)ln;

// value = log2(value)
- (MMMValue*)log2;

// value = log(value)
- (MMMValue*)log;

// value = exp(value)
- (MMMValue*)exp;

// value = value without the sign
- (MMMValue*)abs;

// round to largest integral value not greater than x 
- (MMMValue*)floor;

// round to smallest integral value not less than x
- (MMMValue*)ceil;

// round to integral value
- (MMMValue*)round;

// minimum value out of 2
- (MMMValue*)min:(MMMValue*)theValue;

// maximum value out of 2
- (MMMValue*)max:(MMMValue*)theValue;

// compare two values for equal, returns 0, if not equal, 1 if equal
- (MMMValue*)compareEqual:(MMMValue*)theValue;

// Weight Watcher Points (TM and Patented)
// P = Calories / 50 + Fat / 12 - MIN(Fiber,4) / 5
- (MMMValue*)wwp:(MMMValue*)theFat :(MMMValue*)theDietaryFiberGrams;

// sum value out of n
- (MMMValue*)sum_A:(NSArray<MMMValue *> *)theValues;
// average value out of n
- (MMMValue*)avg_A:(NSArray<MMMValue *> *)theValues;
// min value out of n
- (MMMValue*)min_A:(NSArray<MMMValue *> *)theValues;
// max value out of n
- (MMMValue*)max_A:(NSArray<MMMValue *> *)theValues;

@end
