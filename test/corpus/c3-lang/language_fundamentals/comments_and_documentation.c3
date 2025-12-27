#! Shebang!!!!!!!

/* 
    From c3-lang.org 
    (https://c3-lang.org/language-fundamentals/comments/)
*/

// Single line comment 

/*
    Block comment
*/


// Doc contracts
<*
 Here are some docs.
 @param num_foo `The number of foos.`
 @require num_foo > 4
 @deprecated
 @mycustom 2
*>
void bar(int num_foo)
{
    io::printfn("%d", num_foo);
}