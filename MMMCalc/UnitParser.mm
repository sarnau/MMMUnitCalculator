//
//  UnitParser.mm
//  UnitParser
//
//  Created by Markus Fritze on 2/7/06.
//  Copyright 2006 Markus Fritze. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MMMCalc.h"
#import "MMMUnits.h"

static void	CalcValue(const char *term, const char *unit = nil, NSDictionary *params = nil)
{
	NSString	*ts = @(term);
	NSString	*us = unit ? @(unit) : nil;
	MMMValue	*mv = [MMMValue valueWithString:ts parameter:params wantedUnit:us];
	if([mv error])
	{
		NSLog(@"%@", [mv error]);
	} else {
		NSLog(@"%@ => %@", ts, mv);
	}
}

int			main(int argc, const char * argv[])
{
    @autoreleasepool {
        CalcValue("1/(8 l/100km)","mpg");
        CalcValue("1/(20*mpg)","l/100km");

    //	NSLog(@"%@", [[MMMUnits sharedUnits] groups]);

    }
	return 0;
}
