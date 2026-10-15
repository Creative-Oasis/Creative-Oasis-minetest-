API
===

Inspection tools
----------------

Inspect tool will send chat message to player who use it.

Aviable in node/entity definition:

1.	_inspect_msg - _inspect_msg is used as message
2.	_inspect_msg_func - fucntion return value is used as message
3. 	nothing above - description field is used as message


### Hand Glass
	
Inspection level 2.

### Hand Computer
	
Inspection interval 5s.
Inspection level 2.

### Hand Laser
	
Inspection interval 15s.
Inspection level 3.

Node/entity definition field
----------------------------

### _inspect_msg = "Message to show"
  
String to be used as message.

### _inspect_msg_func = function(data, level)	

	data - clicked positon or ItemStack objector lua entity data
	level = inspection tool level

Functon return value is used as message.

