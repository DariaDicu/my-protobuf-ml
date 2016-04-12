use "MlGenLib.ml";

signature SMALLPRIMITIVECOLLECTION =
sig
  type t
  structure Builder : sig
    type t
    type parentType

    val clear_my_int32: t -> t
    val set_my_int32: t * int -> t

    val clear_my_int64: t -> t
    val set_my_int64: t * int -> t

    val clear_my_string: t -> t
    val set_my_string: t * string -> t

    val init : unit -> t

    val build : t -> parentType
  end where type parentType = t
  val encode : t -> Word8Vector.vector
  val decode : ByteInputStream.stream -> t * parseResult
end

structure SmallPrimitiveCollection : SMALLPRIMITIVECOLLECTION = 
struct
  type t = {
    my_int32: int option,
    my_int64: int option,
    my_string: string option
  }
  structure Builder = 
  struct
    type parentType = t
    type t = {
      my_int32: int option ref,
      my_int64: int option ref,
      my_string: string option ref
    }

    fun clear_my_int32 msg = 
    ((#my_int32 msg) := NONE; msg)
    fun set_my_int32 (msg, l) = 
    ((#my_int32 msg) := SOME(l); msg)

    fun clear_my_int64 msg = 
    ((#my_int64 msg) := NONE; msg)
    fun set_my_int64 (msg, l) = 
    ((#my_int64 msg) := SOME(l); msg)

    fun clear_my_string msg = 
    ((#my_string msg) := NONE; msg)
    fun set_my_string (msg, l) = 
    ((#my_string msg) := SOME(l); msg)

    fun init () = { my_int32 = ref NONE,
      my_int64 = ref NONE,
      my_string = ref NONE
    }

    fun build msg = 
    let
      val my_int32Val = (!(#my_int32 msg))
      val my_int64Val = (!(#my_int64 msg))
      val my_stringVal = (!(#my_string msg))
    in { 
      my_int32 = my_int32Val,
      my_int64 = my_int64Val,
      my_string = my_stringVal
    }
    end
  end
  fun encode m = 
    let
      val my_int32 = (encodeOptional encodeInt32) (encodeKey(Tag(1), Code(0))) (#my_int32 m)
      val my_int64 = (encodeOptional encodeInt64) (encodeKey(Tag(2), Code(0))) (#my_int64 m)
      val my_string = (encodeOptional encodeString) (encodeKey(Tag(3), Code(2))) (#my_string m)
    in
      encodeMessage (Word8Vector.concat [
        my_int32,
        my_int64,
        my_string
      ])
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
        else case (t) of 1 => decodeNextUnpacked (decodeInt32) (Builder.set_my_int32) (decodeNextField) obj buff remaining
        | 2 => decodeNextUnpacked (decodeInt64) (Builder.set_my_int64) (decodeNextField) obj buff remaining
        | 3 => decodeNextUnpacked (decodeString) (Builder.set_my_string) (decodeNextField) obj buff remaining
        | n => raise Exception(PARSE, "Unknown field tag")
      end

  fun decode buff = decodeFullHelper decodeNextField (Builder.build) (Builder.init ()) buff

end
type smallPrimitiveCollection = SmallPrimitiveCollection.t

signature FULLPRIMITIVECOLLECTION =
sig
  type t
  structure Builder : sig
    type t
    type parentType

    val clear_my_int32: t -> t
    val set_my_int32: t * int -> t

    val clear_my_int64: t -> t
    val set_my_int64: t * int -> t

    val clear_my_uint32: t -> t
    val set_my_uint32: t * int -> t

    val clear_my_uint64: t -> t
    val set_my_uint64: t * int -> t

    val clear_my_sint32: t -> t
    val set_my_sint32: t * int -> t

    val clear_my_sint64: t -> t
    val set_my_sint64: t * int -> t

    val clear_my_fixed32: t -> t
    val set_my_fixed32: t * int -> t

    val clear_my_fixed64: t -> t
    val set_my_fixed64: t * int -> t

    val clear_my_sfixed32: t -> t
    val set_my_sfixed32: t * int -> t

    val clear_my_sfixed64: t -> t
    val set_my_sfixed64: t * int -> t

    val clear_my_bool: t -> t
    val set_my_bool: t * bool -> t

    val clear_my_string: t -> t
    val set_my_string: t * string -> t

    val clear_my_bytes: t -> t
    val set_my_bytes: t * Word8Vector.vector -> t

    val init : unit -> t

    val build : t -> parentType
  end where type parentType = t
  val encode : t -> Word8Vector.vector
  val decode : ByteInputStream.stream -> t * parseResult
end

structure FullPrimitiveCollection : FULLPRIMITIVECOLLECTION = 
struct
  type t = {
    my_int32: int option,
    my_int64: int option,
    my_uint32: int option,
    my_uint64: int option,
    my_sint32: int option,
    my_sint64: int option,
    my_fixed32: int option,
    my_fixed64: int option,
    my_sfixed32: int option,
    my_sfixed64: int option,
    my_bool: bool option,
    my_string: string option,
    my_bytes: Word8Vector.vector option
  }
  structure Builder = 
  struct
    type parentType = t
    type t = {
      my_int32: int option ref,
      my_int64: int option ref,
      my_uint32: int option ref,
      my_uint64: int option ref,
      my_sint32: int option ref,
      my_sint64: int option ref,
      my_fixed32: int option ref,
      my_fixed64: int option ref,
      my_sfixed32: int option ref,
      my_sfixed64: int option ref,
      my_bool: bool option ref,
      my_string: string option ref,
      my_bytes: Word8Vector.vector option ref
    }

    fun clear_my_int32 msg = 
    ((#my_int32 msg) := NONE; msg)
    fun set_my_int32 (msg, l) = 
    ((#my_int32 msg) := SOME(l); msg)

    fun clear_my_int64 msg = 
    ((#my_int64 msg) := NONE; msg)
    fun set_my_int64 (msg, l) = 
    ((#my_int64 msg) := SOME(l); msg)

    fun clear_my_uint32 msg = 
    ((#my_uint32 msg) := NONE; msg)
    fun set_my_uint32 (msg, l) = 
    ((#my_uint32 msg) := SOME(l); msg)

    fun clear_my_uint64 msg = 
    ((#my_uint64 msg) := NONE; msg)
    fun set_my_uint64 (msg, l) = 
    ((#my_uint64 msg) := SOME(l); msg)

    fun clear_my_sint32 msg = 
    ((#my_sint32 msg) := NONE; msg)
    fun set_my_sint32 (msg, l) = 
    ((#my_sint32 msg) := SOME(l); msg)

    fun clear_my_sint64 msg = 
    ((#my_sint64 msg) := NONE; msg)
    fun set_my_sint64 (msg, l) = 
    ((#my_sint64 msg) := SOME(l); msg)

    fun clear_my_fixed32 msg = 
    ((#my_fixed32 msg) := NONE; msg)
    fun set_my_fixed32 (msg, l) = 
    ((#my_fixed32 msg) := SOME(l); msg)

    fun clear_my_fixed64 msg = 
    ((#my_fixed64 msg) := NONE; msg)
    fun set_my_fixed64 (msg, l) = 
    ((#my_fixed64 msg) := SOME(l); msg)

    fun clear_my_sfixed32 msg = 
    ((#my_sfixed32 msg) := NONE; msg)
    fun set_my_sfixed32 (msg, l) = 
    ((#my_sfixed32 msg) := SOME(l); msg)

    fun clear_my_sfixed64 msg = 
    ((#my_sfixed64 msg) := NONE; msg)
    fun set_my_sfixed64 (msg, l) = 
    ((#my_sfixed64 msg) := SOME(l); msg)

    fun clear_my_bool msg = 
    ((#my_bool msg) := NONE; msg)
    fun set_my_bool (msg, l) = 
    ((#my_bool msg) := SOME(l); msg)

    fun clear_my_string msg = 
    ((#my_string msg) := NONE; msg)
    fun set_my_string (msg, l) = 
    ((#my_string msg) := SOME(l); msg)

    fun clear_my_bytes msg = 
    ((#my_bytes msg) := NONE; msg)
    fun set_my_bytes (msg, l) = 
    ((#my_bytes msg) := SOME(l); msg)

    fun init () = { my_int32 = ref NONE,
      my_int64 = ref NONE,
      my_uint32 = ref NONE,
      my_uint64 = ref NONE,
      my_sint32 = ref NONE,
      my_sint64 = ref NONE,
      my_fixed32 = ref NONE,
      my_fixed64 = ref NONE,
      my_sfixed32 = ref NONE,
      my_sfixed64 = ref NONE,
      my_bool = ref NONE,
      my_string = ref NONE,
      my_bytes = ref NONE
    }

    fun build msg = 
    let
      val my_int32Val = (!(#my_int32 msg))
      val my_int64Val = (!(#my_int64 msg))
      val my_uint32Val = (!(#my_uint32 msg))
      val my_uint64Val = (!(#my_uint64 msg))
      val my_sint32Val = (!(#my_sint32 msg))
      val my_sint64Val = (!(#my_sint64 msg))
      val my_fixed32Val = (!(#my_fixed32 msg))
      val my_fixed64Val = (!(#my_fixed64 msg))
      val my_sfixed32Val = (!(#my_sfixed32 msg))
      val my_sfixed64Val = (!(#my_sfixed64 msg))
      val my_boolVal = (!(#my_bool msg))
      val my_stringVal = (!(#my_string msg))
      val my_bytesVal = (!(#my_bytes msg))
    in { 
      my_int32 = my_int32Val,
      my_int64 = my_int64Val,
      my_uint32 = my_uint32Val,
      my_uint64 = my_uint64Val,
      my_sint32 = my_sint32Val,
      my_sint64 = my_sint64Val,
      my_fixed32 = my_fixed32Val,
      my_fixed64 = my_fixed64Val,
      my_sfixed32 = my_sfixed32Val,
      my_sfixed64 = my_sfixed64Val,
      my_bool = my_boolVal,
      my_string = my_stringVal,
      my_bytes = my_bytesVal
    }
    end
  end
  fun encode m = 
    let
      val my_int32 = (encodeOptional encodeInt32) (encodeKey(Tag(1), Code(0))) (#my_int32 m)
      val my_int64 = (encodeOptional encodeInt64) (encodeKey(Tag(2), Code(0))) (#my_int64 m)
      val my_uint32 = (encodeOptional encodeUint32) (encodeKey(Tag(3), Code(0))) (#my_uint32 m)
      val my_uint64 = (encodeOptional encodeUint64) (encodeKey(Tag(4), Code(0))) (#my_uint64 m)
      val my_sint32 = (encodeOptional encodeSint32) (encodeKey(Tag(5), Code(0))) (#my_sint32 m)
      val my_sint64 = (encodeOptional encodeSint64) (encodeKey(Tag(6), Code(0))) (#my_sint64 m)
      val my_fixed32 = (encodeOptional encodeFixed32) (encodeKey(Tag(7), Code(5))) (#my_fixed32 m)
      val my_fixed64 = (encodeOptional encodeFixed64) (encodeKey(Tag(8), Code(1))) (#my_fixed64 m)
      val my_sfixed32 = (encodeOptional encodeSfixed32) (encodeKey(Tag(9), Code(5))) (#my_sfixed32 m)
      val my_sfixed64 = (encodeOptional encodeSfixed64) (encodeKey(Tag(10), Code(1))) (#my_sfixed64 m)
      val my_bool = (encodeOptional encodeBool) (encodeKey(Tag(11), Code(0))) (#my_bool m)
      val my_string = (encodeOptional encodeString) (encodeKey(Tag(12), Code(2))) (#my_string m)
      val my_bytes = (encodeOptional encodeBytes) (encodeKey(Tag(13), Code(2))) (#my_bytes m)
    in
      encodeMessage (Word8Vector.concat [
        my_int32,
        my_int64,
        my_uint32,
        my_uint64,
        my_sint32,
        my_sint64,
        my_fixed32,
        my_fixed64,
        my_sfixed32,
        my_sfixed64,
        my_bool,
        my_string,
        my_bytes
      ])
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
        else case (t) of 1 => decodeNextUnpacked (decodeInt32) (Builder.set_my_int32) (decodeNextField) obj buff remaining
        | 2 => decodeNextUnpacked (decodeInt64) (Builder.set_my_int64) (decodeNextField) obj buff remaining
        | 3 => decodeNextUnpacked (decodeUint32) (Builder.set_my_uint32) (decodeNextField) obj buff remaining
        | 4 => decodeNextUnpacked (decodeUint64) (Builder.set_my_uint64) (decodeNextField) obj buff remaining
        | 5 => decodeNextUnpacked (decodeSint32) (Builder.set_my_sint32) (decodeNextField) obj buff remaining
        | 6 => decodeNextUnpacked (decodeSint64) (Builder.set_my_sint64) (decodeNextField) obj buff remaining
        | 7 => decodeNextUnpacked (decodeFixed32) (Builder.set_my_fixed32) (decodeNextField) obj buff remaining
        | 8 => decodeNextUnpacked (decodeFixed64) (Builder.set_my_fixed64) (decodeNextField) obj buff remaining
        | 9 => decodeNextUnpacked (decodeSfixed32) (Builder.set_my_sfixed32) (decodeNextField) obj buff remaining
        | 10 => decodeNextUnpacked (decodeSfixed64) (Builder.set_my_sfixed64) (decodeNextField) obj buff remaining
        | 11 => decodeNextUnpacked (decodeBool) (Builder.set_my_bool) (decodeNextField) obj buff remaining
        | 12 => decodeNextUnpacked (decodeString) (Builder.set_my_string) (decodeNextField) obj buff remaining
        | 13 => decodeNextUnpacked (decodeBytes) (Builder.set_my_bytes) (decodeNextField) obj buff remaining
        | n => raise Exception(PARSE, "Unknown field tag")
      end

  fun decode buff = decodeFullHelper decodeNextField (Builder.build) (Builder.init ()) buff

end
type fullPrimitiveCollection = FullPrimitiveCollection.t

