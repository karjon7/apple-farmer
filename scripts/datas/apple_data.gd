extends Resource
class_name AppleData

signal quantity_updated

@export var name: String = ""
@export_multiline var description: String = ""
@export var starting_price_string: String = ""
@export var starting_effort_string: String = ""
@export var mesh: PackedScene

var quantity: BigNumber = BigNumber.new(0)
var price: BigNumber = BigNumber.new(0) : get = _get_price
var effort: BigNumber = BigNumber.new(0) : get = _get_effort


func _init() -> void:
	quantity.updated.connect(quantity_updated.emit)


func _get_price() -> BigNumber:
	price = BigNumber.new(starting_price_string)
	
	return price


func _get_effort() -> BigNumber:
	effort = BigNumber.new(starting_effort_string)
	
	return effort
