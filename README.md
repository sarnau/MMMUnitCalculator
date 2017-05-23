# MMMUnitCalculator

An piece of code I wrote in 2006, which allows you to do mathematical calculations with units from Objective-C. I've updated the code to Objective-C with properties and generics.

By default the result will be in SI compatible units, but all units and prefixes (like kg or ms) can be freely defined in a configuration file [units.dat](MMMCalc/units.dat). You can also force a specific unit and add variables to the term. It is also trivial to add new functions, even functions which accept a list of values.

A few examples:
```
    ((123.45e-1 + sqrt(+4) -4-.69/2)*2^1/5)^2 => 16
    avg(1,2,3,4) => 2.5
    (9*m^2)^0.5 => 3 m
    60 m + 2 mm => 60.002 m
    sqrt(9 m^2) => 3 m
    20 lb requestedUnit: kg => 9.07185 kg
    60 km/h + 12 m/s requestedUnit: km/h => 103.2 km/h
    1 Torr*760 requestedUnit: atm => 1 atm
    68 F requestedUnit: C => 20 C
    0 C + 0 C requestedUnit: C => 273.15 C   ---  internally temperatures are converted to Kelvin
```

The project is an Xcode project with a simple NSLog in the app delegate for testing. It also has a bunch of unit tests to make sure the math works.
