package search

import     "core:c"
import     "core:os"
import str "core:strings"
import ray "vendor:raylib"
import     "core:unicode/utf8"

SCREEN_WIDTH  :: 480
SCREEN_HEIGHT :: 240

Position := struct {
	x: f32,
	y: f32,
} {
	x = 0,
	y = 0,
}

Size := struct {
	w: f32,
	h: f32,
} {
	w = 0,
	h = 0,
}

Command := struct {
	exec    : string,
	profile : string,
	args    : []string,
} {
	exec    = "nixos-rebuild",
}

Textbox := struct {
	count         : int,
	edit_mode     : bool,
	buffer_size   : c.int,
	input_text    : cstring,
	buffer        : [64]u8,
	input_builder : str.Builder,
} {
	buffer_size = 64,
	edit_mode   = true,
}

input :: proc() -> cstring {
	for Textbox.count < len(Textbox.buffer) {
		char := ray.GetCharPressed()

		if char == 0 do break

		byte, width   := utf8.encode_rune(char)
		Textbox.count += copy(Textbox.buffer[Textbox.count:] , byte[:width])
	}

	str.write_string(&Textbox.input_builder , string(Textbox.buffer[:Textbox.count]))

	return str.to_cstring(&Textbox.input_builder)	
}

main :: proc() {
	ray.InitWindow(SCREEN_WIDTH , SCREEN_HEIGHT , "Search")
	defer ray.CloseWindow()

	ray.SetTargetFPS(60)

	ray.GuiLoadStyle("mocha.rgs")

	ray.ClearBackground(ray.Color{17, 17, 27,255})

	Textbox.input_text = input()

	for !ray.WindowShouldClose() {
		ray.BeginDrawing()
		defer ray.EndDrawing()

		Size.h = 20
		Size.w = 30

		Position.y = 50
		Position.x = (SCREEN_WIDTH - Size.w) / 2

		ray.GuiLabel(ray.Rectangle{Position.x,Position.y,Size.w,Size.h} , "Name:")

		Size.h = 20
		Size.w = 181

		Position.y = 70
		Position.x = (SCREEN_WIDTH - Size.w) / 2

		ray.GuiLabel(ray.Rectangle{Position.x,Position.y,Size.w,Size.h} , "Example: Richard Nixon -> N_Richard")

		Size.h = 25
		Size.w = 200

		Position.y = 90
		Position.x = (SCREEN_WIDTH - Size.w) / 2

		if ray.GuiTextBox(ray.Rectangle{Position.x,Position.y,Size.w,Size.h} , Textbox.input_text , Textbox.buffer_size , Textbox.edit_mode) {
			Textbox.edit_mode = true
			Command.profile   = str.concatenate([]string{"github:Vonixxx/Vontoo#",string(Textbox.input_text)})
			Command.args      = {"boot" , "--flake" , Command.profile}

			if ray.IsKeyPressed(ray.KeyboardKey.ENTER) {
				os.execvp(Command.exec , Command.args)
			}
		}
	}
}
