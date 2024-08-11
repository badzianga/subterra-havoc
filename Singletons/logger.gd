# Logging singleton which enables better console outputs with timestamps and
# log levels. Note that logs don't pause or exit game - they only display
# messages with severities, enabling better readability and filtering. 

extends Node

enum LogLevel {
	DEBUG = 0,
	INFO,
	WARNING,
	ERROR,
}

const COLORS: Array[String] = ["gray", "white", "yellow", "red"]

# Logging level (e.g. debug - show all, error - show only errors).
var log_level := LogLevel.DEBUG

var _level_strings := LogLevel.keys()


func _ready() -> void:
	debug("Logger enabled with logging level: %s" % _level_strings[log_level])


# Displays lowest severity message for debugging purposes.
func debug(message: String) -> void:
	_log(LogLevel.DEBUG, message)


# Displays informational logs - little brighter than debug messages.
func info(message: String) -> void:
	_log(LogLevel.INFO, message)


# Displays warning messages for non-critical behaviors.
func warning(message: String) -> void:
	_log(LogLevel.WARNING, message)


# Displays important errors which can even be critical.
func error(message: String) -> void:
	_log(LogLevel.ERROR, message)


# Logging function used by public functions, which filters logging level and
# displays string in proper color with time, level and message.
func _log(level: LogLevel, message: String) -> void:
	if log_level > level:
		return
	var time_str := _get_time_string()
	var level_name := _level_strings[level] as String
	print_rich("[color=%s][%s] [%s] %s[/color]" % [COLORS[level], time_str, level_name, message])


# Returns time string with milliseconds.
func _get_time_string() -> String:
	var ms := int(fposmod(Time.get_unix_time_from_system(), 1.0) * 1000.0)
	return "%s.%03d" % [Time.get_time_string_from_system(), ms]
