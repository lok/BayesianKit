BayesianKit - Cocoa Objective-C Framework for a naive bayesian classifier
=========================================================================

BayesianKit is a Mac OS X Framework written by Samuel Mendes in Objective-C 2.0
and released under BSD 3-clauses license. BayesianKit offers a simple, ready to
use, implementation for a bayesian classifier. A command line utility is also
provided.

Dependencies
------------

* [ParseKit](http://parsekit.com) used for the default tokenizer
* [appledoc](http://www.gentlebytes.com/freeware/appledoc) used to generate the
 headers' documentation

Both of them are included as submodules. After having cloned the repository
type:

	git submodule init
	git submodule update

However appledoc needs [Doxygen](http://www.stack.nl/~dimitri/doxygen) which is
not provided.

Xcode Project
-------------

The BayesianKit project consists of 3 targets:

- **BayesianKit** : The BayesianKit framework.
- **Bayes** : The command line utility.
- **Install Documentation** : The script running appledoc.

BayesianKit usage
-----------------

The default classifier comes with a tokenizer based on ParseKit. Quite efficient
when training on source code. It also implements and use the Robinson-Fisher
combiner on probabilities. Both the tokenizer and combiner can be changed,
however note that they are not saved along the training. Hence if you load a
classifier from a file, you must reset the tokenizer and/or combiner.

### Creating and Training a new classifier ###

	BKClassifier *classifier = [[BKClassifier alloc] init];
	[classifier trainWithString:@"one two three four five"
	               forPoolNamed:@"english"];
	[classifier trainWithString:@"un deux trois quatre cinq"
	               forPoolNamed:@"french"];
  
### Saving and reloading the training data ###

	[classifier writeToFile:@"counting.bks"]
	// Another day, in a different process
	BKClassifier *anotherOne;
	anotherOne = [BKClassifier classifierWithContentsOfFile:@"counting.bks"];

### Using the classifier to make a guess ###

	NSDictionary *results = [anotherOne guessWithString:@"three platypuses"];
	NSLog(@"%@", results);

The output is:

	$ {
	  english = "0.9999";
	}
  
Bayes
-----

This tool was intended to test quickly the classifier, and works only with
files. A manpage is also provided with every details.

### Installation ###
  
From the root directory of the project:

	sudo cp build/Release/bayes /usr/local/bin/
	sudo cp docs/man/man1/bayes.1 /usr/local/share/man/man1/

### Training with a save file ###

	bayes -f save.bks -s -t english shakespeare.txt -t french moliere.txt

### Guessing based on this training ###
  
	bayes -f save.bks -g mystery.txt


LICENSE
=======

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

Samuel Mendes <samuel.mendes@gmail.com>
