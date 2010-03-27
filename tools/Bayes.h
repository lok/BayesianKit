//
//  Bayes.h
//  BayesianKit
//
//  Created by Samuel Mendes on 3/27/10.
//  Copyright 2010 Atipic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BayesianKit/BayesianKit.h>

@interface Bayes : NSObject {
    NSString *filepath;
    BKBayesianClassifier *classifier;
    BOOL saveWhenExiting;
}

@property (readwrite, retain) NSString *filepath;
@property (readwrite, assign) BOOL saveWhenExiting;

- (void)processArguments:(NSArray*)arguments;
- (NSArray*)extractValuesInArray:(NSArray*)arguments fromIndex:(NSUInteger)idx;
- (void)prepareClassifier;

- (void)showVersion;
- (void)showHelp;
- (void)showInvalidNumberOfArgumentsFor:(NSString*)arg;
- (void)showDump;
- (void)terminateWell:(BOOL)well;
- (void)loadFile:(NSString*)path;
- (void)guessOn:(NSArray*)paths;
- (void)trainOn:(NSArray*)paths withPoolNamed:(NSString*)poolName;
- (void)stripToLevel:(NSUInteger)level;

@end
