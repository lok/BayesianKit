//
//  Utils.m
//  BayesianKit
//
//  Created by Samuel Mendes on 3/27/10.
//  Copyright 2010 Atipic. All rights reserved.
//

#import "Utils.h"

void PrintOut(NSString *format, ...)
{
    va_list args;
    
    va_start(args, format);
    NSString *string;
    
    string = [[NSString alloc] initWithFormat:format  arguments:args];
    va_end(args);
    printf("%s\n", [string UTF8String]);
    
    [string release];
} 