//
//  MMMCalcTests.m
//  MMMCalcTests
//
//  Created by Markus Fritze on 23.05.17.
//  Copyright © 2017 Markus Fritze. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MMMValue.h"
#import "MMMUnits.h"

@interface MMMCalcTests : XCTestCase
@end

@implementation MMMCalcTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (NSString*)testCalcValue:(NSString *)term unit:(NSString *)unit variables:(NSDictionary<NSString *, MMMValue *> *)variables
{
    MMMValue	*mv = [MMMValue valueWithString:term variables:variables requestedUnit:unit];
    NSLog(@"### %@ [%@] => %@", term, unit, mv.error ?: mv.description);
    return mv.error ?: mv.description;
}

- (void)testArrayOperations {
    XCTAssertEqualObjects([self testCalcValue:@"sum(1,2,3,4)" unit:nil variables:nil], @"10");
    XCTAssertEqualObjects([self testCalcValue:@"avg(1,2,3,4)" unit:nil variables:nil], @"2.5");
    XCTAssertEqualObjects([self testCalcValue:@"min(1,2,0.2,3,4)" unit:nil variables:nil], @"0.2");
    XCTAssertEqualObjects([self testCalcValue:@"max(1,2,0.2,4,3)" unit:nil variables:nil], @"4");
}

- (void)testMathOperations {
    XCTAssertEqualObjects([self testCalcValue:@"unknownfunction(0)" unit:nil variables:nil], @"Function unknownfunction() not found");
    
    XCTAssertEqualObjects([self testCalcValue:@"asin(0)" unit:nil variables:nil], @"0");
    XCTAssertEqualObjects([self testCalcValue:@"acos(0)" unit:nil variables:nil], @"1.5708");
    XCTAssertEqualObjects([self testCalcValue:@"atan(0)" unit:nil variables:nil], @"0");
    XCTAssertEqualObjects([self testCalcValue:@"atan2(0,0)" unit:nil variables:nil], @"0");

    XCTAssertEqualObjects([self testCalcValue:@"sin(0)" unit:nil variables:nil], @"0");
    XCTAssertEqualObjects([self testCalcValue:@"sin(PI/2)" unit:nil variables:nil], @"1");
    XCTAssertEqualObjects([self testCalcValue:@"sin(PI)" unit:nil variables:nil], @"1.22465e-16");

    XCTAssertEqualObjects([self testCalcValue:@"cos(0)" unit:nil variables:nil], @"1");
    XCTAssertEqualObjects([self testCalcValue:@"cos(PI/2)" unit:nil variables:nil], @"6.12323e-17");
    XCTAssertEqualObjects([self testCalcValue:@"cos(PI)" unit:nil variables:nil], @"-1");
    
    XCTAssertEqualObjects([self testCalcValue:@"tan(0)" unit:nil variables:nil], @"0");
    XCTAssertEqualObjects([self testCalcValue:@"tan(PI/2)" unit:nil variables:nil], @"1.63312e+16");
    XCTAssertEqualObjects([self testCalcValue:@"tan(PI)" unit:nil variables:nil], @"-1.22465e-16");
    
    XCTAssertEqualObjects([self testCalcValue:@"sinh(0)" unit:nil variables:nil], @"0");
    XCTAssertEqualObjects([self testCalcValue:@"cosh(0)" unit:nil variables:nil], @"1");
    XCTAssertEqualObjects([self testCalcValue:@"tanh(0)" unit:nil variables:nil], @"0");
    
    XCTAssertEqualObjects([self testCalcValue:@"ln(1)" unit:nil variables:nil], @"0");
    XCTAssertEqualObjects([self testCalcValue:@"ln(constE)" unit:nil variables:nil], @"1");
    XCTAssertEqualObjects([self testCalcValue:@"log(1)" unit:nil variables:nil], @"0");
    XCTAssertEqualObjects([self testCalcValue:@"log(10)" unit:nil variables:nil], @"1");
    XCTAssertEqualObjects([self testCalcValue:@"log2(1)" unit:nil variables:nil], @"0");
    XCTAssertEqualObjects([self testCalcValue:@"log2(2)" unit:nil variables:nil], @"1");
    XCTAssertEqualObjects([self testCalcValue:@"exp(0)" unit:nil variables:nil], @"1");
    XCTAssertEqualObjects([self testCalcValue:@"exp(1)=constE" unit:nil variables:nil], @"1");

    XCTAssertEqualObjects([self testCalcValue:@"abs(-(1+1))" unit:nil variables:nil], @"2");
    XCTAssertEqualObjects([self testCalcValue:@"-((1+1))=-2" unit:nil variables:nil], @"1");
    XCTAssertEqualObjects([self testCalcValue:@"-((1+1))" unit:nil variables:nil], @"-2");
    
    XCTAssertEqualObjects([self testCalcValue:@"((123.45e-1 + sqrt(+4) -4-.69/2)*2^1/5)^2" unit:nil variables:nil], @"16");
}

- (void)testVariables {
    XCTAssertEqualObjects([self testCalcValue:@"val" unit:nil variables:@{ @"val":[MMMValue valueWithFactor:42.0 unit:@"mm"] }], @"0.042 m");
}

- (void)testUnits {
    XCTAssertEqualObjects([self testCalcValue:@"1/(8 l/100km)" unit:@"mpg" variables:nil], @"29.4018 mpg");
    XCTAssertEqualObjects([self testCalcValue:@"[1m]" unit:nil variables:nil], @"1");
    
    XCTAssertEqualObjects([self testCalcValue:@"10 knot" unit:nil variables:nil], @"5.14444 m/s");
    
    XCTAssertEqualObjects([self testCalcValue:@"1 Hz * 60" unit:nil variables:nil], @"60 1/s");
    XCTAssertEqualObjects([self testCalcValue:@"60*180'/PI" unit:nil variables:nil], @"1");
    XCTAssertEqualObjects([self testCalcValue:@"1000 \u00B5m" unit:@"mm" variables:nil], @"1 mm");		// um

    XCTAssertEqualObjects([self testCalcValue:@"1 knot" unit:@"km/h" variables:nil], @"1.852 km/h");
    
    XCTAssertEqualObjects([self testCalcValue:@"77 \u2109" unit:@"\u2103" variables:nil], [NSString stringWithUTF8String:"25 \u2103"]);	// degF => degC
    XCTAssertEqualObjects([self testCalcValue:@"25 \u2103" unit:@"\u2109" variables:nil], [NSString stringWithUTF8String:"77 \u2109"]);	// degC => degF

    XCTAssertEqualObjects([self testCalcValue:@"200 bar" unit:@"bar" variables:nil], @"200 bar");
    XCTAssertEqualObjects([self testCalcValue:@"3000 psi" unit:@"bar" variables:nil], @"206.843 bar");
    XCTAssertEqualObjects([self testCalcValue:@"1 atm" unit:@"bar" variables:nil], @"1.01325 bar");
    XCTAssertEqualObjects([self testCalcValue:@"1 Torr*760" unit:@"atm" variables:nil], @"1 atm");
    
    XCTAssertEqualObjects([self testCalcValue:@"65 C" unit:nil variables:nil], @"338.15 K");
    XCTAssertEqualObjects([self testCalcValue:@"65 F" unit:nil variables:nil], @"291.483 K");
    XCTAssertEqualObjects([self testCalcValue:@"65 K" unit:nil variables:nil], @"65 K");
    XCTAssertEqualObjects([self testCalcValue:@"68 F" unit:@"C" variables:nil], @"20 C");
    XCTAssertEqualObjects([self testCalcValue:@"20 C" unit:@"F" variables:nil], @"68 F");
    XCTAssertEqualObjects([self testCalcValue:@"0 C + 0 C" unit:@"C" variables:nil], @"273.15 C");
    
    XCTAssertEqualObjects([self testCalcValue:@"65 mph" unit:nil variables:nil], @"29.0576 m/s");
    XCTAssertEqualObjects([self testCalcValue:@"65 cm" unit:nil variables:nil], @"0.65 m");
    
    XCTAssertEqualObjects([self testCalcValue:@"20 lb" unit:@"kg" variables:nil], @"9.07185 kg");
    XCTAssertEqualObjects([self testCalcValue:@"1000 g" unit:@"kg" variables:nil], @"1 kg");
    XCTAssertEqualObjects([self testCalcValue:@"1 kg" unit:@"g" variables:nil], @"1000 g");
    
    XCTAssertEqualObjects([self testCalcValue:@"sqrt(9 m^2)" unit:nil variables:nil], @"3 m");
    XCTAssertEqualObjects([self testCalcValue:@"9 m^2" unit:nil variables:nil], @"9 m^2");
    XCTAssertEqualObjects([self testCalcValue:@"(9*m^2)^0.5" unit:nil variables:nil], @"3 m");
    
    XCTAssertEqualObjects([self testCalcValue:@"60 m + 2 s" unit:nil variables:nil], @"Term '60 m' and '2 s' can't be added");
    
    XCTAssertEqualObjects([self testCalcValue:@"60m*2m" unit:nil variables:nil], @"120 m^2");
    XCTAssertEqualObjects([self testCalcValue:@"60m*2s" unit:nil variables:nil], @"120 m*s");
    XCTAssertEqualObjects([self testCalcValue:@"60m/2m" unit:nil variables:nil], @"30");
    XCTAssertEqualObjects([self testCalcValue:@"60m/2s" unit:nil variables:nil], @"30 m/s");
    XCTAssertEqualObjects([self testCalcValue:@"60 m + 2 mm" unit:nil variables:nil], @"60.002 m");
    
    XCTAssertEqualObjects([self testCalcValue:@"(9.81 m)^0" unit:nil variables:nil], @"1");
    XCTAssertEqualObjects([self testCalcValue:@"(9.81 m)^1" unit:nil variables:nil], @"9.81 m");
    XCTAssertEqualObjects([self testCalcValue:@"(9.81 m)^2" unit:nil variables:nil], @"96.2361 m^2");
    XCTAssertEqualObjects([self testCalcValue:@"9.81 m/s^2" unit:nil variables:nil], @"9.81 m/s^2");
    
    XCTAssertEqualObjects([self testCalcValue:@"60 km/h + 12 m/s" unit:@"km/h" variables:nil], @"103.2 km/h");
    XCTAssertEqualObjects([self testCalcValue:@"12 m/s" unit:@"km/h" variables:nil], @"43.2 km/h");
    XCTAssertEqualObjects([self testCalcValue:@"43.2 km/h" unit:nil variables:nil], @"12 m/s");
}

- (void)testCustomFormula {
    XCTAssertEqualObjects([self testCalcValue:@"wwp(280 kcal, 1g, 7g)" unit:nil variables:nil], @"5");
}

@end
