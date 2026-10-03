#import "Basic";
#import "raylib";

Editor :: struct {
    lines: [..] string;
    cursor_x: int;
    cursor_y: int;
}

main :: () {
    InitWindow(1000, 700, "Jai Editor");
    SetTargetFPS(60);

    font := LoadFontEx("resources/iosevka-ttf-nerd.ttf", 32, cast(*s32)0, 250);
    
    editor: Editor;
    array_add(*editor.lines, "");

    font_size: float32 = 32;
    line_height: float32 = 40;

    text_x: float32 = 100;
    text_y: float32 = 20;

    while !WindowShouldClose() {

        pressed_char := GetCharPressed();

        while pressed_char > 0 {
            line := editor.lines[editor.cursor_y];

            builder: String_Builder;

            for i: 0..editor.cursor_x - 1 {
                append(*builder, line[i]);
            }

            append(*builder, cast(u8)pressed_char);

            for i: editor.cursor_x..line.count - 1 {
                append(*builder, line[i]);
            }

            editor.lines[editor.cursor_y] = builder_to_string(*builder);

            editor.cursor_x += 1;

            pressed_char = GetCharPressed();
        }

        if IsKeyPressed(259) {
            if editor.cursor_x > 0 {
                line := editor.lines[editor.cursor_y];

                builder: String_Builder;

                for i: 0..editor.cursor_x - 1 {
                    append(*builder, line[i]);
                }

                for i: editor.cursor_x..line.count - 1 {
                    append(*builder, line[i]);
                }

                editor.lines[editor.cursor_y] = builder_to_string(*builder);
                editor.cursor_x -= 1;
            } else if editor.cursor_y > 0 {
                previous := editor.lines[editor.cursor_y - 1];
                current := editor.lines[editor.cursor_y];

                editor.cursor_x = previous.count;

                builder: String_Builder;
                append(*builder, previous);
                append(*builder, current);

                editor.lines[editor.cursor_y - 1] = builder_to_string(*builder);

                j := editor.cursor_y;
                while j < editor.lines.count - 1 {
                    editor.lines[j] = editor.lines[j + 1];
                    j += 1;
                }

                array_resize(*editor.lines, editor.lines.count - 1);
                editor.cursor_y -= 1;
            }
        }

        if IsKeyPressed(257) {
            line := editor.lines[editor.cursor_y];

            left: String_Builder;
            right: String_Builder;

            for i: 0..editor.cursor_x - 1 {
                append(*left, line[i]);
            }

            for i: editor.cursor_x..line.count - 1 {
                append(*right, line[i]);
            }

            new_line := builder_to_string(*right);
            editor.lines[editor.cursor_y] = builder_to_string(*left);

            array_add(*editor.lines, "");

            j := editor.lines.count - 1;
            while j > editor.cursor_y + 1 {
                editor.lines[j] = editor.lines[j - 1];
                j -= 1;
            }

            editor.lines[editor.cursor_y + 1] = new_line;

            editor.cursor_y += 1;
            editor.cursor_x = 0;
        }

        if IsKeyPressed(262) {
            if editor.cursor_x < editor.lines[editor.cursor_y].count {
                editor.cursor_x += 1;
            }
        }

        if IsKeyPressed(263) {
            if editor.cursor_x > 0 {
                editor.cursor_x -= 1;
            }
        }

        if IsKeyPressed(264) {
            if editor.cursor_y < editor.lines.count - 1 {
                editor.cursor_y += 1;

                if editor.cursor_x > editor.lines[editor.cursor_y].count {
                    editor.cursor_x = editor.lines[editor.cursor_y].count;
                }
            }
        }

        if IsKeyPressed(265) {
            if editor.cursor_y > 0 {
                editor.cursor_y -= 1;

                if editor.cursor_x > editor.lines[editor.cursor_y].count {
                    editor.cursor_x = editor.lines[editor.cursor_y].count;
                }
            }
        }

        BeginDrawing();
        ClearBackground(BLACK);

        for i: 0..editor.lines.count - 1 {
            y := cast(float32)(i) * line_height + text_y;

            line_num := tprint("%", i + 1);

            DrawTextEx(
                font,
                to_c_string(line_num),
                .{20, y},
                font_size,
                0,
                GRAY
            );
        }

        for line, i: editor.lines {
            y := cast(float32)(i) * line_height + text_y;

            DrawTextEx(
                font,
                to_c_string(line),
                .{text_x, y},
                font_size,
                0,
                WHITE
            );
        }

        cursor_line := editor.lines[editor.cursor_y];

        cursor_prefix: String_Builder;

        for i: 0..editor.cursor_x - 1 {
            append(*cursor_prefix, cursor_line[i]);
        }

        prefix := builder_to_string(*cursor_prefix);

        cursor_width := MeasureTextEx(
            font,
            to_c_string(prefix),
            font_size,
            0
        );

        cursor_screen_x := text_x + cursor_width.x;
        cursor_screen_y := cast(float32)(editor.cursor_y) * line_height + text_y;

        DrawRectangle(
            cast(s32)cursor_screen_x,
            cast(s32)cursor_screen_y,
            2,
            cast(s32)font_size,
            WHITE
        );

        EndDrawing();
    }

    CloseWindow();
}
