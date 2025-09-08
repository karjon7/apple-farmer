extends RefCounted
class_name BigNumber

var mantissa: float = 0.0
var exponent: int = 0


func _init(x: Variant, y: int = 0) -> void:
	if x is BigNumber: 
		mantissa = x.mantissa
		exponent = x.exponent
	elif (x is float) or (x is int):
		mantissa = float(x)
		exponent = y
	elif x is String:
		var string: String = x
		string = string.strip_escapes().strip_edges()
		
		if string.containsn("e"): #String is in scientific notation
			if string.countn("e") != 1:
				printerr("Incorrect String passed to BigNumber")
				return 
			
			var string_mantissa: String = string.get_slice("e", 0)
			var string_exponent: String = string.get_slice("e", 1)
			
			if (not string_mantissa.is_valid_float()) or (not string_exponent.is_valid_int()):
				printerr("Incorrect String passed to BigNumber")
				return 
			
			mantissa = float(string_mantissa)
			exponent = int(string_exponent)
			
			normalize()
		else:
			if string.contains("."): string = string.rstrip("0")
			
			var negative: bool = string[0] == "-"
			if negative: string = string.substr(1)
			
			var decimal_start_pos: int = string.find(".") if string.find(".") != -1 else string.length()
			if decimal_start_pos: string = string.erase(decimal_start_pos)
			
			string = string[0] + "." + string.substr(1)
			if is_negative: string = "-" + string
			
			if not string.is_valid_float(): 
				printerr("Incorrect String passed to BigNumber")
				return
			
			mantissa = float(string)
			exponent = decimal_start_pos - 1
			
			normalize() #Based on the logic, shouldn't have to do this but might aswell to be safe
		
	else:
		printerr("Failed to create BigNumber, was given value of type %s" % type_string(typeof(x)).to_lower())
		return
	
	normalize()


func normalize() -> void:
	if mantissa == 0.0:
		exponent = 0
		return
	
	var current_sign: float = signf(mantissa)
	mantissa = absf(mantissa)
	
	while mantissa >= 10.0:
		mantissa /= 10
		exponent += 1
	
	while mantissa < 1.0:
		mantissa *= 10
		exponent -= 1
	
	mantissa *= current_sign


func print_big_number() -> void:
	printt("Mantissa: %s" % mantissa, "Exponent: %s" % exponent, "Actually: %s" % to_short_string(3))


#Operations

static func add(a: BigNumber, b: BigNumber) -> BigNumber:
	var result: BigNumber = BigNumber.new(0)
	var diff: int = a.exponent - b.exponent
	
	if diff >= 0:
		var adjusted: float = b.mantissa * pow(10.0, -diff)
		result.mantissa = a.mantissa + adjusted
		result.exponent = a.exponent
	else:
		var adjusted: float = a.mantissa * pow(10.0, diff)
		result.mantissa = b.mantissa + adjusted
		result.exponent = b.exponent
	
	result.normalize()
	return result


static func subtract(a: BigNumber, b: BigNumber) -> BigNumber:
	var negative_number_2: BigNumber = BigNumber.new(-b.mantissa, b.exponent)
	
	return add(a, negative_number_2)


static func multiply(a: BigNumber, b: BigNumber) -> BigNumber:
	var result : BigNumber = BigNumber.new(0)
	
	result.mantissa = a.mantissa * b.mantissa
	result.exponent = a.exponent + b.exponent
	result.normalize()
	return result


static func divide(a: BigNumber, b: BigNumber) -> BigNumber:
	var result : BigNumber = BigNumber.new(0)
	
	result.mantissa = a.mantissa / b.mantissa
	result.exponent = a.exponent - b.exponent
	result.normalize()
	return result


static func equals(a: BigNumber, b: BigNumber) -> bool:
	return a.exponent == b.exponent and is_equal_approx(a.mantissa, b.mantissa)


static func less_than(a: BigNumber, b: BigNumber) -> bool:
	#If exponents are the same just compare the mantissa
	if a.exponent == b.exponent: return a.mantissa < b.mantissa 
	
	return a.exponent < b.exponent


static func less_than_equal(a: BigNumber, b: BigNumber) -> bool:
	return less_than(a, b) or equals(a, b)


static func greater_than(a: BigNumber, b: BigNumber) -> bool:
	#If exponents are the same just compare the mantissa
	if a.exponent == b.exponent: return a.mantissa > b.mantissa 
	
	return a.exponent > b.exponent


static func greater_than_equal(a: BigNumber, b: BigNumber) -> bool:
	return greater_than(a, b) or equals(a, b)


func plus(other: BigNumber) -> BigNumber:
	return add(self, other)


func plus_equals(other: BigNumber) -> BigNumber:
	var result: BigNumber = add(self, other)
	
	mantissa = result.mantissa
	exponent = result.exponent
	return self


func minus(other: BigNumber) -> BigNumber:
	return subtract(self, other)


func minus_equals(other: BigNumber) -> BigNumber:
	var result: BigNumber = subtract(self, other)
	
	mantissa = result.mantissa
	exponent = result.exponent
	return self


func times(other: BigNumber) -> BigNumber:
	return multiply(self, other)


func times_equals(other: BigNumber) -> BigNumber:
	var result: BigNumber = multiply(self, other)
	
	mantissa = result.mantissa
	exponent = result.exponent
	return self


func divided_by(other: BigNumber) -> BigNumber:
	return divide(self, other)


func divided_by_equals(other: BigNumber) -> BigNumber:
	var result: BigNumber = divide(self, other)
	
	mantissa = result.mantissa
	exponent = result.exponent
	return self


func is_equal_to(other: BigNumber) -> bool:
	return equals(self, other)


func is_less_than(other: BigNumber) -> bool:
	return less_than(self, other)


func is_less_than_equal_to(other: BigNumber) -> bool:
	return less_than_equal(self, other)


func is_greater_than(other: BigNumber) -> bool:
	return greater_than(self, other)


func is_greater_than_equal_to(other: BigNumber) -> bool:
	return greater_than_equal(self, other)


func absolute() -> BigNumber:
	var result: BigNumber = BigNumber.new(self)
	
	result.mantissa = absf(result.mantissa)
	return result


func is_negative() -> bool:
	return true if signf(mantissa) == -1 else false


#String Stuff
func to_scientific_string(max_decimals: int = 3, max_exponents: int = 3) -> String:
	max_decimals = maxi(max_decimals, 0)
	max_exponents = maxi(max_exponents, 0)
	
	var mantissa_text: String = str(mantissa)
	var sign: String = "-" if mantissa_text.begins_with("-") else ""
	
	if not sign.is_empty(): mantissa_text = mantissa_text.erase(0)
	
	var integer_part: String = mantissa_text.get_slice(".", 0)
	var decimal_part: String = mantissa_text.get_slice(".", 1)
	
	mantissa_text = integer_part + "." + decimal_part.substr(0, max_decimals) \
		if max_decimals > 0 else str(floor(mantissa))
	
	return sign + mantissa_text + "e" + NumberUtilities.compact_format(exponent, max_exponents, true)


func to_short_string(max_digits: int = 4, max_decimals: int = 3, abbreviate: bool = true, fractional_decimals: bool = false) -> String:
	
	return NumberUtilities.compact_format_string_number(to_full_string(), max_digits, abbreviate)


func to_full_string(decimals: int = 3) -> String:
	decimals = maxi(decimals, 0)
	
	var mantissa_string: String = str(mantissa)
	var is_negative_number: bool = mantissa_string.begins_with("-")
	
	if is_negative_number: mantissa_string = mantissa_string.erase(0)
	mantissa_string = mantissa_string.lpad(mantissa_string.length() - exponent, "0")
	
	var decimal_start_index: int = mantissa_string.find(".") \
		if mantissa_string.contains(".") else mantissa_string.length()
	var decimal_end_index: int = decimal_start_index + exponent
	
	mantissa_string = mantissa_string.erase(decimal_start_index)
	mantissa_string = mantissa_string.rpad(decimal_end_index + decimals, "0")
	mantissa_string = mantissa_string.insert(decimal_end_index, ".")
	if is_negative_number: mantissa_string = mantissa_string.insert(0, "-")
	
	return NumberUtilities.format_string_number(mantissa_string, decimals)
