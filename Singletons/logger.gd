extends Node

enum LogLevel {
	DEBUG = 0,
	INFO,
	WARNING,
	ERROR,
}

var log_level := LogLevel.DEBUG


func debug(message: String) -> void:
	_log(LogLevel.DEBUG, message, "gray")


func info(message: String) -> void:
	_log(LogLevel.INFO, message, "white")


func warning(message: String) -> void:
	_log(LogLevel.WARNING, message, "yellow")


func error(message: String) -> void:
	_log(LogLevel.ERROR, message, "red")


func _log(level: LogLevel, message: String, color: String) -> void:
	if log_level > level:
		return
	var time_str := _get_time_string()
	var level_name := LogLevel.keys()[level] as String
	print_rich("[color=%s][%s] [%s] %s[/color]" % [color, time_str, level_name, message])


func _get_time_string() -> String:
	var ms := int(fposmod(Time.get_unix_time_from_system(), 1.0) * 1000.0)
	return "%s.%d" % [Time.get_time_string_from_system(), ms]
