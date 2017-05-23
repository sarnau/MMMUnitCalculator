//
//  MMMUnits.mm
//  UnitParser
//
//  Created by Markus Fritze on 2/7/06.
//  Copyright 2006 Markus Fritze. All rights reserved.
//

#import "MMMUnits.h"

@implementation MMMUnits
{
    NSMutableDictionary<NSString *, NSString *> *_units;
    NSMutableDictionary<NSString *, NSString *> *_prefix;
    NSMutableData *_unitCharactersetBitmap;
}

+ (instancetype)sharedUnits
{
    static dispatch_once_t once;
    static MMMUnits *_sharedUnits = nil;
    dispatch_once(&once, ^{
        _sharedUnits = [[self.class alloc] init];
    });
	return _sharedUnits;
}

- (void)parseUnit:(NSString*)theUnitString
{
	NSRange	range = [theUnitString rangeOfCharacterFromSet:NSCharacterSet.whitespaceCharacterSet];
	if(range.length == 0)
		return;

	NSString	*unitKey = [theUnitString substringWithRange:NSMakeRange(0, range.location)];
	NSString	*param = [theUnitString substringWithRange:NSMakeRange(range.location, theUnitString.length - range.location)];
	param = [param stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];

	NSUInteger	length = unitKey.length;
	for(NSUInteger i=0; i<length; ++i)
	{
		unichar	uc = [unitKey characterAtIndex:i];
		if(uc != '>' && uc != '-')	// this is a special character for formulas and prefixes
		{
			//NSLog(@"%x = %c", uc, uc);
			unsigned char	*bitmapRep = (unsigned char*)_unitCharactersetBitmap.mutableBytes;
			bitmapRep[uc >> 3] |= (((unsigned int)1) << (uc &  7));
		}
	}
    
    // All keys with a '-' suffix are prefixes (milli, nano, etc)
	if([unitKey hasSuffix:@"-"])
	{
		// remove the "-" at the end of the unit
		unitKey = [unitKey substringWithRange:NSMakeRange(0, unitKey.length - 1)];
		if(_prefix[unitKey])
		{
			NSLog(@"duplicate prefix %@",unitKey);
		} else {
			_prefix[unitKey] = param;
		}
	} else {    // otherwise it is a regular unit
		if(_units[unitKey])
		{
			NSLog(@"duplicate unit %@",unitKey);
		} else {
			_units[unitKey] = param;
		}
	}
}

- (void)parseUnitFile:(NSString*)theInputString
{
	NSRange range = NSMakeRange(0,0);
	NSUInteger start, end;
	NSUInteger contentsEnd = 0;
	NSString *lastStr = @"";
	while (contentsEnd < theInputString.length)
    {
		[theInputString getLineStart:&start end:&end contentsEnd:&contentsEnd forRange:range];
		NSString	*str = [theInputString substringWithRange:NSMakeRange(start, contentsEnd - start)];

		// remove the comment
		NSRange		commentRange = [str rangeOfString:@"#"];
		if(commentRange.length != 0)
			str = [str substringWithRange:NSMakeRange(0, commentRange.location)];

		// remove whitespace at the beginning and end
	    NSString	*strtrim = [str stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];

		// if group, we ignore it
		if([strtrim hasPrefix:@"="])
		{
			strtrim = nil;
		}

		// does the line continue?
		if([strtrim hasSuffix:@"\\"])
		{
			lastStr = [lastStr stringByAppendingString:[strtrim substringWithRange:NSMakeRange(0, strtrim.length-1)]];
			strtrim = nil;
		}

		// anything left?
		if(strtrim.length)
		{
			// do we have previous lines?
			if(lastStr.length)
			{
				strtrim = [lastStr stringByAppendingString:strtrim];
				lastStr = @"";
			}
			[self parseUnit:strtrim];
		}
		range.location = end;
		range.length = 0;
	}
}

- (NSString*)findPrefix:(NSString*)theUnit
{
	for(NSString *key in _prefix)
	{
		if([theUnit hasPrefix:key])
			return key;
	}
	return nil;
}

- (NSString*)prefixValue:(NSString*)thePrefix
{
	// resolve prefixes recursively
	while([self findPrefix:thePrefix])
		thePrefix = _prefix[thePrefix];
	return thePrefix;
}

- (NSString*)findUnit:(NSString*)theUnit withPrefix:(BOOL)thePrefix
{
	NSString	*u = _units[theUnit];
	if(u)
	{
		// if the unit is a primitive, don't go further!
		if([u isEqual:@"@"])
			return theUnit;
		return u;
	}
	if(thePrefix)
	{
		NSString *prefix = [self findPrefix:theUnit];
		if(prefix)
		{
			NSString *us = [self findUnit:[theUnit substringFromIndex:prefix.length] withPrefix:NO];
			if(us)
				return [NSString stringWithFormat:@"%@*%@", [self prefixValue:prefix], us];
		}
	}
	return nil;
}

- (NSString*)findUnit:(NSString*)theUnit
{
	return [self findUnit:theUnit withPrefix:YES];
}

- (instancetype)init
{
	if(self = [super init])
	{
		_units = [NSMutableDictionary dictionary];
		_prefix = [NSMutableDictionary dictionary];
		_unitCharactersetBitmap = [[NSMutableData alloc] initWithLength:8192];
        
        // We have to load the units somehow. In our case we store them in the bundle of the application
        NSURL    *url = [NSBundle.mainBundle URLForResource:@"units" withExtension:@"dat"];
        if(!url) return nil;
        NSError        *error;
        NSString *fileData = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if(!fileData) return nil;
        [self parseUnitFile:fileData];
		_unitCharacterset = [NSCharacterSet characterSetWithBitmapRepresentation:_unitCharactersetBitmap];
		_unitCharactersetBitmap = nil;    // we no longer need this data object
	}
	return self;
}

@end
