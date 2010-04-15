//
// BKBayesianClassifier.h
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

#import <Foundation/Foundation.h>

#import <BayesianKit/BKDataPool.h>
#import <BayesianKit/BKTokenizing.h>


/** Implementation of a naive bayesian classifier.
 
 BKClassifier is provided with a default setup using Robinson-Fisher 
 probabilities combiner and a ParseKit-based tokenizer.
 
 Using methods @c initWithContentsOfFile:() and @c writeToFile:() the 
 classifier's training can be saved and reloaded. Note that if you change the 
 probabilities combiner or the tokenizer, those changes are not saved in the 
 file. You need to reapply thoses changes after reloading the classifier.
 
 To train the classifier use @c trainWithFile:forPoolNamed:() or 
 @c trainWithString:forPoolNamed:(). At the end of those methods 
 @c updatePoolsProbabilities() will be automatically called and probabilities 
 associated to each tokens will be re-computed.
 
 Once trained the classifier can be immediatly used with @c guessWithFile:() or
 @c guessWithString:(). Both returns a dictionary containing the score, in 
 percent for each pool.
 
 To avoid unecessary big pools, @c stripToLevel:() will remove any token with a 
 total count lower than specified.
 */
@interface BKClassifier : NSObject <NSCoding> {
    BKDataPool *corpus;
    
    NSMutableDictionary *pools;
    BOOL dirty;
    
    NSInvocation *probabilitiesCombinerInvocation;
    
    id<BKTokenizing> tokenizer;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties
//////////////////////////////////////////////////////////////////////////////////////////

/** Dictionary containing every data pools of the classifier */
@property (readonly) NSMutableDictionary *pools;

/** Invocation to call for combining probabilities.
 
 As an alternative you can use @c setProbabilitiesCombinerWithTarget:selector:userInfo:().
 
 By default it uses @c robinsonFisherCombinerOn:userInfo:.
 */
@property (readwrite, retain) NSInvocation *probabilitiesCombinerInvocation;

/** Tokenizer to use on string training or guessing.
 
 By default it uses @c BKTokenizer
 */
@property (readwrite, retain) id<BKTokenizing> tokenizer;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creating a classifier
//////////////////////////////////////////////////////////////////////////////////////////

/** Create a new classifier using a previous training saved in a file.
 
 @param path The path to the file containing the classifier's save.
 @returns A new bayesian classifier.
 @see initWithContentsOfFile:
 */
- (BKClassifier*)classifierWithContentsOfFile:(NSString*)path;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Initializing a classifier
//////////////////////////////////////////////////////////////////////////////////////////

/** Initialize a bayesian classifier using a previous training saved in a file.
  
 @param path The path to the file containing the classifier's save.
 @returns A bayesian classifier initialized.
 @see classifierWithContentsOfFile:
 */
- (id)initWithContentsOfFile:(NSString*)path;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Storing a classifier's training
//////////////////////////////////////////////////////////////////////////////////////////

/** Saves all training data in a file.
 
 If path contains a tilde (~) character, you must expand it before invoking this method.
 @param path The path at which to write the file.
 @return YES if the file is written successfully, otherwise NO.
 */
- (BOOL)writeToFile:(NSString*)path;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creating & Destroying pools
//////////////////////////////////////////////////////////////////////////////////////////

/** Returns the pool with a given name.
 
 If the classifier do not hold a pool with this name, a new one is created.
 @param poolName The name of the pool to look for.
 @return The pool associated to the name.
 */
- (BKDataPool*)poolNamed:(NSString*)poolName;

/** Destroy a pool with a given name.
 
 @param poolName The name of the pool.
 */
- (void)removePoolNamed:(NSString*)poolName;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Updating probabilities
//////////////////////////////////////////////////////////////////////////////////////////

/** Compute the probability associated with every tokens in every pools. */
- (void)updatePoolsProbabilities;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Probabilities combining
//////////////////////////////////////////////////////////////////////////////////////////

/** Change the probabilities combiner.
 
 @param target The object to which to send the message specified by selector when 
 the classifier needs to combine a series of probabilities.
 The target object is @b not retained by the classifier.
 @param selector The selector to send to the target when the classifier needs to
 combine a series of probabilities. The selector must have the same signature than 
 @c robinsonCombinerOn:userInfo:(). The classifier passes an array 
 of @c NSNumber containing float values in @a probabilities.
 @param userInfo Custom user info for the combiner. 
 The object you specify is @b not retained by the classifier. 
 This parameter may be nil.
 @see robinsonCombinerOn:userInfo:
 @see robinsonFisherCombinerOn:userInfo:
 */
- (void)setProbabilitiesCombinerWithTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo;

/** Compute Robinson's combiner on a series of probabilities.
 
 @param probabilities An array of @c NSNumber containing float numbers.
 @param userInfo Custom user info for the combiner. Unused in this method.
 @return A single probability representing the serie.
 @see robinsonFisherCombinerOn:userInfo:
 */
- (float)robinsonCombinerOn:(NSArray*)probabilities userInfo:(id)userInfo;

/** Compute Robinson-Fisher's combiner on a series of probabilities.
 
 @param probabilities An array of @c NSNumber containing float numbers.
 @param userInfo Custom user info for the combiner. Unused in this method.
 @return A single probability representing the serie.
 @see robinsonCombinerOn:userInfo:
 */
- (float)robinsonFisherCombinerOn:(NSArray*)probabilities userInfo:(id)userInfo;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Training a classifier
//////////////////////////////////////////////////////////////////////////////////////////

/** Train the classifier on a file.
 
 @param path The path to the file on which the classifier will train.
 @param poolName The name of the pool to which the content of the file belongs.
 @see trainWithString:forPoolNamed:
 @see trainWithTokens:forPoolNamed:
 */
- (void)trainWithFile:(NSString*)path forPoolNamed:(NSString*)poolName;

/** Train the classifier on a string.
 
 @param trainString The string on which the classifier will train.
 @param poolName The name of the pool to which the content of the file belongs.
 @see trainWithFile:forPoolNamed:
 @see trainWithTokens:forPoolNamed:
 */
- (void)trainWithString:(NSString*)trainString forPoolNamed:(NSString*)poolName;

/** Train the classifier on a group of tokens.
 
 @param tokens Tokens to add to one of the classifier's pool.
 @param poolName The name of the pool where the tokens belongs.
 @see trainWithFile:forPoolNamed:
 @see trainWithString:forPoolNamed:
 */
- (void)trainWithTokens:(NSArray*)tokens inPool:(BKDataPool*)pool;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Guessing with the classifier
//////////////////////////////////////////////////////////////////////////////////////////

/** Ask the classifier to guess on a file.
 
 @param path The path to the file on which the classifier will make a guess.
 @return A dictionary with every pools' names as keys and theirs probability to 
 be associated with the file's content.
 @see guessWithString:
 @see guessWithTokens:
 */
- (NSDictionary*)guessWithFile:(NSString*)path;

/** Ask the classifier to guess on a string.
 
 @param string The string on which the classifier will make a guess.
 @return A dictionary with every pools' names as keys and theirs probability to 
 be associated with the string.
 @see guessWithFile:
 @see guessWithTokens:
 */
- (NSDictionary*)guessWithString:(NSString*)string;

/** Ask the classifier to guess on a group of tokens.
 
 @param tokens Tokens on which the classifier will make a guess.
 @return A dictionary with every pools' names as keys and theirs probability to 
 be associated with those tokens.
 @see guessWithFile:
 @see guessWithString:
 */
- (NSDictionary*)guessWithTokens:(NSArray*)tokens;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Optimizing the classifier
//////////////////////////////////////////////////////////////////////////////////////////

/** Remove any tokens with a total count lower than a given level.
 
 @param level The minimum amount a tokens needs not to get removed.
 */
- (void)stripToLevel:(NSUInteger)level;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Getting informations
//////////////////////////////////////////////////////////////////////////////////////////

/** Print some basics statistics on the pools */
- (void)printInformations;

@end


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Constants
//////////////////////////////////////////////////////////////////////////////////////////

/** Pool name for the corpus' pool */
extern NSString* const BKCorpusDataPoolName;
