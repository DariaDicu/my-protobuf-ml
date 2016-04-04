use "MlGenLib.ml";

signature PHONETYPE =
sig
  datatype t = MOBILE
    | HOME
    | WORK
    | UNKNOWN

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
    datatype t = MOBILE
      | HOME
      | WORK

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
      val set_type_: t * PhoneType.t -> t

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
    val set_id: t * bool -> t

    val clear_email: t -> t
    val set_email: t * string -> t

    val clear_phones: t -> t
    val set_phones: t * PhoneNumber.t list -> t
    val merge_phones: t * PhoneNumber.t list -> t
    val add_phones: t * PhoneNumber.t -> t

    val clear_cnp: t -> t
    val set_cnp: t * int list -> t
    val merge_cnp: t * int list -> t
    val add_cnp: t * int -> t

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
      fun set_number (msg, l) = 
      ((#number msg) := SOME(l); msg)

      fun clear_type_ msg = 
      ((#type_ msg) := NONE; msg)
      fun set_type_ (msg, l) = 
      ((#type_ msg) := SOME(l); msg)

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
          else case (t) of 1 => decodeNextUnpacked (decodeString) (Builder.set_number) (decodeNextField) obj buff remaining
          | 2 => decodeNextUnpacked (PhoneType.decode) (Builder.set_type_) (decodeNextField) obj buff remaining
          | n => raise Exception(PARSE, "Unknown field tag")
        end

    fun decode buff = decodeFullHelper decodeNextField (Builder.build) (Builder.init ()) buff

  end
  type phoneNumber = PhoneNumber.t
  type t = {
    name: string option,
    id: bool option,
    email: string option,
    phones: phoneNumber list,
    cnp: int list
  }
  structure Builder = 
  struct
    type parentType = t
    type t = {
      name: string option ref,
      id: bool option ref,
      email: string option ref,
      phones: phoneNumber list option ref,
      cnp: int list option ref
    }

    fun clear_name msg = 
    ((#name msg) := NONE; msg)
    fun set_name (msg, l) = 
    ((#name msg) := SOME(l); msg)

    fun clear_id msg = 
    ((#id msg) := NONE; msg)
    fun set_id (msg, l) = 
    ((#id msg) := SOME(l); msg)

    fun clear_email msg = 
    ((#email msg) := NONE; msg)
    fun set_email (msg, l) = 
    ((#email msg) := SOME(l); msg)

    fun clear_phones msg = 
    ((#phones msg) := NONE; msg)
    fun set_phones (msg, l) = 
    ((#phones msg) := SOME(l); msg)
    fun add_phones (msg, v) = 
      ((case (!(#phones msg)) of NONE => (#phones msg) := SOME([v])
      | SOME(l) => (#phones msg) := SOME(v :: l)); msg)
    fun merge_phones (msg, l) = 
      ((case (!(#phones msg)) of NONE => (#phones msg) := SOME(l)
      | SOME(ll) => (#phones msg) := SOME(List.concat [ll, l])); msg)

    fun clear_cnp msg = 
    ((#cnp msg) := NONE; msg)
    fun set_cnp (msg, l) = 
    ((#cnp msg) := SOME(l); msg)
    fun add_cnp (msg, v) = 
      ((case (!(#cnp msg)) of NONE => (#cnp msg) := SOME([v])
      | SOME(l) => (#cnp msg) := SOME(v :: l)); msg)
    fun merge_cnp (msg, l) = 
      ((case (!(#cnp msg)) of NONE => (#cnp msg) := SOME(l)
      | SOME(ll) => (#cnp msg) := SOME(List.concat [ll, l])); msg)

    fun init () = { name = ref NONE,
      id = ref NONE,
      email = ref NONE,
      phones = ref NONE,
      cnp = ref NONE
    }

    fun build msg = 
    let
      val nameVal = (!(#name msg))
      val idVal = (!(#id msg))
      val emailVal = (!(#email msg))
      val phonesVal = case (!(#phones msg)) of NONE => [] | SOME(v) => v
      val cnpVal = case (!(#cnp msg)) of NONE => [] | SOME(v) => v
    in { 
      name = nameVal,
      id = idVal,
      email = emailVal,
      phones = phonesVal,
      cnp = cnpVal
    }
    end
  end
  fun encode m = 
    let
      val name = (encodeOptional encodeString) (encodeKey(Tag(1), Code(2))) (#name m)
      val id = (encodeOptional encodeBool) (encodeKey(Tag(2), Code(0))) (#id m)
      val email = (encodeOptional encodeString) (encodeKey(Tag(3), Code(2))) (#email m)
      val phones = (encodeRepeated PhoneNumber.encode) (encodeKey(Tag(4), Code(2))) (#phones m)
      val cnp = (encodePackedRepeated encodeInt32) (encodeKey(Tag(5), Code(2))) (#cnp m)
    in
      Word8Vector.concat [
        name,
        id,
        email,
        phones,
        cnp
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
        else case (t) of 1 => decodeNextUnpacked (decodeString) (Builder.set_name) (decodeNextField) obj buff remaining
        | 2 => decodeNextUnpacked (decodeBool) (Builder.set_id) (decodeNextField) obj buff remaining
        | 3 => decodeNextUnpacked (decodeString) (Builder.set_email) (decodeNextField) obj buff remaining
        | 4 => decodeNextUnpacked (PhoneNumber.decode) (Builder.add_phones) (decodeNextField) obj buff remaining
        | 5 => if (c = 2) then (decodeNextPacked (decodeInt32) (Builder.add_cnp) (decodeNextField) obj buff remaining)
        else (decodeNextUnpacked (decodeInt32) (Builder.add_cnp) (decodeNextField) obj buff remaining)

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
    val set_people: t * Person.t list -> t
    val merge_people: t * Person.t list -> t
    val add_people: t * Person.t -> t

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
    fun set_people (msg, l) = 
    ((#people msg) := SOME(l); msg)
    fun add_people (msg, v) = 
      ((case (!(#people msg)) of NONE => (#people msg) := SOME([v])
      | SOME(l) => (#people msg) := SOME(v :: l)); msg)
    fun merge_people (msg, l) = 
      ((case (!(#people msg)) of NONE => (#people msg) := SOME(l)
      | SOME(ll) => (#people msg) := SOME(List.concat [ll, l])); msg)

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
      val people = (encodeRepeated Person.encode) (encodeKey(Tag(1), Code(2))) (#people m)
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
        else case (t) of 1 => decodeNextUnpacked (Person.decode) (Builder.add_people) (decodeNextField) obj buff remaining
        | n => raise Exception(PARSE, "Unknown field tag")
      end

  fun decode buff = decodeFullHelper decodeNextField (Builder.build) (Builder.init ()) buff

end
type addressBook = AddressBook.t

