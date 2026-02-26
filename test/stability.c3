import std::io;
import c3fmt::executable;

const String ROOT = "test/stdlib/src";

faultdef INVALID_PATH;

fn Path? convert_path(Path input, Allocator allocator)
{
    Path cwd = path::cwd(mem)!;
    defer cwd.free();
    String cwd_str = cwd.str_view();
    String in_str  = input.str_view();

    if (!in_str.starts_with(cwd_str)) {
        return INVALID_PATH~;
    }

    usz rel_start = cwd_str.len;
    if (in_str.len > rel_start && std::io::path::is_separator(in_str[rel_start], input.env)) {
        rel_start++;
    }

    String rel = in_str[rel_start..];

    if (!rel.starts_with(ROOT)) {
        return INVALID_PATH~;
    }

    String stripped = rel[ROOT.len..];

    DString d = dstring::new(mem);
    defer d.free();
    d.append("test/stdlib/src-formatted");
    d.append(stripped);

    return path::new(allocator, d.str_view(), input.env);
}

fn bool? process_source_file (Path path, bool is_dir, any data) {
    if(!is_dir) {
        io::printfn("%s", path);

        String input = (String)file::load(mem, path.str_view())!!;
        defer input.free(mem);
        String? formatted = c3fmt::format_string(mem, input, check_semantic: true);
        defer (void)formatted.free(mem);

        if(catch excuse = formatted) {
            io::eprintfn("Can't format %s (%s)...", path.str_view(), excuse);
			unreachable();
        } else {
			String? formatted_twice = c3fmt::format_string(mem, formatted, check_semantic: true);
			defer (void)formatted_twice.free(mem);

			if(catch excuse_twice = formatted_twice) {
				io::eprintfn("Can't format %s twice (%s)...", path.str_view(), excuse_twice);
				unreachable();
			} else {
				if(formatted_twice != formatted) {
					//io::eprintfn("%s", formatted);
					//io::eprintfn("--------------");
					//io::eprintfn("%s", formatted_twice);
					unreachable();
				}
			}
        }

        int* ptr = (int*) data;
        (*ptr)++;
    }

    return false;
}
fn void stability() @test {
    Path root = std::io::path::new(mem, ROOT)!!;
    defer root.free();

    int formatted_file_count;
    std::io::path::traverse(root, &process_source_file, &formatted_file_count)!!;
    io::printfn("Formatted %s files.", formatted_file_count);
}
