use "MlGenLib.ml";

signature PERSON =
sig
  structure PhoneType : sig
    datatype t = MOBILE
      | HOME
      | WORK

    val encode : t -> Word8Vector.vector

    val decode : ByteInputStream.stream -> t * parseResult

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
    val encodeToplevel : t -> Word8Vector.vector
    val decode : ByteInputStream.stream -> t * parseResult
    val decodeToplevel : ByteInputStream.stream -> t * parseResult
  end
  type phoneNumber
  type t
  structure Builder : sig
    type t
    type parentType

    val clear_name: t -> t
    val set_name: t * string -> t

    val clear_id: t -> t
    val set_id: t * real -> t

    val clear_email: t -> t
    val set_email: t * string -> t

    val clear_phone: t -> t
    val set_phone: t * PhoneNumber.t list -> t
    val merge_phone: t * PhoneNumber.t list -> t
    val add_phone: t * PhoneNumber.t -> t

    val init : unit -> t

    val build : t -> parentType
  end where type parentType = t
  val encode : t -> Word8Vector.vector
  val encodeToplevel : t -> Word8Vector.vector
  val decode : ByteInputStream.stream -> t * parseResult
  val decodeToplevel : ByteInputStream.stream -> t * parseResult
end

structure Person : PERSON = 
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
        | n => raise Exception(DECODE, "Attempting to parse enum of unknown tag value.")
      in
        (v, parse_result)
      end
  end
  type phoneType = PhoneType.t
  structure PhoneNumber = 
  struct
    type t = {
      number: string ,
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
        val numberVal = case (!(#number msg)) of NONE => raise Exception(BUILD, "Required field missing.") | SOME(v) => v
        val type_Val = (!(#type_ msg))
      in { 
        number = numberVal,
        type_ = type_Val
      }
      end
    end
    fun encodeToplevel m = 
      let
        val number = (encodeRequired encodeString) (encodeKey(Tag(1), Code(2))) (#number m)
        val type_ = (encodeOptional PhoneType.encode) (encodeKey(Tag(2), Code(0))) (#type_ m)
      in
        Word8Vector.concat [
          number,
          type_
        ]
      end

    fun encode m = encodeMessage (encodeToplevel m)

    fun decodeNextField buff obj remaining = 
      if (remaining = 0) then
        (obj, buff)
      else if (remaining < 0) then
        raise Exception(DECODE, "Field encoding does not match length in message header.")
      else
        let
          val ((Tag(t), Code(c)), parse_result) = decodeKey buff
          val ParseResult(buff, ParsedByteCount(keyByteCount)) = parse_result
          val remaining = remaining - keyByteCount
        in
          if (remaining <= 0) then
            raise Exception(DECODE, "Not enough bytes left after parsing message field key.")
          else case (t) of 1 => decodeNextUnpacked (decodeString) (Builder.set_number) (decodeNextField) obj buff remaining
          | 2 => decodeNextUnpacked (PhoneType.decode) (Builder.set_type_) (decodeNextField) obj buff remaining
          | n => raise Exception(DECODE, "Unknown field tag")
        end

    fun decode buff = decodeFullHelper false decodeNextField (Builder.build) (Builder.init ()) buff

    fun decodeToplevel buff = decodeFullHelper true decodeNextField (Builder.build) (Builder.init ()) buff

  end
  type phoneNumber = PhoneNumber.t
  type t = {
    name: string ,
    id: real ,
    email: string option,
    phone: phoneNumber list
  }
  structure Builder = 
  struct
    type parentType = t
    type t = {
      name: string option ref,
      id: real option ref,
      email: string option ref,
      phone: phoneNumber list option ref
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

    fun clear_phone msg = 
    ((#phone msg) := NONE; msg)
    fun set_phone (msg, l) = 
    ((#phone msg) := SOME(l); msg)
    fun add_phone (msg, v) = 
      ((case (!(#phone msg)) of NONE => (#phone msg) := SOME([v])
      | SOME(l) => (#phone msg) := SOME(v :: l)); msg)
    fun merge_phone (msg, l) = 
      ((case (!(#phone msg)) of NONE => (#phone msg) := SOME(l)
      | SOME(ll) => (#phone msg) := SOME(List.concat [ll, l])); msg)

    fun init () = { name = ref NONE,
      id = ref NONE,
      email = ref NONE,
      phone = ref NONE
    }

    fun build msg = 
    let
      val nameVal = case (!(#name msg)) of NONE => raise Exception(BUILD, "Required field missing.") | SOME(v) => v
      val idVal = case (!(#id msg)) of NONE => raise Exception(BUILD, "Required field missing.") | SOME(v) => v
      val emailVal = (!(#email msg))
      val phoneVal = case (!(#phone msg)) of NONE => [] | SOME(v) => v
    in { 
      name = nameVal,
      id = idVal,
      email = emailVal,
      phone = phoneVal
    }
    end
  end
  fun encodeToplevel m = 
    let
      val name = (encodeRequired encodeString) (encodeKey(Tag(1), Code(2))) (#name m)
      val id = (encodeRequired encodeDouble) (encodeKey(Tag(2), Code(1))) (#id m)
      val email = (encodeOptional encodeString) (encodeKey(Tag(3), Code(2))) (#email m)
      val phone = (encodeRepeated PhoneNumber.encode) (encodeKey(Tag(4), Code(2))) (#phone m)
    in
      Word8Vector.concat [
        name,
        id,
        email,
        phone
      ]
    end

  fun encode m = encodeMessage (encodeToplevel m)

  fun decodeNextField buff obj remaining = 
    if (remaining = 0) then
      (obj, buff)
    else if (remaining < 0) then
      raise Exception(DECODE, "Field encoding does not match length in message header.")
    else
      let
        val ((Tag(t), Code(c)), parse_result) = decodeKey buff
        val ParseResult(buff, ParsedByteCount(keyByteCount)) = parse_result
        val remaining = remaining - keyByteCount
      in
        if (remaining <= 0) then
          raise Exception(DECODE, "Not enough bytes left after parsing message field key.")
        else case (t) of 1 => decodeNextUnpacked (decodeString) (Builder.set_name) (decodeNextField) obj buff remaining
        | 2 => decodeNextUnpacked (decodeDouble) (Builder.set_id) (decodeNextField) obj buff remaining
        | 3 => decodeNextUnpacked (decodeString) (Builder.set_email) (decodeNextField) obj buff remaining
        | 4 => decodeNextUnpacked (PhoneNumber.decode) (Builder.add_phone) (decodeNextField) obj buff remaining
        | n => raise Exception(DECODE, "Unknown field tag")
      end

  fun decode buff = decodeFullHelper false decodeNextField (Builder.build) (Builder.init ()) buff

  fun decodeToplevel buff = decodeFullHelper true decodeNextField (Builder.build) (Builder.init ()) buff

end
type person = Person.t

signature ADDRESSBOOK =
sig
  type t
  structure Builder : sig
    type t
    type parentType

    val clear_person: t -> t
    val set_person: t * Person.t list -> t
    val merge_person: t * Person.t list -> t
    val add_person: t * Person.t -> t

    val init : unit -> t

    val build : t -> parentType
  end where type parentType = t
  val encode : t -> Word8Vector.vector
  val encodeToplevel : t -> Word8Vector.vector
  val decode : ByteInputStream.stream -> t * parseResult
  val decodeToplevel : ByteInputStream.stream -> t * parseResult
end

structure AddressBook : ADDRESSBOOK = 
struct
  type t = {
    person: person list
  }
  structure Builder = 
  struct
    type parentType = t
    type t = {
      person: person list option ref
    }

    fun clear_person msg = 
    ((#person msg) := NONE; msg)
    fun set_person (msg, l) = 
    ((#person msg) := SOME(l); msg)
    fun add_person (msg, v) = 
      ((case (!(#person msg)) of NONE => (#person msg) := SOME([v])
      | SOME(l) => (#person msg) := SOME(v :: l)); msg)
    fun merge_person (msg, l) = 
      ((case (!(#person msg)) of NONE => (#person msg) := SOME(l)
      | SOME(ll) => (#person msg) := SOME(List.concat [ll, l])); msg)

    fun init () = { person = ref NONE
    }

    fun build msg = 
    let
      val personVal = case (!(#person msg)) of NONE => [] | SOME(v) => v
    in { 
      person = personVal
    }
    end
  end
  fun encodeToplevel m = 
    let
      val person = (encodeRepeated Person.encode) (encodeKey(Tag(1), Code(2))) (#person m)
    in
      Word8Vector.concat [
        person
      ]
    end

  fun encode m = encodeMessage (encodeToplevel m)

  fun decodeNextField buff obj remaining = 
    if (remaining = 0) then
      (obj, buff)
    else if (remaining < 0) then
      raise Exception(DECODE, "Field encoding does not match length in message header.")
    else
      let
        val ((Tag(t), Code(c)), parse_result) = decodeKey buff
        val ParseResult(buff, ParsedByteCount(keyByteCount)) = parse_result
        val remaining = remaining - keyByteCount
      in
        if (remaining <= 0) then
          raise Exception(DECODE, "Not enough bytes left after parsing message field key.")
        else case (t) of 1 => decodeNextUnpacked (Person.decode) (Builder.add_person) (decodeNextField) obj buff remaining
        | n => raise Exception(DECODE, "Unknown field tag")
      end

  fun decode buff = decodeFullHelper false decodeNextField (Builder.build) (Builder.init ()) buff

  fun decodeToplevel buff = decodeFullHelper true decodeNextField (Builder.build) (Builder.init ()) buff

end
type addressBook = AddressBook.t

