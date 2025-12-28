import std::io;
import c3fmt::executable;

const String ROOT = "test/stdlib/";

faultdef INVALID_PATH;

fn Path? convert_path(Path input, Allocator allocator)
{
    // 1. Get cwd (fixed root)
    Path cwd = path::cwd(tmem)!;
    String cwd_str = cwd.str_view();
    String in_str  = input.str_view();

    // 2. Must be under cwd
    if (!in_str.starts_with(cwd_str)) {
        return INVALID_PATH?;
    }

    // 3. Make path relative to cwd
    usz rel_start = cwd_str.len;
    if (in_str.len > rel_start && std::io::path::is_separator(in_str[rel_start], input.env)) {
        rel_start++;
    }

    String rel = in_str[rel_start..];

    // 4. Must be under test/stdlib
    if (!rel.starts_with(ROOT)) {
        return INVALID_PATH?;
    }

    // 5. Strip test/stdlib
    String stripped = rel[ROOT.len..];

    // 6. Prepend formatted-stdlib
    @pool()
    {
        DString d = dstring::temp_with_capacity(
            "formatted-stdlib/".len + stripped.len
        );
        d.append("test/formatted-stdlib/");
        d.append(stripped);

        return path::new(allocator, d.str_view(), input.env);
    };
}


fn bool? process_source_file (Path path, bool is_dir, any data) {
    if(!is_dir) {
        String input = c3fmt::executable::read_file(path.str_view())!!;
        defer input.free(mem);
        String? formatted = c3fmt::format_string(mem, input);
        defer (void)formatted.free(mem);

        if(catch excuse = formatted) {
            io::eprintfn("Source file %s can't be parsed...", path.str_view());
            return false;
        }

        Path target_path = convert_path(path, mem)!!;
        defer target_path.free();

        std::io::path::mkdir(target_path.parent()!!, true)!!;
        std::io::file::save(target_path.str_view(), formatted)!!;

        int* ptr = (int*) data;
        (*ptr)++;
    }

    return false;
}
fn void format_and_compile_std_lib() @test {
    Path root = std::io::path::new(mem, ROOT)!!;
    defer root.free();

    int formatted_file_count;
    std::io::path::traverse(root, &process_source_file, &formatted_file_count)!!;
    io::printfn("Formatted %s files.", formatted_file_count);

    assert(false);
}