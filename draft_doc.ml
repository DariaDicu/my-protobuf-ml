fun parseNextField buff obj remaining = 
if (remaining > 0) then
let
	val ((tag_, code_), ParseResult(buff, keyByteCount)) = parseKey buff
	val remaining = remaining - keyByteCount
in
	if (remaining <= 0) then raise Exception(PARSE, "Not enough bytes in message to parse the message fields.")
	else case (tag_) of 0 => 
		let
			val (field_value, parse_result) = parseFuncForType buff
			val (parsed_bytes, buff)= parseResult
		in
			if (remaining > parsed_bytes)
				(ModuleName.setOrAddForLabel (obj, field_value),
				parseNextField buff obj (remaining - parsed_bytes))
			else 
				raise Exception(PARSE, 
					"Error in matching the message length with fields length.")
		end
	| 1 => 
	| n => raise Exception(PARSE, 
		"Attempting to parse field type inexistent for this message.")
end