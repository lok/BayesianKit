//
// BKTokenizer.m
// Licensed under the terms of the BSD License, as specified below.
//

/*
 Copyright (c) 2010, Samuel Mendes
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 * Neither the name of ᐱ nor the names of its
 contributors may be used to endorse or promote products derived
 from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <BayesianKit/BKTokenizer.h>


@implementation BKTokenizer

@synthesize lowerCaseTokens;

- (id)init
{
    self = [super init];
    if (self) {
        lowerCaseTokens = YES;
    }
    return self;
}

- (NSArray*)tokenizeString:(NSString *)string
{
    PKTokenizer *tokenizer = [PKTokenizer tokenizerWithString:string];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *token = nil;
    NSMutableSet *tokens = [NSMutableSet set];
    
    while ((token = [tokenizer nextToken]) != eof) {
        if ([token tokenType] == PKTokenTypeWord || [token tokenType] == PKTokenTypeSymbol) {
            NSString *tokenString = [token stringValue];
            if (lowerCaseTokens) {
                tokenString = [tokenString lowercaseString];
            }
            [tokens addObject:tokenString];
        }
    }
    
    return [tokens allObjects];
}

@end
