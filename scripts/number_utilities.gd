extends RefCounted
class_name NumberUtilities

#FIXME: Gonna need a spreadsheet or like automatic system for this in the future
static var NOTATION_LOOK_UP: Array[Notation] = [
	Notation.new("", ""),
	Notation.new("K", "Thousand"),          # 10^3
	Notation.new("M", "Million"),           # 10^6
	Notation.new("B", "Billion"),           # 10^9
	Notation.new("T", "Trillion"),          # 10^12
	Notation.new("Qa", "Quadrillion"),       # 10^15
	Notation.new("Qi", "Quintillion"),       # 10^18
	Notation.new("Sx", "Sextillion"),        # 10^21
	Notation.new("Sp", "Septillion"),        # 10^24
	Notation.new("Oc", "Octillion"),         # 10^27
	Notation.new("No", "Nonillion"),         # 10^30
	Notation.new("Dc", "Decillion"),         # 10^33
	Notation.new("Ud", "Undecillion"),       # 10^36
	Notation.new("Dd", "Duodecillion"),      # 10^39
	Notation.new("Td", "Tredecillion"),      # 10^42
	Notation.new("Qad", "Quattuordecillion"), # 10^45
	Notation.new("Qid", "Quindecillion"),     # 10^48
	Notation.new("Sxd", "Sexdecillion"),      # 10^51
	Notation.new("Spd", "Septendecillion"),   # 10^54
	Notation.new("Ocd", "Octodecillion"),     # 10^57
	Notation.new("Nod", "Novemdecillion"),    # 10^60
	Notation.new("Vg", "Vigintillion"),      # 10^63
	Notation.new("Uvg", "Unvigintillion"),    # 10^66
	Notation.new("Dvg", "Duovigintillion"),   # 10^69
	Notation.new("Tvg", "Trevigintillion"),   # 10^72
	Notation.new("Qavg", "Quattuorvigintillion"), # 10^75
	Notation.new("Qivg", "Quinvigintillion"),     # 10^78
	Notation.new("Sxvg", "Sexvigintillion"),      # 10^81
	Notation.new("Spvg", "Septenvigintillion"),   # 10^84
	Notation.new("Ocvg", "Octovigintillion"),     # 10^87
	Notation.new("Novg", "Novemvigintillion"),    # 10^90
	Notation.new("Tg", "Trigintillion"),        # 10^93
	Notation.new("Utg", "Untrigintillion"),      # 10^96
	Notation.new("Dtg", "Duotrigintillion"),     # 10^99
]


static func format(number: float, decimals: int = 0, separator: String = ",") -> String:
	return format_string_number(str(number), decimals, separator)


#FIXME: UNOPTIMIZED AF FIX ASAP, GODOT LOOPS ARE SLOWWW
static func format_string_number(str_number: String, decimals: int = 0, separator: String = ",") -> String:
	decimals = maxi(decimals, 0)
	
	str_number = str_number.replace(",", "")
	str_number = str_number.lstrip("0")
	
	var parts: PackedStringArray = str_number.split(".")
	var integer_part: String = parts[0].lpad(1, "0")
	var decimal_part: String = parts[1] if parts.size() > 1 else ""
	var is_negative_number: bool = integer_part.begins_with("-")
	
	if is_negative_number: integer_part = integer_part.erase(0)
	
	var separated_number: String = ""
	var count: int = 0
	
	for i in integer_part.reverse():
		count += 1
		separated_number = i + separated_number
		if count % 3 == 0 and count != integer_part.length():
			separated_number = separator + separated_number
			
	
	if is_negative_number: separated_number = separated_number.insert(0, "-")
	return separated_number + "." + decimal_part.substr(0, decimals).rpad(decimals, "0") if decimals > 0 else separated_number


static func compact_format(value: float, max_digits: int = 4, abbreviate: bool = true) -> String:
	
	return compact_format_string_number(format(value, 3), max_digits, abbreviate)


static func compact_format_string_number(str_number: String, max_digits: int = 4, \
	 abbreviate: bool = true) -> String:
	
	max_digits = clampi(max_digits, 3, 6)
	
	str_number = format_string_number(str_number, 3)
	
	var parts: PackedStringArray = str_number.split(".")
	var integer_part: String = parts[0]
	var decimal_part: String = parts[1].rstrip("0") if parts.size() > 1 else ""
	var is_negative_number: bool = integer_part.begins_with("-")
	
	if is_negative_number: integer_part = integer_part.erase(0)
	
	var integer_parts: PackedStringArray = integer_part.split(",", false)
	var notation: Notation = NOTATION_LOOK_UP[integer_parts.size() - 1] if integer_parts.size() - 1 < NOTATION_LOOK_UP.size() else null
	var return_text: String = ""
	
	if not notation: return scientific_format_string_number(str_number, max_digits - 1, true, max_digits - 1)
	
	var new_integer: String = integer_parts[0]
	var new_decimal: String
	
	for part in integer_parts:
		if return_text.length() >= max_digits: break
		if part == new_integer: continue
		
		new_decimal = new_decimal + part 
	
	new_decimal = new_decimal + decimal_part
	
	return_text = new_integer + new_decimal.substr(0, 3)
	return_text = return_text.substr(0, max_digits)
	return_text = return_text.insert(new_integer.length(), ".")
	return_text = return_text.rstrip(".")
	
	return_text = "%s%s" % [return_text, notation.symbol] if abbreviate else "%s %s" % [return_text, notation.suffix]
	
	return "-" + return_text if is_negative_number else return_text
	


static func scientific_format(value: float, max_decimals: int = 3, \
	pad_decimals: bool = false, max_exponents: int = 3) -> String:
	
	return scientific_format_string_number(str(value), max_decimals, pad_decimals, max_exponents)


static func scientific_format_string_number(str_number: String, max_decimals: int = 3, \
	pad_decimals: bool = false, max_exponents: int = 3) -> String:
	
	max_decimals = maxi(max_decimals, 1)
	max_exponents = maxi(max_exponents, 1)
	str_number = format_string_number(str_number, max_decimals)
	
	var number_sign: String = "-" if str_number.begins_with("-") else ""
	if not number_sign.is_empty(): str_number = str_number.erase(0)
	
	#Remove commas and leading and trailing decimal 0s
	if str_number.contains("."): str_number = str_number.lstrip("0").rstrip("0") 
	str_number = str_number.replace(",", "")
	
	var original_decimal_index: int = str_number.find(".")
	var exponent: int = original_decimal_index - 1
	var mantissa: String = str_number.replace(".", "").insert(1, ".").substr(0, max_decimals + 2) #max_decimals + integer part and decimal
	
	mantissa = mantissa.rpad(max_decimals + 2, "0") if pad_decimals else mantissa.rstrip("0").rpad(3, "0")
	
	return number_sign + mantissa + "e" + compact_format(exponent, max_exponents)


#Really made a inner class cus wasnt getting auto complete on the dictionary lol
class Notation:
	var symbol: String
	var suffix: String
	
	func _init(_symbol: String, _suffix: String) -> void:
		symbol = _symbol
		suffix = _suffix
