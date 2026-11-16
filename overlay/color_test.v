module overlay

fn test_color_from_hex_valid() {
	cases := {
		'#89b4fa':   Color{ r: 137, g: 180, b: 250, a: 255 }
		'89b4fa':    Color{ r: 137, g: 180, b: 250, a: 255 }
		'#AbC':      Color{ r: 170, g: 187, b: 204, a: 255 }
		'aBc':       Color{ r: 170, g: 187, b: 204, a: 255 }
		'#000':      Color{ r: 0, g: 0, b: 0, a: 255 }
		'fff':       Color{ r: 255, g: 255, b: 255, a: 255 }
		'#ABCDEF':   Color{ r: 171, g: 205, b: 239, a: 255 }
		'abcdef':    Color{ r: 171, g: 205, b: 239, a: 255 }
		'#12345678': Color{ r: 18, g: 52, b: 86, a: 120 }
		'12345678':  Color{ r: 18, g: 52, b: 86, a: 120 }
		'#abcdef00': Color{ r: 171, g: 205, b: 239, a: 0 }
		'FFFFFFFF':  Color{ r: 255, g: 255, b: 255, a: 255 }
	}
	for input, expected in cases {
		actual := color_from_hex(input) or { panic(err) }
		assert actual == expected, input
	}
}

fn test_color_from_hex_invalid() {
	for input in ['', '#', '##fff', '12', '1234', '12345', '1234567', '123456789', 'ggg', '12 456',
		'0x89b4fa', '#12345g', 'ééé'] {
		if parsed := color_from_hex(input) {
			assert false, 'accepted invalid hex color ${input}: ${parsed}'
		} else {
			assert err.msg().len > 0
		}
	}
}
