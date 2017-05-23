//
//  TestMMMCalc.mm
//  UnitParser
//
//  Created by Markus Fritze on 2/19/06.
//  Copyright (c) 2006 Markus Fritze. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MMMCalc.h"
//#import "MMMUnits.h"

@interface TestMMMCalc : SenTestCase {

}
@end

@implementation TestMMMCalc
- (void) setUp
{
}
 
- (void) tearDown
{
//	[MMMUnits removeUnits];
}

- (NSString*) testCalcValue:(const char *)term unit:(const char *)unit parameter:(NSDictionary *)params
{
	NSString	*ts = [NSString stringWithUTF8String:term];
	NSString	*us = unit ? [NSString stringWithUTF8String:unit] : nil;
	MMMValue	*mv = [MMMValue valueWithString:ts parameter:params wantedUnit:us];
	if([mv error])
	{
		return [mv error];
	} else {
		return [mv description];
	}
}

- (void) testCase1
{
	STAssertEqualObjects([self testCalcValue:"1/(8 l/100km)" unit:"mpg" parameter:nil], @"29.4018 mpg", nil);
//	STAssertEqualObjects([self testCalcValue:"1/(20*mpg)" unit:"l/l/100km" parameter:nil], @"11.7607 l/100km", nil);

	STAssertEqualObjects([self testCalcValue:"1 %" unit:nil parameter:nil], @"0.01", nil);
	STAssertEqualObjects([self testCalcValue:"1 \u2030" unit:nil parameter:nil], @"0.001", nil);	// 0/00
	STAssertEqualObjects([self testCalcValue:"1 \u2031" unit:nil parameter:nil], @"0.0001", nil);	// 0/000

	STAssertEqualObjects([self testCalcValue:"sum(1,2,3,4)" unit:nil parameter:nil], @"10", nil);
	STAssertEqualObjects([self testCalcValue:"avg(1,2,3,4)" unit:nil parameter:nil], @"2.5", nil);
	STAssertEqualObjects([self testCalcValue:"min(1,2,0.2,3,4)" unit:nil parameter:nil], @"0.2", nil);
	STAssertEqualObjects([self testCalcValue:"max(1,2,0.2,4,3)" unit:nil parameter:nil], @"4", nil);

	STAssertEqualObjects([self testCalcValue:"asin(0)" unit:nil parameter:nil], @"0", nil);
	STAssertEqualObjects([self testCalcValue:"acos(0)" unit:nil parameter:nil], @"1.5708", nil);
	STAssertEqualObjects([self testCalcValue:"atan(0)" unit:nil parameter:nil], @"0", nil);
	STAssertEqualObjects([self testCalcValue:"atan2(0,0)" unit:nil parameter:nil], @"0", nil);

	STAssertEqualObjects([self testCalcValue:"sin(0)" unit:nil parameter:nil], @"0", nil);
	STAssertEqualObjects([self testCalcValue:"sin(PI/2)" unit:nil parameter:nil], @"1", nil);
	STAssertEqualObjects([self testCalcValue:"sin(PI)" unit:nil parameter:nil], @"1.22465e-16", nil);

	STAssertEqualObjects([self testCalcValue:"cos(0)" unit:nil parameter:nil], @"1", nil);
	STAssertEqualObjects([self testCalcValue:"cos(PI/2)" unit:nil parameter:nil], @"6.12323e-17", nil);
	STAssertEqualObjects([self testCalcValue:"cos(PI)" unit:nil parameter:nil], @"-1", nil);

	STAssertEqualObjects([self testCalcValue:"tan(0)" unit:nil parameter:nil], @"0", nil);
	STAssertEqualObjects([self testCalcValue:"tan(PI/2)" unit:nil parameter:nil], @"1.63312e+16", nil);
	STAssertEqualObjects([self testCalcValue:"tan(PI)" unit:nil parameter:nil], @"-1.22465e-16", nil);

	STAssertEqualObjects([self testCalcValue:"sinh(0)" unit:nil parameter:nil], @"0", nil);
	STAssertEqualObjects([self testCalcValue:"cosh(0)" unit:nil parameter:nil], @"1", nil);
	STAssertEqualObjects([self testCalcValue:"tanh(0)" unit:nil parameter:nil], @"0", nil);

	STAssertEqualObjects([self testCalcValue:"ln(1)" unit:nil parameter:nil], @"0", nil);
	STAssertEqualObjects([self testCalcValue:"ln(constE)" unit:nil parameter:nil], @"1", nil);
	STAssertEqualObjects([self testCalcValue:"log(1)" unit:nil parameter:nil], @"0", nil);
	STAssertEqualObjects([self testCalcValue:"log(10)" unit:nil parameter:nil], @"1", nil);
	STAssertEqualObjects([self testCalcValue:"log2(1)" unit:nil parameter:nil], @"0", nil);
	STAssertEqualObjects([self testCalcValue:"log2(2)" unit:nil parameter:nil], @"1", nil);
	STAssertEqualObjects([self testCalcValue:"exp(0)" unit:nil parameter:nil], @"1", nil);
	STAssertEqualObjects([self testCalcValue:"exp(1)=constE" unit:nil parameter:nil], @"1", nil);

	STAssertEqualObjects([self testCalcValue:"1 Hz * 60" unit:nil parameter:nil], @"60 1/s", nil);
	STAssertEqualObjects([self testCalcValue:"60*180'/PI" unit:nil parameter:nil], @"1", nil);
	STAssertEqualObjects([self testCalcValue:"1000 \u00B5m" unit:"mm" parameter:nil], @"1 mm", nil);		// um

	STAssertEqualObjects([self testCalcValue:"wwp(280 kcal, 1g, 7g)" unit:nil parameter:nil], @"5", nil);
	STAssertEqualObjects([self testCalcValue:"1 knot" unit:"km/h" parameter:nil], @"1.852 km/h", nil);
	STAssertEqualObjects([self testCalcValue:"val" unit:nil parameter:[NSDictionary dictionaryWithObject:[MMMValue valueWithFactor:42.0 unit:@"mm"] forKey:@"val"]], @"0.042 m", nil);

	STAssertEqualObjects([self testCalcValue:"abs(-(1+1))" unit:nil parameter:nil], @"2", nil);
	STAssertEqualObjects([self testCalcValue:"-((1+1))=-2" unit:nil parameter:nil], @"1", nil);

	STAssertEqualObjects([self testCalcValue:"77 \u2109" unit:"\u2103" parameter:nil], [NSString stringWithUTF8String:"25 \u2103"], nil);	// degF => degC
	STAssertEqualObjects([self testCalcValue:"25 \u2103" unit:"\u2109" parameter:nil], [NSString stringWithUTF8String:"77 \u2109"], nil);	// degC => degF


	STAssertEqualObjects([self testCalcValue:"200 bar" unit:"bar" parameter:nil], @"200 bar", nil);
	STAssertEqualObjects([self testCalcValue:"3000 psi" unit:"bar" parameter:nil], @"206.843 bar", nil);
	STAssertEqualObjects([self testCalcValue:"1 atm" unit:"bar" parameter:nil], @"1.01325 bar", nil);
	STAssertEqualObjects([self testCalcValue:"1 Torr*760" unit:"atm" parameter:nil], @"1 atm", nil);

	STAssertEqualObjects([self testCalcValue:"65 C" unit:nil parameter:nil], @"338.15 K", nil);
	STAssertEqualObjects([self testCalcValue:"65 F" unit:nil parameter:nil], @"291.483 K", nil);
	STAssertEqualObjects([self testCalcValue:"65 K" unit:nil parameter:nil], @"65 K", nil);

	STAssertEqualObjects([self testCalcValue:"65 mph" unit:nil parameter:nil], @"29.0576 m/s", nil);
	STAssertEqualObjects([self testCalcValue:"65 cm" unit:nil parameter:nil], @"0.65 m", nil);

	STAssertEqualObjects([self testCalcValue:"20 lb" unit:"kg" parameter:nil], @"9.07185 kg", nil);
	STAssertEqualObjects([self testCalcValue:"1000 g" unit:"kg" parameter:nil], @"1 kg", nil);
	STAssertEqualObjects([self testCalcValue:"1 kg" unit:"g" parameter:nil], @"1000 g", nil);

	STAssertEqualObjects([self testCalcValue:"sqrt(9 m^2)" unit:nil parameter:nil], @"3 m", nil);
	STAssertEqualObjects([self testCalcValue:"9 m^2" unit:nil parameter:nil], @"9 m^2", nil);
	STAssertEqualObjects([self testCalcValue:"(9*m^2)^0.5" unit:nil parameter:nil], @"3 m", nil);

	STAssertEqualObjects([self testCalcValue:"60 m + 2 s" unit:nil parameter:nil], @"Term '60 m' and '2 s' can't be added", nil);

	STAssertEqualObjects([self testCalcValue:"((123.45e-1 + sqrt(+4) -4-.69/2)*2^1/5)^2" unit:nil parameter:nil], @"16", nil);
	STAssertEqualObjects([self testCalcValue:"60m*2m" unit:nil parameter:nil], @"120 m^2", nil);
	STAssertEqualObjects([self testCalcValue:"60m*2s" unit:nil parameter:nil], @"120 m*s", nil);
	STAssertEqualObjects([self testCalcValue:"60m/2m" unit:nil parameter:nil], @"30", nil);
	STAssertEqualObjects([self testCalcValue:"60m/2s" unit:nil parameter:nil], @"30 m/s", nil);
	STAssertEqualObjects([self testCalcValue:"60 m + 2 mm" unit:nil parameter:nil], @"60.002 m", nil);

	STAssertEqualObjects([self testCalcValue:"(9.81 m)^0" unit:nil parameter:nil], @"1", nil);
	STAssertEqualObjects([self testCalcValue:"(9.81 m)^1" unit:nil parameter:nil], @"9.81 m", nil);
	STAssertEqualObjects([self testCalcValue:"(9.81 m)^2" unit:nil parameter:nil], @"96.2361 m^2", nil);
	STAssertEqualObjects([self testCalcValue:"9.81 m/s^2" unit:nil parameter:nil], @"9.81 m/s^2", nil);

	STAssertEqualObjects([self testCalcValue:"60 km/h + 12 m/s" unit:"km/h" parameter:nil], @"103.2 km/h", nil);
	STAssertEqualObjects([self testCalcValue:"12 m/s" unit:"km/h" parameter:nil], @"43.2 km/h", nil);
	STAssertEqualObjects([self testCalcValue:"43.2 km/h" unit:nil parameter:nil], @"12 m/s", nil);
}
@end

int main(int argc, const char *argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"This is just the SenTestCase build. If it builds correctly, you are fine.");
	[pool release];
}
