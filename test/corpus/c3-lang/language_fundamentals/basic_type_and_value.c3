/* 
    From c3-lang.org 
    (https://c3-lang.org/language-fundamentals/basic-types-and-values/)
*/

// Integers
int a = -2_000;
int b = 0o770;
int c = 0x7f7f7f;

// Booleans
bool t = true; 
bool f = false;

// Character litterals
ushort twochar = 'C3';
Char32 smiley = '\u1F603';

// Arrays
int[3] abc = { 1, 2, 3 }; // Explicit int[3]
int[*] bcd = { 1, 2, 3 }; // Implicit int[3]

// Slices
int[3] abc = { 1, 2, 3 };
int[] slice = &abc;       // A slice pointing to abc with length 3

// Vectors 
int[<*>] a = { 1, 2 };

int[<2>] b = { 3, 8 };
int[<2>] c = { 7, 2 };
int[<2>] d = b * c;    // d is { 21, 16 }

int[<3>] v = { .xy = 3, .z = 100 }; // Same as { 3, 3, 100 }

// String litterals
// Note: String is a typedef inline char[]
String three_lines =
`multi
line
string`;

String foo = `C:\foo\bar.dll`;
String bar = `"Say ``hello``"`;
// Same as
String foo = "C:\\foo\\bar.dll";
String bar = "\"Say `hello`\"";

// Base64 and hex data literals
// The array below contains the characters "Hello World!"
char[*] hello_world_base64 = b64"SGVsbG8gV29ybGQh";
// The array below contains the characters "Hello World!"
char[*] hello_world_hex = x"4865 6c6c 6f20 776f 726c 6421";

// Printing values
import std::io; // Get the io functions.

fn void main()
{
    int a = 1234;
    ulong b = 0xFFAABBCCDDEEFF;
    double d = 13.03e-04;
    char[*] hex = x"4865 6c6c 6f20 776f 726c 6421";
    io::printn(a);
    io::printn(b);
    io::printn(d);
    io::printn(hex);
}

import std::io;
fn void main()
{
    int a = 1234;
    ulong b = 0xFFAABBCCDDEEFF;
    double d = 13.03e-04;
    char[*] hex = x"4865 6c6c 6f20 776f 726c 6421";
    io::printfn("a was: %d", a);
    io::printfn("b in hex was: %x", b);
    io::printfn("d in scientific notation was: %e", d);
    io::printfn("Bytes as string: %s", (String)&hex);
}

import std::io;

enum Foo
{
    ABC,
    BCD,
    EFG,
}

fn void main()
{
    int a = 1234;
    uint128 b = 0xFFEEDDCC_BBAA9988_77665544_33221100;
    Foo foo = BCD;
    io::printfn("a: %s, b: %d, foo: %s", a, b, foo);
}