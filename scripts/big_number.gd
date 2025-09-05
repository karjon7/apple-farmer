extends RefCounted
class_name BigNumber

var mantissa: float = 0.0
var exponent: int = 0


func _init(x: Variant, y: int = 0) -> void:
	if x is BigNumber: 
		mantissa = x.mantissa
		exponent = x.exponent
	else:
		mantissa = x
		exponent = y
	
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


func to_short_string(decimals: int) -> String:
	var suffixes: Array[String] = ["", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"]
	
	if mantissa == 0.0:
		return "0".pad_decimals(decimals)
	
	var groups: int = int(exponent / 3)
	var remainder_exp: int = exponent % 3
	var adjusted_mantissa: float = mantissa * pow(10.0, float(remainder_exp))
	
	# Handle very small numbers with negative exponents
	if exponent < 0:
		var value: float = mantissa * pow(10.0, float(exponent))
		return str(floor(value * pow(10.0, decimals)) / pow(10.0, decimals)).pad_decimals(decimals)
	
	# Apply suffix if within range
	if groups < suffixes.size():
		var factor: float = pow(10.0, decimals)
		var floored: float = floor(adjusted_mantissa * factor) / factor
		return str(floored).pad_decimals(decimals) + suffixes[groups]
	
	# Fallback to scientific notation
	return str(mantissa) + "e" + str(exponent)


#DANGER: Does not work for numbers over max 64-bit signed value 
func to_full_string() -> String:
	var full_value: float = mantissa * pow(10.0, float(exponent))
	var str_value: String = str(full_value)
	
	# Check if it's an integer
	if full_value == floor(full_value):
		return str(int(full_value))
	else:
		# Trim trailing zeros after decimal point
		return str_value.rstrip("0").rstrip(".")
