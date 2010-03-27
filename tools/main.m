//
//  mainTokenizerTest.m
//  Bayesian
//
//  Created by Samuel Mendes on 3/26/10.
//  Copyright 2010 Atipic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bayes.h"

int main(int argc, char **argv) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    NSProcessInfo *proc = [NSProcessInfo processInfo];
    Bayes *bayes = [[Bayes alloc] init];
    [bayes processArguments:[proc arguments]];
    [bayes release];
    
    [pool drain];
    return EXIT_SUCCESS;
}
