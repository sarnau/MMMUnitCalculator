//
//  AppDelegate.m
//  MMMCalc
//
//  Created by Markus Fritze on 23.05.17.
//  Copyright © 2017 Markus Fritze. All rights reserved.
//

#import "AppDelegate.h"

#import "MMMValue.h"
#import "MMMUnits.h"

static void	CalcValue(NSString *term, NSString *unit, NSDictionary<NSString *, MMMValue *> *variables)
{
    MMMValue	*mv = [MMMValue valueWithString:term variables:variables requestedUnit:unit];
    if(mv.error)
    {
        NSLog(@"%@", mv.error);
    } else {
        NSLog(@"%@ => %@", term, mv.description);
    }
}


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    CalcValue(@"1/(8 l/100km)",@"mpg", nil);
    CalcValue(@"1/(20*mpg)",@"l/100km", nil);
    
    [NSApp terminate:self];
}

@end
