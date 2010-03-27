//
//  Tokenizing.h
//  Bayesian
//
//  Created by Samuel Mendes on 3/26/10.
//  Copyright 2010 Atipic. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol BKTokenizing

@property (readwrite, assign) BOOL lower;
- (NSArray*)tokenizeString:(NSString*)string;

@end
