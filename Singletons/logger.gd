extends Node

enum LogLevel {
	DEBUG = 0,
	INFO,
	WARNING,
	ERROR,
}


func debug(message: String) -> void:
	_log(LogLevel.DEBUG, message)


func info(message: String) -> void:
	_log(LogLevel.INFO, message)


func warning(message: String) -> void:
	_log(LogLevel.WARNING, message)


func error(message: String) -> void:
	_log(LogLevel.ERROR, message)


func _log(level: LogLevel, message: String) -> void:
	var time_str := _get_time_string()
	var level_name := LogLevel.keys()[level] as String
	print("[%s] [%s] %s" % [time_str, level_name, message])


func _get_time_string() -> String:
	var ms := int(fposmod(Time.get_unix_time_from_system(), 1.0) * 1000.0)
	return Time.get_time_string_from_system() + '.' + str(ms)
