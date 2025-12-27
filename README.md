# c3fmt

A customizable code formatter for the C3 language, written in C3.

## About the parser 

I use Tree Sitter to generate a tree that is then walked down.
Would be nice to instead rely on the official C3 parser.

## Test and code coverage
The final goal is to support the whole grammar of c3. 

The test consist of a corpus of many code snippet and an expected output. For each test c3fmt will format it and compare it to the expected output.

Next, c3fmt will format the whole standard library and check that it didn't change the semantic