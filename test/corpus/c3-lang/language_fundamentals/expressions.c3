fn void test(int* x) { ... }

test(&&1);

// In C:
// int x = 1;
// test(&x);

struct Foo
{
    int a;
    double b;
}

fn void test1(Foo x) { }

test1((Foo){ 1, 2.0 });

fn void test2(int[3] x) { }

test2((int[3]){ 1, 2, 3 });

test1({ 1, 2.0 });
test2({ 1, 2, 3 });

fn void test(int[] y) { ... }

// Using &&
test(&&(int[3]){ 1, 2, 3 });

// Explicitly slicing:
test(((int[3]){ 1, 2, 3 })[..]);

// Using a slice directly as a temporary:
test((int[]){ 1, 2, 3 });

// Same as above but with inferred type:
test({ 1, 2, 3 });

fn void test1(int[3]* z) { ... }
fn void test2(int* z) { ... }

test1(&&(int[3]){ 1, 2, 3 });
test2(&&(int[3]){ 1, 2, 3 });

char[*] my_image = $embed("my_image.png");

char[4] my_data = $embed("foo.txt", 4);

char[]? my_image = $embed("my_image.png");

char[] my_image = $embed("my_image.png") ?? DEFAULT_IMAGE_DATA;