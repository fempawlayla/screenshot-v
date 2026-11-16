/*

  ______                                    _
 / _____)                                  | |           _
( (____   ____  ____ _____ _____ ____   ___| |__   ___ _| |_
 \____ \ / ___)/ ___) ___ | ___ |  _ \ /___)  _ \ / _ (_   _)
 _____) | (___| |   | ____| ____| | | |___ | | | | |_| || |_
(______/ \____)_|   |_____)_____)_| |_(___/|_| |_|\___/  \__)
        The funny overcomplicated screenshot tool


	AFTER SLURP:

**
***
****** 		CTRL+S     saves the screenshot to ~/Pictures/Screenshots/ directory
***
**

**
***
******		CTRL+C     saves the screenshot to clipboard
***
**

*/

@[has_globals]
module main

import os
import overlay
import time

struct Screenshot {
	pos       string
	size      string
	exit_code int
}

struct GrimResult {
	file_path string
}

struct Config {
	output_dir string = os.join_path(os.home_dir(), 'Pictures', 'Screenshots')
	color      string = '#89b4fa'
}

__global config = Config{}

struct Choice {
mut:
	action Actions
}

enum Actions {
	saved
	copied
	none
}

fn slurp() Screenshot {
	slurpout := os.exec(['slurp'])
	f_slurp := slurpout.output.trim_space().split(' ')
	return Screenshot{
		pos:       f_slurp[0]
		size:      f_slurp[1]
		exit_code: slurpout.exit_code
	}
}

fn grim(pos string, size string) GrimResult {
	file := os.join_path(config.output_dir, 'Screenshot-${time.now().custom_format('YYYY-MM-DD_HH-mm-ss')}')
	os.exec(['grim', '-g', '"${pos} ${size}"', '${file}'])
	return GrimResult{
		file_path: file
	}
}

fn full_screenshot() {}

fn region_screenshot() ! {
	result := slurp()
	if result.exit_code != 0 {
		println('Operating stopped.')
		return
	}
	println('SS: ${result.pos} . ${result.size}')

	p := result.pos.split(',')
	s := result.size.split('x')

	pos := overlay.Pos{
		x: p[0].int()
		y: p[1].int()
	}
	size := overlay.Size{
		width:  s[0].int()
		height: s[1].int()
	}

	mut o := overlay.new(config.color)!
	o.box_pos = pos
	o.box_size = size

	mut choice := &Choice{}
	o.bind_input('esc', fn (mut o overlay.Overlay) {
		o.stop()
	})
	o.bind_input('ctrl+s', fn [mut choice] (mut o overlay.Overlay) {
		choice.action = Actions.saved
		o.stop()
	})
	o.bind_input('ctrl+c', fn [mut choice] (mut o overlay.Overlay) {
		choice.action = Actions.copied
		o.stop()
	})
	o.run()!
	o.close()!

	match choice.action {
		.saved {
			grim_result := grim('${o.box_pos.x},${o.box_pos.y}', '${o.box_size.width}x${o.box_size.height}')
			println('successfully saved photo to ${grim_result.file_path}')
		}
		.copied {
			os.exec(['sh', '-c',
				"grim -g '${o.box_pos.x},${o.box_pos.y} ${o.box_size.width}x${o.box_size.height}' - | wl-copy --type image/png >/dev/null 2>&1"])
			println('saved to clipboard')
		}
		else {
			println('operation stopped.')
		}
	}
}

fn main() {
	args := os.args[1..]

	for arg in args {
		match arg {
			'full' {
				full_screenshot()
			}
			'region' {
				region_screenshot()!
			}
			else {}
		}
	}
}
