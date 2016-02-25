use "MlGenLib.ml";

signature PHONETYPE =
sig
  type t
  val encode : t * tag -> Word8Vector.vector
  val parse : ByteBuffer.buffer -> (t * tag) * parseResult
end
structure PhoneType :> PHONETYPE = 
struct
  datatype t = MOBILE
    | HOME
    | WORK
    | UNKNOWN
  fun encode (e, tag) =
    let
      val v = case (e) of MOBILE => encodeVarint 0
      | HOME => encodeVarint 1
      | WORK => encodeVarint 2
      | UNKNOWN => encodeVarint 3
      val key = encodeKey (tag, Code(0))
    in
      Word8Vector.concat [key, v]
    end
  fun parse buff =
    let
      val ((e, tag), buff) = parseEnum buff
      val enum_val = case (e) of 0 => MOBILE
      | 1 => HOME
      | 2 => WORK
      | 3 => UNKNOWN
      | n => raise Exception(PARSE, "Attempting to parse enum of unknown tag value.")
    in
      ((enum_val, tag), buff)
    end
end
type phoneType = PhoneType.t

signature PERSON =
sig
  structure PhoneType : sig
    type t
    val encode : t * tag -> Word8Vector.vector
    val parse : ByteBuffer.buffer -> (t * tag) * parseResult
  end
  type phoneType
  structure PhoneNumber : sig
    type t
    val encode : t * tag -> Word8Vector.vector
    val parse : ByteBuffer.buffer -> (t * tag) * parseResult
    val parseNextField : ByteBuffer.buffer -> t -> int -> (t * tag) * parseResult
    val set_number: t * string option -> unit
    val set_type_: t * phoneType option -> unit
  end
  type phoneNumber
  type t
  val encode : t * tag -> Word8Vector.vector
  val parse : ByteBuffer.buffer -> (t * tag) * parseResult
  val parseNextField : ByteBuffer.buffer -> t -> int -> (t * tag) * parseResult
  val set_name: t * string option -> unit
  val set_id: t * int option -> unit
  val set_email: t * string option -> unit
  val set_phones: t * phoneNumber list -> unit
  val add_phones: t * phoneNumber -> unit
end

structure Person :> PERSON = 
struct
  structure PhoneType = 
  struct
    datatype t = MOBILE
      | HOME
      | WORK
    fun encode (e, tag) =
      let
        val v = case (e) of MOBILE => encodeVarint 0
        | HOME => encodeVarint 1
        | WORK => encodeVarint 2
        val key = encodeKey (tag, Code(0))
      in
        Word8Vector.concat [key, v]
      end
    fun parse buff =
      let
        val ((e, tag), buff) = parseEnum buff
        val enum_val = case (e) of 0 => MOBILE
        | 1 => HOME
        | 2 => WORK
        | n => raise Exception(PARSE, "Attempting to parse enum of unknown tag value.")
      in
        ((enum_val, tag), buff)
      end
  end
  type phoneType = PhoneType.t
  structure PhoneNumber = 
  struct
    type t = {
      number: string option ref,
      type_: phoneType option ref
    }
    fun set_number (msg, value) = 
    (#number msg) := value
    fun set_type_ (msg, value) = 
    (#type_ msg) := value
    fun encode (m, tag) = 
      let
        val l = [(encodeOptional encodeString) (!(#number m), Tag(1)), 
        (encodeOptional PhoneType.encode) (!(#type_ m), Tag(2))]
      in
        Word8Vector.concat l
      end
    fun parseNextField buff obj remaining = 
      if (remaining == 0) then
        (obj, ParseResult(buff, 0))
      elseif (remaining < 0) then
        raise Exception(PARSE, "Field encoding does not match length in message header")
      else
        let
          val ((Tag(t), Code(c)), parse_result) = parseKey buff
          val ParseResult(buff, ParsedByteCount(keyByteCount)) = parse_result
          val remaining = remaining - keyByteCount
        in
          if (remaining <= 0) then
            raise Exception(PARSE, "Not enough bytes in message to parse the message fields.")
          else case (t) of 1 => 
            let
              val (field_value, parse_result) = parseString buff
              val ParseResult(buff, ParsedByteCount(parsed_bytes)) = parse_result
            in
              if (remaining > parsed_bytes) then
                (set_number (obj, field_value);
                parseNextField buff obj (remaining - parsed_bytes))
              else
                raise Exception(PARSE, "Error in matching the message length with fields length.")
            end
          | 2 => 
            let
              val (field_value, parse_result) = PhoneType.parse buff
              val ParseResult(buff, ParsedByteCount(parsed_bytes)) = parse_result
            in
              if (remaining > parsed_bytes) then
                (set_type_ (obj, field_value);
                parseNextField buff obj (remaining - parsed_bytes))
              else
                raise Exception(PARSE, "Error in matching the message length with fields length.")
            end
      end
  end
  type phoneNumber = PhoneNumber.t
  type t = {
    name: string option ref,
    id: int option ref,
    email: string option ref,
    phones: phoneNumber list ref
  }
  fun set_name (msg, value) = 
  (#name msg) := value
  fun set_id (msg, value) = 
  (#id msg) := value
  fun set_email (msg, value) = 
  (#email msg) := value
  fun set_phones (msg, value) = 
  (#phones msg) := value
  fun add_phones (msg, value) = 
  (#phones msg) := value :: !(#phones msg)
  fun encode (m, tag) = 
    let
      val l = [(encodeOptional encodeString) (!(#name m), Tag(1)), 
      (encodeOptional encodeInt32) (!(#id m), Tag(2)), 
      (encodeOptional encodeString) (!(#email m), Tag(3)), 
      (encodeRepeated PhoneNumber.encode) (!(#phones m), Tag(4))]
    in
      Word8Vector.concat l
    end
  fun parseNextField buff obj remaining = 
    if (remaining == 0) then
      (obj, ParseResult(buff, 0))
    elseif (remaining < 0) then
      raise Exception(PARSE, "Field encoding does not match length in message header")
    else
      let
        val ((Tag(t), Code(c)), parse_result) = parseKey buff
        val ParseResult(buff, ParsedByteCount(keyByteCount)) = parse_result
        val remaining = remaining - keyByteCount
      in
        if (remaining <= 0) then
          raise Exception(PARSE, "Not enough bytes in message to parse the message fields.")
        else case (t) of 1 => 
          let
            val (field_value, parse_result) = parseString buff
            val ParseResult(buff, ParsedByteCount(parsed_bytes)) = parse_result
          in
            if (remaining > parsed_bytes) then
              (set_name (obj, field_value);
              parseNextField buff obj (remaining - parsed_bytes))
            else
              raise Exception(PARSE, "Error in matching the message length with fields length.")
          end
        | 2 => 
          let
            val (field_value, parse_result) = parseInt32 buff
            val ParseResult(buff, ParsedByteCount(parsed_bytes)) = parse_result
          in
            if (remaining > parsed_bytes) then
              (set_id (obj, field_value);
              parseNextField buff obj (remaining - parsed_bytes))
            else
              raise Exception(PARSE, "Error in matching the message length with fields length.")
          end
        | 3 => 
          let
            val (field_value, parse_result) = parseString buff
            val ParseResult(buff, ParsedByteCount(parsed_bytes)) = parse_result
          in
            if (remaining > parsed_bytes) then
              (set_email (obj, field_value);
              parseNextField buff obj (remaining - parsed_bytes))
            else
              raise Exception(PARSE, "Error in matching the message length with fields length.")
          end
        | 4 => 
          let
            val (field_value, parse_result) = PhoneNumber.parse buff
            val ParseResult(buff, ParsedByteCount(parsed_bytes)) = parse_result
          in
            if (remaining > parsed_bytes) then
              (add_phones (obj, field_value);
              parseNextField buff obj (remaining - parsed_bytes))
            else
              raise Exception(PARSE, "Error in matching the message length with fields length.")
          end
    end
end
type person = Person.t

signature ADDRESSBOOK =
sig
  type t
  val encode : t * tag -> Word8Vector.vector
  val parse : ByteBuffer.buffer -> (t * tag) * parseResult
  val set_people: t * person list -> unit
  val add_people: t * person -> unit
end

structure AddressBook :> ADDRESSBOOK = 
struct
  type t = {
    people: person list ref
  }
  fun set_people (msg, value) = 
  (#people msg) := value
  fun add_people (msg, value) = 
  (#people msg) := value :: !(#people msg)
  fun encode (m, tag) = 
    let
      val l = [(encodeRepeated Person.encode) (!(#people m), Tag(1))]
    in
      Word8Vector.concat l
    end
  fun parseNextField buff obj remaining = 
    if (remaining == 0) then
      (obj, ParseResult(buff, 0))
    elseif (remaining < 0) then
      raise Exception(PARSE, "Field encoding does not match length in message header")
    else
      let
        val ((Tag(t), Code(c)), parse_result) = parseKey buff
        val ParseResult(buff, ParsedByteCount(keyByteCount)) = parse_result
        val remaining = remaining - keyByteCount
      in
        if (remaining <= 0) then
          raise Exception(PARSE, "Not enough bytes in message to parse the message fields.")
        else case (t) of 1 => 
          let
            val (field_value, parse_result) = Person.parse buff
            val ParseResult(buff, ParsedByteCount(parsed_bytes)) = parse_result
          in
            if (remaining > parsed_bytes) then
              (add_people (obj, field_value);
              parseNextField buff obj (remaining - parsed_bytes))
            else
              raise Exception(PARSE, "Error in matching the message length with fields length.")
          end
    end
end
type addressBook = AddressBook.t

