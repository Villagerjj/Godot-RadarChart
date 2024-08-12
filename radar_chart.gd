extends Control

@export var stats : int = 10 ## the amount of different lines/stats that will be tracked
@export var names : Array[String]
@export var max_value : int = 100
@export var values : Array[int]
@export var radius : int = 200 ## the radius of the chart in pixels.

@export var border_thickness := 5.0
@export var perimeter_color := Color.DARK_GRAY
@export var perimeter_fill_color := Color.WHITE
@export var perimeter_point_color := Color.LIGHT_GRAY
@export var value_color := Color.DARK_BLUE
@export var value_fill_color := Color.BLUE
@export var value_point_color := Color.NAVY_BLUE

@onready var arrow := preload("res://assets/Arrow.png")
@onready var center = Vector2.ZERO #$Center.global_position

var label_positions : Array
var perimeter_positions : Array
var value_positions : Array
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_positions = arrange_in_circle(stats, radius + 50, center - Vector2(15,0))
	perimeter_positions = arrange_in_circle(stats, radius, center)
	value_positions = arrange_in_circle(stats, 5, center)
	names.resize(stats)

	if names[0] == "":
		for i in range(stats):
			names[i] = "stat" + str(i)
		
	values.resize(stats)
	
	for i in range(stats):
		var temp = Label.new()
		temp.text = names[i]
		temp.global_position = label_positions[i]
		temp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(temp)
	
	### calculate the positions of each value
	for i in range(stats):
		value_positions[i] = interpolate_between_points(center, perimeter_positions[i % stats], values[i % stats])


func _draw() -> void:
	draw_colored_polygon(perimeter_positions, perimeter_fill_color)
	draw_colored_polygon(value_positions, value_fill_color)
	## points:
	
	
	##lines
	for i in range(stats):
		draw_dashed_line(value_positions[i % stats], perimeter_positions[i % stats] ,perimeter_color, border_thickness/2, 5.0) #value to the perimeter
		draw_line(value_positions[i % stats], center , value_color, border_thickness/2) #from the value to the center
		draw_line(value_positions[i % stats], value_positions[i - 1 % stats] , value_color, border_thickness) #value border
		draw_line(perimeter_positions[i % stats], perimeter_positions[i - 1 % stats] ,perimeter_color, border_thickness) #perimeter border
	
	##Points
	for i in range(stats):
		draw_circle(value_positions[i % stats], 5,  value_point_color, true, 1.0) #points
		draw_circle(perimeter_positions[i % stats], 5, perimeter_point_color, true, 1.0) 
	
	draw_circle(center, 6,  value_point_color, true, 1.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#a function to get an array of n positions arranged evenly in a circle, with a given radius, around a specific center point, and with an optional angle offset
func arrange_in_circle(n: int, r: float, center=Vector2.ZERO, start_offset=0.0) -> Array:
	var output = []
	var offset = 2.0 * PI / abs(n) # could verify that n is non-zero and
	for i in range(n):
		var pos = Vector2(r, 0).rotated(i * offset + start_offset)
		output.push_front(pos + center)
	return output

func interpolate_between_points(A: Vector2, B: Vector2, percent: float) -> Vector2:
	var t = percent / 100.0  # Normalize the percentage to a value between 0 and 1
	return A + t * (B - A)
