//
// Bayes.m
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

#import "Bayes.h"
#import "Utils.h"

#ifdef ARGUMENT_IS
#undef ARGUMENT_IS
#endif
#define ARGUMENT_IS(short, long) ([argument isEqual:short] || [argument isEqual:long])

@implementation Bayes

@synthesize filepath;
@synthesize saveWhenExiting;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    [classifier release];
    [filepath release];
    [super dealloc];
}

#pragma mark -
#pragma mark Arguments Processing
- (void)processArguments:(NSArray *)arguments
{
    //First class arguments: If found run them and then stop
    if ([arguments containsObject:@"-h"] || [arguments containsObject:@"--help"]) {
        [self showHelp]; 
        [self terminateWell:YES];
    }
    
    if ([arguments containsObject:@"-v"] || [arguments containsObject:@"--version"]) {
        [self showVersion]; 
        [self terminateWell:YES];
    }
    
    //Second class arguments: Needs to be run before the third class
    NSMutableArray *leftOver = [NSMutableArray arrayWithCapacity:[arguments count]];
    for (int i = 0; i < [arguments count]; i++) {
        NSString *argument = [arguments objectAtIndex:i];
        
        if ([argument isEqual:@"-f"] || [argument isEqual:@"--file"]) {
            [self loadFile:[arguments objectAtIndex:i+1]];
            i++;
        }
        if ([argument isEqual:@"-s"] || [argument isEqual:@"--save"]) {
            [self setSaveWhenExiting:YES];
        }
        else {
            [leftOver addObject:argument];
        }
    }
    
    [self prepareClassifier];
    
    //Third class arguments: Process in order
    for (int i = 0; i < [leftOver count]; i++) {
        NSString *argument = [leftOver objectAtIndex:i];
        
        if ([argument isEqual:@"-g"] || [argument isEqual:@"--guess"]) {
            NSArray *files = [self extractValuesInArray:leftOver fromIndex:i+1];
            if (i+1 >= [leftOver count] || [files count] == 0) 
                [self showInvalidNumberOfArgumentsFor:@"-g/--guess"];
            else
                [self guessOn:files];
            i += [files count];
        }
        else if ([argument isEqual:@"-t"] || [argument isEqual:@"--train"]) {
            NSArray *files = [self extractValuesInArray:leftOver fromIndex:i+2];
            if (i+2 >= [leftOver count] || [files count] == 0) 
                [self showInvalidNumberOfArgumentsFor:@"-t/--train"];
            else
                [self trainOn:files withPoolNamed:[leftOver objectAtIndex:i+1]];
            i += ([files count] + 1);
        }
        else if ([argument isEqual:@"-d"] || [argument isEqual:@"--dump"]) {
            [self showDump];
        }
        else if ([argument isEqual:@"-r"] || [argument isEqual:@"--strip"]) {
            if (i+1 >= [leftOver count]) [self showInvalidNumberOfArgumentsFor:@"-r/--strip"];
            [self stripToLevel:[[leftOver objectAtIndex:i+1] integerValue]];
            i += 1;
        }
    }
    
    [self terminateWell:YES];
}

- (NSArray*)extractValuesInArray:(NSArray*)arguments fromIndex:(NSUInteger)idx
{
    NSMutableArray *values = [NSMutableArray array];
    for (int i=idx; i < [arguments count]; i++) {
        NSString *value = [arguments objectAtIndex:i];
        if ([value hasPrefix:@"-"]) break;
        [values addObject:value];
    }
    return values;
}

- (void)prepareClassifier
{
    if (filepath) {
        @try {
            classifier = [[BKClassifier alloc] initWithContentsOfFile:filepath];
        }
        @catch (NSException *e) {
            PrintOut(@"%@ - Is not a valid classifier archive", filepath);
            [self terminateWell:NO];
        }
    }
    
    if (classifier == nil) {
        classifier = [[BKClassifier alloc] init];
    }
}

#pragma mark -
#pragma mark Actions
- (void)showVersion
{
    PrintOut(@"%@ - %@ %@", APPNAME, _(@"version"), VERSION);
}

- (void)showHelp
{
    PrintOut(@"Usage:\n" 
             "  bayes [-vh] [-sf] [-tgrd]\n"
             "     -h/--help               What is recursion ?\n"
             "     -v/--version            Display the actual version number.\n"
             "\n"
             "     -f/--file <path>        Save/Load classifier training to/from a file.\n"
             "     -s/--save               Save the changes in -f file before exiting.\n"
             "\n"
             "     -t/--train <cat> <path> Uses path as training data for a category.\n"
             "     -g/--guess <path>       Guess to which category path is belonging.\n"
             "     -r/--strip <level>      Remove any token with a total count lower than level.\n"
             "     -d/--dump               Print out the whole content of the classifier."
             );
}

- (void)showInvalidNumberOfArgumentsFor:(NSString*)arg
{
    PrintOut(@"Error - Invalid number of arguments for %@ option", arg);
    [self terminateWell:NO];
}

- (void)showDump
{
    [classifier printInformations];
}

- (void)terminateWell:(BOOL)well
{
    if (well) {
        if (saveWhenExiting) [classifier writeToFile:filepath];
        exit(EXIT_SUCCESS);
    } else {
        exit(EXIT_FAILURE);
    }
}

- (void)loadFile:(NSString*)path
{
    if (filepath) {
        PrintOut(_(@"Error - Only one -f or --file option can be used"));
        [self terminateWell:NO];
    }
    
    [self setFilepath:path];
}

- (void)guessOn:(NSArray*)paths
{
    for (NSString *path in paths) {
        NSDictionary *results = [classifier guessWithFile:path];
        NSString *maxKey = _(@"Nothing");
        float maxValue = -1.f;
        
        if ([results count] == 0) {
            PrintOut(@"No results, the classifier was either not trained, or you forgot to mention the -f option");
        }
        
        for (NSString *key in results) {
            float value = [[results objectForKey:key] floatValue];
            if (value > maxValue) {
                maxValue = value;
                maxKey = key;
            }
        }
        
        PrintOut(@"%@ : %@ (%02i%%)", path, maxKey, (int)(maxValue*100.f));
    }
}

- (void)trainOn:(NSArray*)paths withPoolNamed:(NSString*)poolName
{
    for (NSString *path in paths) {
        [classifier trainWithFile:path forPoolNamed:poolName];
    }
}

- (void)stripToLevel:(NSUInteger)level
{
    [classifier stripToLevel:level];
}

@end
