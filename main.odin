package search

import       "core:os"
import       "core:fmt"
import       "core:strings"
import ray   "vendor:raylib"
import linux "core:sys/linux"
import       "core:unicode/utf8"

MAX_SIZE      :: 128
SCREEN_WIDTH  :: 480
SCREEN_HEIGHT :: 240

Textbox := struct {
	count     : int,
	edit_mode : bool,
	buffer    : [MAX_SIZE]u8,
	input     : strings.Builder,
} {
	edit_mode = false,
}

input :: proc() -> cstring {
	for Textbox.count < len(Textbox.buffer) {
		char := ray.GetCharPressed()

		if char == 0 do break

		byte, width   := utf8.encode_rune(char)
		Textbox.count += copy(Textbox.buffer[Textbox.count:] , byte[:width])
	}

	strings.write_string(&Textbox.input , string(Textbox.buffer[:Textbox.count]))

	return strings.to_cstring(&Textbox.input)	
}

main :: proc() {
	ray.InitWindow(SCREEN_WIDTH , SCREEN_HEIGHT , "Search")
	defer ray.CloseWindow()

	ray.SetTargetFPS(60)

	text : cstring = input()

	for !ray.WindowShouldClose() {
		ray.BeginDrawing()
		defer ray.EndDrawing()

		ray.ClearBackground(ray.RAYWHITE)

		ray.GuiLabel(ray.Rectangle{140,50,50,30} , "Name: ")
		ray.GuiLabel(ray.Rectangle{140,70,200,30} , "Example: Richard Nixon -> N_Richard")

		if ray.GuiTextBox(ray.Rectangle{140,95,200,50} , text , MAX_SIZE , Textbox.edit_mode) {
			Textbox.edit_mode = true

			if ray.IsKeyPressed(ray.KeyboardKey.ENTER) {
				command_exec : string = "nix-shell"
				// command_args : []string = {"-p" , "nixVersions.latest" , "--run" , "'nixos-rebuild" , "boot" , "--flake" , "github:Vonixxx/Vontoo#V_SteamDeck'"}
				command_args : []string = {"-p" , "--extra-experimental-features" , "flakes" , "nixVersions.latest" , "--run" , "nixos-rebuild" , "boot" , "--flake"}

				os.execvp(command_exec , command_args)
			}
		}
	}
}
