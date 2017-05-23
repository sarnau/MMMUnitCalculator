# MMMUnitCalculator

An piece of code I wrote in 2006, which allows you to do mathematical calculations with units from Objective-C. I've updated the code to Objective-C with properties and generics.

By default the result will be in SI compatible units, but all units and prefixes (like kg or ms) can be freely defined in a configuration file [units.dat](units.dat). You can also force a specific unit and add variables to the term. It is also trivial to add new functions, even functions which accept a list of values.

A few examples:
```
    [MMMValue valueWithString:@"((123.45e-1 + sqrt(+4) -4-.69/2)*2^1/5)^2" variables:nil requestedUnit:@""] => @"16"
    [MMMValue valueWithString:@"(9*m^2)^0.5" variables:nil requestedUnit:@""] => @"3 m"
    [MMMValue valueWithString:@"20 lb" variables:nil requestedUnit:@"kg"] => @"9.07185 kg"
    [MMMValue valueWithString:@"60 m + 2 mm" variables:nil requestedUnit:nil] => @"60.002 m"
    [MMMValue valueWithString:@"60 km/h + 12 m/s" variables:nil requestedUnit:@"km/h"] => @"103.2 km/h"
    [MMMValue valueWithString:@"sqrt(9 m^2)" variables:nil requestedUnit:@"km/h"] => @"3 m"
    [MMMValue valueWithString:@"1 Torr*760" variables:nil requestedUnit:@"atm"] => @"1 atm"
    [MMMValue valueWithString:@"68 F" variables:nil requestedUnit:@"km/h"] => @"20 C"
    [MMMValue valueWithString:@"0 C + 0 C" variables:nil requestedUnit:@"C"] => @"273.15 C" // internally temperatures are converted to Kelvin
    [MMMValue valueWithString:@"avg(1,2,3,4)" variables:nil requestedUnit:nil] => @"2.5"
```

The project is an Xcode project with a simple NSLog in the app delegate for testing. It also has a bunch of unit tests to make sure the math works.
