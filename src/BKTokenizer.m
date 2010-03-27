//
//  Tokenizer.m
//  Bayesian
//
//  Created by Samuel Mendes on 3/26/10.
//  Copyright 2010 Atipic. All rights reserved.
//

#import <BayesianKit/BKTokenizer.h>


@implementation BKTokenizer

@synthesize lower;

- (NSArray*)tokenizeString:(NSString *)string
{
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@" \n;,()[]{}"];
    return [string componentsSeparatedByCharactersInSet:set];
}

@end
