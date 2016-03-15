use "MlGenLib.ml";

signature PHONETYPE =
sig
  type t
  val encode : t -> Word8Vector.vector
  val decode : ByteBuffer.buffer -> t * parseResult
end
structure PhoneType :> PHONETYPE = 
struct
  datatype t = MOBILE
    | HOME
    | WORK
    | UNKNOWN
  fun encode e = encodeVarint (case e of MOBILE => 0
    | HOME => 1
    | WORK => 2
    | UNKNOWN => 3
  )
  fun decode buff =
    let
      val (e, parse_result) = decodeVarint buff
      val v = case e of 0 => MOBILE
      | 1 => HOME
      | 2 => WORK
      | 3 => UNKNOWN
      | n => raise Exception(PARSE, "Attempting to parse enum of unknown tag value.")
    in
      (v, parse_result)
    end
end
type phoneType = PhoneType.t

signature PERSON =
sig
  structure PhoneType : sig
    type t
    val encode : t -> Word8Vector.vector
    val decode : ByteBuffer.buffer -> t * parseResult
  end
  type phoneType
  structure PhoneNumber : sig
    type t
    structure Builder : sig
      type t
      type parentType

      val clear_number: t -> t
      val set_number: t * string -> t

      val clear_type_: t -> t
      val set_type_: t * phoneType -> t

      val init : unit -> t

      val build : t -> parentType
    end where type parentType = t
    val encode : t -> Word8Vector.vector
    val decode : ByteBuffer.buffer -> t * parseResult
  end
  type phoneNumber
  type t
  structure Builder : sig
    type t
    type parentType

    val clear_name: t -> t
    val set_name: t * string -> t

    val clear_id: t -> t
    val set_id: t * int -> t

    val clear_email: t -> t
    val set_email: t * string -> t

    val clear_phones: t -> t
    val set_phones: t * phoneNumber list -> t
    val add_phones: t * phoneNumber -> t

    val init : unit -> t

    val build : t -> parentType
  end where type parentType = t
  val encode : t -> Word8Vector.vector
  val decode : ByteBuffer.buffer -> t * parseResult
end

structure Person :> PERSON = 
struct
  structure PhoneType = 
  struct
    datatype t = MOBILE
      | HOME
      | WORK
    fun encode e = encodeVarint (case e of MOBILE => 0
      | HOME => 1
      | WORK => 2
    )
    fun decode buff =
      let
        val (e, parse_result) = decodeVarint buff
        val v = case e of 0 => MOBILE
        | 1 => HOME
        | 2 => WORK
        | n => raise Exception(PARSE, "Attempting to parse enum of unknown tag value.")
      in
        (v, parse_result)
      end
  end
  type phoneType = PhoneType.t
  structure PhoneNumber = 
  struct
    type t = {
      number: string option,
      type_: phoneType option
    }
    structure Builder = 
    struct
      type parentType = t
      type t = {
        number: string option ref,
        type_: phoneType option ref
      }

      fun clear_number msg = 
      ((#number msg) := NONE; msg)
      fun set_number (msg, v) = 
      ((#number msg) := SOME(v); msg)

      fun clear_type_ msg = 
      ((#type_ msg) := NONE; msg)
      fun set_type_ (msg, v) = 
      ((#type_ msg) := SOME(v); msg)

      fun init () = { number = ref NONE,
        type_ = ref NONE
      }

      fun build msg = 
      let
        val numberVal = (!(#number msg))
        val type_Val = (!(#type_ msg))
      in { 
        number = numberVal,
        type_ = type_Val
      }
      end
    end
    fun encode m = 
      let
        val number = (encodeOptional encodeString) (encodeKey(Tag(1), Code(2))) (#number m)
        val type_ = (encodeOptional PhoneType.encode) (encodeKey(Tag(2), Code(0))) (#type_ m)
      in
        Word8Vector.concat [
          number,
          type_
        ]
      end
    fun decodeNextField buff obj remaining = 
      if (remaining = 0) then
        (obj, buff)
      else if (remaining < 0) then
        raise Exception(PARSE, "Field encoding does not match length in message header.")
      else
        let
          val ((Tag(t), Code(c)), parse_result) = decodeKey buff
          val ParseResult(buff, ParsedByteCount(keyByteCount)) = parse_result
          val remaining = remaining - keyByteCount
        in
          if (remaining <= 0) then
            raise Exception(PARSE, "Not enough bytes left after parsing message field key.")
          else case (t) of 1 => decodeNextHelper (decodeString) (Builder.set_number) (decodeNextField) obj buff remaining
          | 2 => decodeNextHelper (PhoneType.decode) (Builder.set_type_) (decodeNextField) obj buff remaining
          | n => raise Exception(PARSE, "Unknown field tag")
        end

    fun decode buff = decodeFullHelper decodeNextField (Builder.build) (Builder.init ()) buff

  end
  type phoneNumber = PhoneNumber.t
  type t = {
    name: string option,
    id: int option,
    email: string option,
    phones: phoneNumber list
  }
  structure Builder = 
  struct
    type parentType = t
    type t = {
      name: string option ref,
      id: int option ref,
      email: string option ref,
      phones: phoneNumber list option ref
    }

    fun clear_name msg = 
    ((#name msg) := NONE; msg)
    fun set_name (msg, v) = 
    ((#name msg) := SOME(v); msg)

    fun clear_id msg = 
    ((#id msg) := NONE; msg)
    fun set_id (msg, v) = 
    ((#id msg) := SOME(v); msg)

    fun clear_email msg = 
    ((#email msg) := NONE; msg)
    fun set_email (msg, v) = 
    ((#email msg) := SOME(v); msg)

    fun clear_phones msg = 
    ((#phones msg) := NONE; msg)
    fun set_phones (msg, v) = 
    ((#phones msg) := SOME(v); msg)
    fun add_phones (msg, v) = 
      ((case (!(#phones msg)) of NONE => (#phones msg) := SOME([v])
      | SOME(l) => (#phones msg) := SOME(v :: l)); msg)

    fun init () = { name = ref NONE,
      id = ref NONE,
      email = ref NONE,
      phones = ref NONE
    }

    fun build msg = 
    let
      val nameVal = (!(#name msg))
      val idVal = (!(#id msg))
      val emailVal = (!(#email msg))
      val phonesVal = case (!(#phones msg)) of NONE => [] | SOME(v) => v
    in { 
      name = nameVal,
      id = idVal,
      email = emailVal,
      phones = phonesVal
    }
    end
  end
  fun encode m = 
    let
      val name = (encodeOptional encodeString) (encodeKey(Tag(1), Code(2))) (#name m)
      val id = (encodeOptional encodeInt32) (encodeKey(Tag(2), Code(0))) (#id m)
      val email = (encodeOptional encodeString) (encodeKey(Tag(3), Code(2))) (#email m)
      val phones = (encodePackedRepeated PhoneNumber.encode) (encodeKey(Tag(4), Code(2))) (#phones m)
    in
      Word8Vector.concat [
        name,
        id,
        email,
        phones
      ]
    end
  fun decodeNextField buff obj remaining = 
    if (remaining = 0) then
      (obj, buff)
    else if (remaining < 0) then
      raise Exception(PARSE, "Field encoding does not match length in message header.")
    else
      let
        val ((Tag(t), Code(c)), parse_result) = decodeKey buff
        val ParseResult(buff, ParsedByteCount(keyByteCount)) = parse_result
        val remaining = remaining - keyByteCount
      in
        if (remaining <= 0) then
          raise Exception(PARSE, "Not enough bytes left after parsing message field key.")
        else case (t) of 1 => decodeNextHelper (decodeString) (Builder.set_name) (decodeNextField) obj buff remaining
        | 2 => decodeNextHelper (decodeInt32) (Builder.set_id) (decodeNextField) obj buff remaining
        | 3 => decodeNextHelper (decodeString) (Builder.set_email) (decodeNextField) obj buff remaining
        | 4 => decodeNextHelper (PhoneNumber.decode) (Builder.add_phones) (decodeNextField) obj buff remaining
        | n => raise Exception(PARSE, "Unknown field tag")
      end

  fun decode buff = decodeFullHelper decodeNextField (Builder.build) (Builder.init ()) buff

end
type person = Person.t

signature ADDRESSBOOK =
sig
  type t
  structure Builder : sig
    type t
    type parentType

    val clear_people: t -> t
    val set_people: t * person list -> t
    val add_people: t * person -> t

    val init : unit -> t

    val build : t -> parentType
  end where type parentType = t
  val encode : t -> Word8Vector.vector
  val decode : ByteBuffer.buffer -> t * parseResult
end

structure AddressBook :> ADDRESSBOOK = 
struct
  type t = {
    people: person list
  }
  structure Builder = 
  struct
    type parentType = t
    type t = {
      people: person list option ref
    }

    fun clear_people msg = 
    ((#people msg) := NONE; msg)
    fun set_people (msg, v) = 
    ((#people msg) := SOME(v); msg)
    fun add_people (msg, v) = 
      ((case (!(#people msg)) of NONE => (#people msg) := SOME([v])
      | SOME(l) => (#people msg) := SOME(v :: l)); msg)

    fun init () = { people = ref NONE
    }

    fun build msg = 
    let
      val peopleVal = case (!(#people msg)) of NONE => [] | SOME(v) => v
    in { 
      people = peopleVal
    }
    end
  end
  fun encode m = 
    let
      val people = (encodePackedRepeated Person.encode) (encodeKey(Tag(1), Code(2))) (#people m)
    in
      Word8Vector.concat [
        people
      ]
    end
  fun decodeNextField buff obj remaining = 
    if (remaining = 0) then
      (obj, buff)
    else if (remaining < 0) then
      raise Exception(PARSE, "Field encoding does not match length in message header.")
    else
      let
        val ((Tag(t), Code(c)), parse_result) = decodeKey buff
        val ParseResult(buff, ParsedByteCount(keyByteCount)) = parse_result
        val remaining = remaining - keyByteCount
      in
        if (remaining <= 0) then
          raise Exception(PARSE, "Not enough bytes left after parsing message field key.")
        else case (t) of 1 => decodeNextHelper (Person.decode) (Builder.add_people) (decodeNextField) obj buff remaining
        | n => raise Exception(PARSE, "Unknown field tag")
      end

  fun decode buff = decodeFullHelper decodeNextField (Builder.build) (Builder.init ()) buff

end
type addressBook = AddressBook.t

