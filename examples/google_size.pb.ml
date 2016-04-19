use "MlGenLib.ml";

signature SIZEMESSAGE1SUBMESSAGE =
sig
  type t
  structure Builder : sig
    type t
    type parentType

    val clear_field1: t -> t
    val set_field1: t * int -> t

    val clear_field2: t -> t
    val set_field2: t * int -> t

    val clear_field3: t -> t
    val set_field3: t * int -> t

    val clear_field15: t -> t
    val set_field15: t * string -> t

    val clear_field12: t -> t
    val set_field12: t * bool -> t

    val clear_field13: t -> t
    val set_field13: t * int -> t

    val clear_field14: t -> t
    val set_field14: t * int -> t

    val clear_field16: t -> t
    val set_field16: t * int -> t

    val clear_field19: t -> t
    val set_field19: t * int -> t

    val clear_field20: t -> t
    val set_field20: t * bool -> t

    val clear_field28: t -> t
    val set_field28: t * bool -> t

    val clear_field21: t -> t
    val set_field21: t * int -> t

    val clear_field22: t -> t
    val set_field22: t * int -> t

    val clear_field23: t -> t
    val set_field23: t * bool -> t

    val clear_field206: t -> t
    val set_field206: t * bool -> t

    val clear_field203: t -> t
    val set_field203: t * int -> t

    val clear_field204: t -> t
    val set_field204: t * int -> t

    val clear_field205: t -> t
    val set_field205: t * string -> t

    val clear_field207: t -> t
    val set_field207: t * int -> t

    val clear_field300: t -> t
    val set_field300: t * int -> t

    val init : unit -> t

    val build : t -> parentType
  end where type parentType = t
  val encode : t -> Word8Vector.vector
  val decode : ByteInputStream.stream -> t * parseResult
end

structure SizeMessage1SubMessage : SIZEMESSAGE1SUBMESSAGE = 
struct
  type t = {
    field1: int option,
    field2: int option,
    field3: int option,
    field15: string option,
    field12: bool option,
    field13: int option,
    field14: int option,
    field16: int option,
    field19: int option,
    field20: bool option,
    field28: bool option,
    field21: int option,
    field22: int option,
    field23: bool option,
    field206: bool option,
    field203: int option,
    field204: int option,
    field205: string option,
    field207: int option,
    field300: int option
  }
  structure Builder = 
  struct
    type parentType = t
    type t = {
      field1: int option ref,
      field2: int option ref,
      field3: int option ref,
      field15: string option ref,
      field12: bool option ref,
      field13: int option ref,
      field14: int option ref,
      field16: int option ref,
      field19: int option ref,
      field20: bool option ref,
      field28: bool option ref,
      field21: int option ref,
      field22: int option ref,
      field23: bool option ref,
      field206: bool option ref,
      field203: int option ref,
      field204: int option ref,
      field205: string option ref,
      field207: int option ref,
      field300: int option ref
    }

    fun clear_field1 msg = 
    ((#field1 msg) := NONE; msg)
    fun set_field1 (msg, l) = 
    ((#field1 msg) := SOME(l); msg)

    fun clear_field2 msg = 
    ((#field2 msg) := NONE; msg)
    fun set_field2 (msg, l) = 
    ((#field2 msg) := SOME(l); msg)

    fun clear_field3 msg = 
    ((#field3 msg) := NONE; msg)
    fun set_field3 (msg, l) = 
    ((#field3 msg) := SOME(l); msg)

    fun clear_field15 msg = 
    ((#field15 msg) := NONE; msg)
    fun set_field15 (msg, l) = 
    ((#field15 msg) := SOME(l); msg)

    fun clear_field12 msg = 
    ((#field12 msg) := NONE; msg)
    fun set_field12 (msg, l) = 
    ((#field12 msg) := SOME(l); msg)

    fun clear_field13 msg = 
    ((#field13 msg) := NONE; msg)
    fun set_field13 (msg, l) = 
    ((#field13 msg) := SOME(l); msg)

    fun clear_field14 msg = 
    ((#field14 msg) := NONE; msg)
    fun set_field14 (msg, l) = 
    ((#field14 msg) := SOME(l); msg)

    fun clear_field16 msg = 
    ((#field16 msg) := NONE; msg)
    fun set_field16 (msg, l) = 
    ((#field16 msg) := SOME(l); msg)

    fun clear_field19 msg = 
    ((#field19 msg) := NONE; msg)
    fun set_field19 (msg, l) = 
    ((#field19 msg) := SOME(l); msg)

    fun clear_field20 msg = 
    ((#field20 msg) := NONE; msg)
    fun set_field20 (msg, l) = 
    ((#field20 msg) := SOME(l); msg)

    fun clear_field28 msg = 
    ((#field28 msg) := NONE; msg)
    fun set_field28 (msg, l) = 
    ((#field28 msg) := SOME(l); msg)

    fun clear_field21 msg = 
    ((#field21 msg) := NONE; msg)
    fun set_field21 (msg, l) = 
    ((#field21 msg) := SOME(l); msg)

    fun clear_field22 msg = 
    ((#field22 msg) := NONE; msg)
    fun set_field22 (msg, l) = 
    ((#field22 msg) := SOME(l); msg)

    fun clear_field23 msg = 
    ((#field23 msg) := NONE; msg)
    fun set_field23 (msg, l) = 
    ((#field23 msg) := SOME(l); msg)

    fun clear_field206 msg = 
    ((#field206 msg) := NONE; msg)
    fun set_field206 (msg, l) = 
    ((#field206 msg) := SOME(l); msg)

    fun clear_field203 msg = 
    ((#field203 msg) := NONE; msg)
    fun set_field203 (msg, l) = 
    ((#field203 msg) := SOME(l); msg)

    fun clear_field204 msg = 
    ((#field204 msg) := NONE; msg)
    fun set_field204 (msg, l) = 
    ((#field204 msg) := SOME(l); msg)

    fun clear_field205 msg = 
    ((#field205 msg) := NONE; msg)
    fun set_field205 (msg, l) = 
    ((#field205 msg) := SOME(l); msg)

    fun clear_field207 msg = 
    ((#field207 msg) := NONE; msg)
    fun set_field207 (msg, l) = 
    ((#field207 msg) := SOME(l); msg)

    fun clear_field300 msg = 
    ((#field300 msg) := NONE; msg)
    fun set_field300 (msg, l) = 
    ((#field300 msg) := SOME(l); msg)

    fun init () = { field1 = ref NONE,
      field2 = ref NONE,
      field3 = ref NONE,
      field15 = ref NONE,
      field12 = ref NONE,
      field13 = ref NONE,
      field14 = ref NONE,
      field16 = ref NONE,
      field19 = ref NONE,
      field20 = ref NONE,
      field28 = ref NONE,
      field21 = ref NONE,
      field22 = ref NONE,
      field23 = ref NONE,
      field206 = ref NONE,
      field203 = ref NONE,
      field204 = ref NONE,
      field205 = ref NONE,
      field207 = ref NONE,
      field300 = ref NONE
    }

    fun build msg = 
    let
      val field1Val = (!(#field1 msg))
      val field2Val = (!(#field2 msg))
      val field3Val = (!(#field3 msg))
      val field15Val = (!(#field15 msg))
      val field12Val = (!(#field12 msg))
      val field13Val = (!(#field13 msg))
      val field14Val = (!(#field14 msg))
      val field16Val = (!(#field16 msg))
      val field19Val = (!(#field19 msg))
      val field20Val = (!(#field20 msg))
      val field28Val = (!(#field28 msg))
      val field21Val = (!(#field21 msg))
      val field22Val = (!(#field22 msg))
      val field23Val = (!(#field23 msg))
      val field206Val = (!(#field206 msg))
      val field203Val = (!(#field203 msg))
      val field204Val = (!(#field204 msg))
      val field205Val = (!(#field205 msg))
      val field207Val = (!(#field207 msg))
      val field300Val = (!(#field300 msg))
    in { 
      field1 = field1Val,
      field2 = field2Val,
      field3 = field3Val,
      field15 = field15Val,
      field12 = field12Val,
      field13 = field13Val,
      field14 = field14Val,
      field16 = field16Val,
      field19 = field19Val,
      field20 = field20Val,
      field28 = field28Val,
      field21 = field21Val,
      field22 = field22Val,
      field23 = field23Val,
      field206 = field206Val,
      field203 = field203Val,
      field204 = field204Val,
      field205 = field205Val,
      field207 = field207Val,
      field300 = field300Val
    }
    end
  end
  fun encode m = 
    let
      val field1 = (encodeOptional encodeInt32) (encodeKey(Tag(1), Code(0))) (#field1 m)
      val field2 = (encodeOptional encodeInt32) (encodeKey(Tag(2), Code(0))) (#field2 m)
      val field3 = (encodeOptional encodeInt32) (encodeKey(Tag(3), Code(0))) (#field3 m)
      val field15 = (encodeOptional encodeString) (encodeKey(Tag(15), Code(2))) (#field15 m)
      val field12 = (encodeOptional encodeBool) (encodeKey(Tag(12), Code(0))) (#field12 m)
      val field13 = (encodeOptional encodeInt64) (encodeKey(Tag(13), Code(0))) (#field13 m)
      val field14 = (encodeOptional encodeInt64) (encodeKey(Tag(14), Code(0))) (#field14 m)
      val field16 = (encodeOptional encodeInt32) (encodeKey(Tag(16), Code(0))) (#field16 m)
      val field19 = (encodeOptional encodeInt32) (encodeKey(Tag(19), Code(0))) (#field19 m)
      val field20 = (encodeOptional encodeBool) (encodeKey(Tag(20), Code(0))) (#field20 m)
      val field28 = (encodeOptional encodeBool) (encodeKey(Tag(28), Code(0))) (#field28 m)
      val field21 = (encodeOptional encodeFixed64) (encodeKey(Tag(21), Code(1))) (#field21 m)
      val field22 = (encodeOptional encodeInt32) (encodeKey(Tag(22), Code(0))) (#field22 m)
      val field23 = (encodeOptional encodeBool) (encodeKey(Tag(23), Code(0))) (#field23 m)
      val field206 = (encodeOptional encodeBool) (encodeKey(Tag(206), Code(0))) (#field206 m)
      val field203 = (encodeOptional encodeFixed32) (encodeKey(Tag(203), Code(5))) (#field203 m)
      val field204 = (encodeOptional encodeInt32) (encodeKey(Tag(204), Code(0))) (#field204 m)
      val field205 = (encodeOptional encodeString) (encodeKey(Tag(205), Code(2))) (#field205 m)
      val field207 = (encodeOptional encodeUint64) (encodeKey(Tag(207), Code(0))) (#field207 m)
      val field300 = (encodeOptional encodeUint64) (encodeKey(Tag(300), Code(0))) (#field300 m)
    in
      encodeMessage (Word8Vector.concat [
        field1,
        field2,
        field3,
        field15,
        field12,
        field13,
        field14,
        field16,
        field19,
        field20,
        field28,
        field21,
        field22,
        field23,
        field206,
        field203,
        field204,
        field205,
        field207,
        field300
      ])
    end

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
        else case (t) of 1 => decodeNextUnpacked (decodeInt32) (Builder.set_field1) (decodeNextField) obj buff remaining
        | 2 => decodeNextUnpacked (decodeInt32) (Builder.set_field2) (decodeNextField) obj buff remaining
        | 3 => decodeNextUnpacked (decodeInt32) (Builder.set_field3) (decodeNextField) obj buff remaining
        | 15 => decodeNextUnpacked (decodeString) (Builder.set_field15) (decodeNextField) obj buff remaining
        | 12 => decodeNextUnpacked (decodeBool) (Builder.set_field12) (decodeNextField) obj buff remaining
        | 13 => decodeNextUnpacked (decodeInt64) (Builder.set_field13) (decodeNextField) obj buff remaining
        | 14 => decodeNextUnpacked (decodeInt64) (Builder.set_field14) (decodeNextField) obj buff remaining
        | 16 => decodeNextUnpacked (decodeInt32) (Builder.set_field16) (decodeNextField) obj buff remaining
        | 19 => decodeNextUnpacked (decodeInt32) (Builder.set_field19) (decodeNextField) obj buff remaining
        | 20 => decodeNextUnpacked (decodeBool) (Builder.set_field20) (decodeNextField) obj buff remaining
        | 28 => decodeNextUnpacked (decodeBool) (Builder.set_field28) (decodeNextField) obj buff remaining
        | 21 => decodeNextUnpacked (decodeFixed64) (Builder.set_field21) (decodeNextField) obj buff remaining
        | 22 => decodeNextUnpacked (decodeInt32) (Builder.set_field22) (decodeNextField) obj buff remaining
        | 23 => decodeNextUnpacked (decodeBool) (Builder.set_field23) (decodeNextField) obj buff remaining
        | 206 => decodeNextUnpacked (decodeBool) (Builder.set_field206) (decodeNextField) obj buff remaining
        | 203 => decodeNextUnpacked (decodeFixed32) (Builder.set_field203) (decodeNextField) obj buff remaining
        | 204 => decodeNextUnpacked (decodeInt32) (Builder.set_field204) (decodeNextField) obj buff remaining
        | 205 => decodeNextUnpacked (decodeString) (Builder.set_field205) (decodeNextField) obj buff remaining
        | 207 => decodeNextUnpacked (decodeUint64) (Builder.set_field207) (decodeNextField) obj buff remaining
        | 300 => decodeNextUnpacked (decodeUint64) (Builder.set_field300) (decodeNextField) obj buff remaining
        | n => raise Exception(DECODE, "Unknown field tag")
      end

  fun decode buff = decodeFullHelper decodeNextField (Builder.build) (Builder.init ()) buff

end
type sizeMessage1SubMessage = SizeMessage1SubMessage.t

signature SIZEMESSAGE1 =
sig
  type t
  structure Builder : sig
    type t
    type parentType

    val clear_field1: t -> t
    val set_field1: t * string -> t

    val clear_field9: t -> t
    val set_field9: t * string -> t

    val clear_field18: t -> t
    val set_field18: t * string -> t

    val clear_field80: t -> t
    val set_field80: t * bool -> t

    val clear_field81: t -> t
    val set_field81: t * bool -> t

    val clear_field2: t -> t
    val set_field2: t * int -> t

    val clear_field3: t -> t
    val set_field3: t * int -> t

    val clear_field280: t -> t
    val set_field280: t * int -> t

    val clear_field6: t -> t
    val set_field6: t * int -> t

    val clear_field22: t -> t
    val set_field22: t * int -> t

    val clear_field4: t -> t
    val set_field4: t * string -> t

    val clear_field5: t -> t
    val set_field5: t * int list -> t
    val merge_field5: t * int list -> t
    val add_field5: t * int -> t

    val clear_field59: t -> t
    val set_field59: t * bool -> t

    val clear_field7: t -> t
    val set_field7: t * string -> t

    val clear_field16: t -> t
    val set_field16: t * int -> t

    val clear_field130: t -> t
    val set_field130: t * int -> t

    val clear_field12: t -> t
    val set_field12: t * bool -> t

    val clear_field17: t -> t
    val set_field17: t * bool -> t

    val clear_field13: t -> t
    val set_field13: t * bool -> t

    val clear_field14: t -> t
    val set_field14: t * bool -> t

    val clear_field104: t -> t
    val set_field104: t * int -> t

    val clear_field100: t -> t
    val set_field100: t * int -> t

    val clear_field101: t -> t
    val set_field101: t * int -> t

    val clear_field102: t -> t
    val set_field102: t * string -> t

    val clear_field103: t -> t
    val set_field103: t * string -> t

    val clear_field29: t -> t
    val set_field29: t * int -> t

    val clear_field30: t -> t
    val set_field30: t * bool -> t

    val clear_field60: t -> t
    val set_field60: t * int -> t

    val clear_field271: t -> t
    val set_field271: t * int -> t

    val clear_field272: t -> t
    val set_field272: t * int -> t

    val clear_field150: t -> t
    val set_field150: t * int -> t

    val clear_field23: t -> t
    val set_field23: t * int -> t

    val clear_field24: t -> t
    val set_field24: t * bool -> t

    val clear_field25: t -> t
    val set_field25: t * int -> t

    val clear_field15: t -> t
    val set_field15: t * SizeMessage1SubMessage.t -> t

    val clear_field78: t -> t
    val set_field78: t * bool -> t

    val clear_field67: t -> t
    val set_field67: t * int -> t

    val clear_field68: t -> t
    val set_field68: t * int -> t

    val clear_field128: t -> t
    val set_field128: t * int -> t

    val clear_field129: t -> t
    val set_field129: t * string -> t

    val clear_field131: t -> t
    val set_field131: t * int -> t

    val init : unit -> t

    val build : t -> parentType
  end where type parentType = t
  val encode : t -> Word8Vector.vector
  val decode : ByteInputStream.stream -> t * parseResult
end

structure SizeMessage1 : SIZEMESSAGE1 = 
struct
  type t = {
    field1: string ,
    field9: string option,
    field18: string option,
    field80: bool option,
    field81: bool option,
    field2: int ,
    field3: int ,
    field280: int option,
    field6: int option,
    field22: int option,
    field4: string option,
    field5: int list,
    field59: bool option,
    field7: string option,
    field16: int option,
    field130: int option,
    field12: bool option,
    field17: bool option,
    field13: bool option,
    field14: bool option,
    field104: int option,
    field100: int option,
    field101: int option,
    field102: string option,
    field103: string option,
    field29: int option,
    field30: bool option,
    field60: int option,
    field271: int option,
    field272: int option,
    field150: int option,
    field23: int option,
    field24: bool option,
    field25: int option,
    field15: sizeMessage1SubMessage option,
    field78: bool option,
    field67: int option,
    field68: int option,
    field128: int option,
    field129: string option,
    field131: int option
  }
  structure Builder = 
  struct
    type parentType = t
    type t = {
      field1: string option ref,
      field9: string option ref,
      field18: string option ref,
      field80: bool option ref,
      field81: bool option ref,
      field2: int option ref,
      field3: int option ref,
      field280: int option ref,
      field6: int option ref,
      field22: int option ref,
      field4: string option ref,
      field5: int list option ref,
      field59: bool option ref,
      field7: string option ref,
      field16: int option ref,
      field130: int option ref,
      field12: bool option ref,
      field17: bool option ref,
      field13: bool option ref,
      field14: bool option ref,
      field104: int option ref,
      field100: int option ref,
      field101: int option ref,
      field102: string option ref,
      field103: string option ref,
      field29: int option ref,
      field30: bool option ref,
      field60: int option ref,
      field271: int option ref,
      field272: int option ref,
      field150: int option ref,
      field23: int option ref,
      field24: bool option ref,
      field25: int option ref,
      field15: sizeMessage1SubMessage option ref,
      field78: bool option ref,
      field67: int option ref,
      field68: int option ref,
      field128: int option ref,
      field129: string option ref,
      field131: int option ref
    }

    fun clear_field1 msg = 
    ((#field1 msg) := NONE; msg)
    fun set_field1 (msg, l) = 
    ((#field1 msg) := SOME(l); msg)

    fun clear_field9 msg = 
    ((#field9 msg) := NONE; msg)
    fun set_field9 (msg, l) = 
    ((#field9 msg) := SOME(l); msg)

    fun clear_field18 msg = 
    ((#field18 msg) := NONE; msg)
    fun set_field18 (msg, l) = 
    ((#field18 msg) := SOME(l); msg)

    fun clear_field80 msg = 
    ((#field80 msg) := NONE; msg)
    fun set_field80 (msg, l) = 
    ((#field80 msg) := SOME(l); msg)

    fun clear_field81 msg = 
    ((#field81 msg) := NONE; msg)
    fun set_field81 (msg, l) = 
    ((#field81 msg) := SOME(l); msg)

    fun clear_field2 msg = 
    ((#field2 msg) := NONE; msg)
    fun set_field2 (msg, l) = 
    ((#field2 msg) := SOME(l); msg)

    fun clear_field3 msg = 
    ((#field3 msg) := NONE; msg)
    fun set_field3 (msg, l) = 
    ((#field3 msg) := SOME(l); msg)

    fun clear_field280 msg = 
    ((#field280 msg) := NONE; msg)
    fun set_field280 (msg, l) = 
    ((#field280 msg) := SOME(l); msg)

    fun clear_field6 msg = 
    ((#field6 msg) := NONE; msg)
    fun set_field6 (msg, l) = 
    ((#field6 msg) := SOME(l); msg)

    fun clear_field22 msg = 
    ((#field22 msg) := NONE; msg)
    fun set_field22 (msg, l) = 
    ((#field22 msg) := SOME(l); msg)

    fun clear_field4 msg = 
    ((#field4 msg) := NONE; msg)
    fun set_field4 (msg, l) = 
    ((#field4 msg) := SOME(l); msg)

    fun clear_field5 msg = 
    ((#field5 msg) := NONE; msg)
    fun set_field5 (msg, l) = 
    ((#field5 msg) := SOME(l); msg)
    fun add_field5 (msg, v) = 
      ((case (!(#field5 msg)) of NONE => (#field5 msg) := SOME([v])
      | SOME(l) => (#field5 msg) := SOME(v :: l)); msg)
    fun merge_field5 (msg, l) = 
      ((case (!(#field5 msg)) of NONE => (#field5 msg) := SOME(l)
      | SOME(ll) => (#field5 msg) := SOME(List.concat [ll, l])); msg)

    fun clear_field59 msg = 
    ((#field59 msg) := NONE; msg)
    fun set_field59 (msg, l) = 
    ((#field59 msg) := SOME(l); msg)

    fun clear_field7 msg = 
    ((#field7 msg) := NONE; msg)
    fun set_field7 (msg, l) = 
    ((#field7 msg) := SOME(l); msg)

    fun clear_field16 msg = 
    ((#field16 msg) := NONE; msg)
    fun set_field16 (msg, l) = 
    ((#field16 msg) := SOME(l); msg)

    fun clear_field130 msg = 
    ((#field130 msg) := NONE; msg)
    fun set_field130 (msg, l) = 
    ((#field130 msg) := SOME(l); msg)

    fun clear_field12 msg = 
    ((#field12 msg) := NONE; msg)
    fun set_field12 (msg, l) = 
    ((#field12 msg) := SOME(l); msg)

    fun clear_field17 msg = 
    ((#field17 msg) := NONE; msg)
    fun set_field17 (msg, l) = 
    ((#field17 msg) := SOME(l); msg)

    fun clear_field13 msg = 
    ((#field13 msg) := NONE; msg)
    fun set_field13 (msg, l) = 
    ((#field13 msg) := SOME(l); msg)

    fun clear_field14 msg = 
    ((#field14 msg) := NONE; msg)
    fun set_field14 (msg, l) = 
    ((#field14 msg) := SOME(l); msg)

    fun clear_field104 msg = 
    ((#field104 msg) := NONE; msg)
    fun set_field104 (msg, l) = 
    ((#field104 msg) := SOME(l); msg)

    fun clear_field100 msg = 
    ((#field100 msg) := NONE; msg)
    fun set_field100 (msg, l) = 
    ((#field100 msg) := SOME(l); msg)

    fun clear_field101 msg = 
    ((#field101 msg) := NONE; msg)
    fun set_field101 (msg, l) = 
    ((#field101 msg) := SOME(l); msg)

    fun clear_field102 msg = 
    ((#field102 msg) := NONE; msg)
    fun set_field102 (msg, l) = 
    ((#field102 msg) := SOME(l); msg)

    fun clear_field103 msg = 
    ((#field103 msg) := NONE; msg)
    fun set_field103 (msg, l) = 
    ((#field103 msg) := SOME(l); msg)

    fun clear_field29 msg = 
    ((#field29 msg) := NONE; msg)
    fun set_field29 (msg, l) = 
    ((#field29 msg) := SOME(l); msg)

    fun clear_field30 msg = 
    ((#field30 msg) := NONE; msg)
    fun set_field30 (msg, l) = 
    ((#field30 msg) := SOME(l); msg)

    fun clear_field60 msg = 
    ((#field60 msg) := NONE; msg)
    fun set_field60 (msg, l) = 
    ((#field60 msg) := SOME(l); msg)

    fun clear_field271 msg = 
    ((#field271 msg) := NONE; msg)
    fun set_field271 (msg, l) = 
    ((#field271 msg) := SOME(l); msg)

    fun clear_field272 msg = 
    ((#field272 msg) := NONE; msg)
    fun set_field272 (msg, l) = 
    ((#field272 msg) := SOME(l); msg)

    fun clear_field150 msg = 
    ((#field150 msg) := NONE; msg)
    fun set_field150 (msg, l) = 
    ((#field150 msg) := SOME(l); msg)

    fun clear_field23 msg = 
    ((#field23 msg) := NONE; msg)
    fun set_field23 (msg, l) = 
    ((#field23 msg) := SOME(l); msg)

    fun clear_field24 msg = 
    ((#field24 msg) := NONE; msg)
    fun set_field24 (msg, l) = 
    ((#field24 msg) := SOME(l); msg)

    fun clear_field25 msg = 
    ((#field25 msg) := NONE; msg)
    fun set_field25 (msg, l) = 
    ((#field25 msg) := SOME(l); msg)

    fun clear_field15 msg = 
    ((#field15 msg) := NONE; msg)
    fun set_field15 (msg, l) = 
    ((#field15 msg) := SOME(l); msg)

    fun clear_field78 msg = 
    ((#field78 msg) := NONE; msg)
    fun set_field78 (msg, l) = 
    ((#field78 msg) := SOME(l); msg)

    fun clear_field67 msg = 
    ((#field67 msg) := NONE; msg)
    fun set_field67 (msg, l) = 
    ((#field67 msg) := SOME(l); msg)

    fun clear_field68 msg = 
    ((#field68 msg) := NONE; msg)
    fun set_field68 (msg, l) = 
    ((#field68 msg) := SOME(l); msg)

    fun clear_field128 msg = 
    ((#field128 msg) := NONE; msg)
    fun set_field128 (msg, l) = 
    ((#field128 msg) := SOME(l); msg)

    fun clear_field129 msg = 
    ((#field129 msg) := NONE; msg)
    fun set_field129 (msg, l) = 
    ((#field129 msg) := SOME(l); msg)

    fun clear_field131 msg = 
    ((#field131 msg) := NONE; msg)
    fun set_field131 (msg, l) = 
    ((#field131 msg) := SOME(l); msg)

    fun init () = { field1 = ref NONE,
      field9 = ref NONE,
      field18 = ref NONE,
      field80 = ref NONE,
      field81 = ref NONE,
      field2 = ref NONE,
      field3 = ref NONE,
      field280 = ref NONE,
      field6 = ref NONE,
      field22 = ref NONE,
      field4 = ref NONE,
      field5 = ref NONE,
      field59 = ref NONE,
      field7 = ref NONE,
      field16 = ref NONE,
      field130 = ref NONE,
      field12 = ref NONE,
      field17 = ref NONE,
      field13 = ref NONE,
      field14 = ref NONE,
      field104 = ref NONE,
      field100 = ref NONE,
      field101 = ref NONE,
      field102 = ref NONE,
      field103 = ref NONE,
      field29 = ref NONE,
      field30 = ref NONE,
      field60 = ref NONE,
      field271 = ref NONE,
      field272 = ref NONE,
      field150 = ref NONE,
      field23 = ref NONE,
      field24 = ref NONE,
      field25 = ref NONE,
      field15 = ref NONE,
      field78 = ref NONE,
      field67 = ref NONE,
      field68 = ref NONE,
      field128 = ref NONE,
      field129 = ref NONE,
      field131 = ref NONE
    }

    fun build msg = 
    let
      val field1Val = case (!(#field1 msg)) of NONE => raise Exception(BUILD, "Required field missing.") | SOME(v) => v
      val field9Val = (!(#field9 msg))
      val field18Val = (!(#field18 msg))
      val field80Val = (!(#field80 msg))
      val field81Val = (!(#field81 msg))
      val field2Val = case (!(#field2 msg)) of NONE => raise Exception(BUILD, "Required field missing.") | SOME(v) => v
      val field3Val = case (!(#field3 msg)) of NONE => raise Exception(BUILD, "Required field missing.") | SOME(v) => v
      val field280Val = (!(#field280 msg))
      val field6Val = (!(#field6 msg))
      val field22Val = (!(#field22 msg))
      val field4Val = (!(#field4 msg))
      val field5Val = case (!(#field5 msg)) of NONE => [] | SOME(v) => v
      val field59Val = (!(#field59 msg))
      val field7Val = (!(#field7 msg))
      val field16Val = (!(#field16 msg))
      val field130Val = (!(#field130 msg))
      val field12Val = (!(#field12 msg))
      val field17Val = (!(#field17 msg))
      val field13Val = (!(#field13 msg))
      val field14Val = (!(#field14 msg))
      val field104Val = (!(#field104 msg))
      val field100Val = (!(#field100 msg))
      val field101Val = (!(#field101 msg))
      val field102Val = (!(#field102 msg))
      val field103Val = (!(#field103 msg))
      val field29Val = (!(#field29 msg))
      val field30Val = (!(#field30 msg))
      val field60Val = (!(#field60 msg))
      val field271Val = (!(#field271 msg))
      val field272Val = (!(#field272 msg))
      val field150Val = (!(#field150 msg))
      val field23Val = (!(#field23 msg))
      val field24Val = (!(#field24 msg))
      val field25Val = (!(#field25 msg))
      val field15Val = (!(#field15 msg))
      val field78Val = (!(#field78 msg))
      val field67Val = (!(#field67 msg))
      val field68Val = (!(#field68 msg))
      val field128Val = (!(#field128 msg))
      val field129Val = (!(#field129 msg))
      val field131Val = (!(#field131 msg))
    in { 
      field1 = field1Val,
      field9 = field9Val,
      field18 = field18Val,
      field80 = field80Val,
      field81 = field81Val,
      field2 = field2Val,
      field3 = field3Val,
      field280 = field280Val,
      field6 = field6Val,
      field22 = field22Val,
      field4 = field4Val,
      field5 = field5Val,
      field59 = field59Val,
      field7 = field7Val,
      field16 = field16Val,
      field130 = field130Val,
      field12 = field12Val,
      field17 = field17Val,
      field13 = field13Val,
      field14 = field14Val,
      field104 = field104Val,
      field100 = field100Val,
      field101 = field101Val,
      field102 = field102Val,
      field103 = field103Val,
      field29 = field29Val,
      field30 = field30Val,
      field60 = field60Val,
      field271 = field271Val,
      field272 = field272Val,
      field150 = field150Val,
      field23 = field23Val,
      field24 = field24Val,
      field25 = field25Val,
      field15 = field15Val,
      field78 = field78Val,
      field67 = field67Val,
      field68 = field68Val,
      field128 = field128Val,
      field129 = field129Val,
      field131 = field131Val
    }
    end
  end
  fun encode m = 
    let
      val field1 = (encodeRequired encodeString) (encodeKey(Tag(1), Code(2))) (#field1 m)
      val field9 = (encodeOptional encodeString) (encodeKey(Tag(9), Code(2))) (#field9 m)
      val field18 = (encodeOptional encodeString) (encodeKey(Tag(18), Code(2))) (#field18 m)
      val field80 = (encodeOptional encodeBool) (encodeKey(Tag(80), Code(0))) (#field80 m)
      val field81 = (encodeOptional encodeBool) (encodeKey(Tag(81), Code(0))) (#field81 m)
      val field2 = (encodeRequired encodeInt32) (encodeKey(Tag(2), Code(0))) (#field2 m)
      val field3 = (encodeRequired encodeInt32) (encodeKey(Tag(3), Code(0))) (#field3 m)
      val field280 = (encodeOptional encodeInt32) (encodeKey(Tag(280), Code(0))) (#field280 m)
      val field6 = (encodeOptional encodeInt32) (encodeKey(Tag(6), Code(0))) (#field6 m)
      val field22 = (encodeOptional encodeInt64) (encodeKey(Tag(22), Code(0))) (#field22 m)
      val field4 = (encodeOptional encodeString) (encodeKey(Tag(4), Code(2))) (#field4 m)
      val field5 = (encodePackedRepeated encodeFixed64) (encodeKey(Tag(5), Code(2))) (#field5 m)
      val field59 = (encodeOptional encodeBool) (encodeKey(Tag(59), Code(0))) (#field59 m)
      val field7 = (encodeOptional encodeString) (encodeKey(Tag(7), Code(2))) (#field7 m)
      val field16 = (encodeOptional encodeInt32) (encodeKey(Tag(16), Code(0))) (#field16 m)
      val field130 = (encodeOptional encodeInt32) (encodeKey(Tag(130), Code(0))) (#field130 m)
      val field12 = (encodeOptional encodeBool) (encodeKey(Tag(12), Code(0))) (#field12 m)
      val field17 = (encodeOptional encodeBool) (encodeKey(Tag(17), Code(0))) (#field17 m)
      val field13 = (encodeOptional encodeBool) (encodeKey(Tag(13), Code(0))) (#field13 m)
      val field14 = (encodeOptional encodeBool) (encodeKey(Tag(14), Code(0))) (#field14 m)
      val field104 = (encodeOptional encodeInt32) (encodeKey(Tag(104), Code(0))) (#field104 m)
      val field100 = (encodeOptional encodeInt32) (encodeKey(Tag(100), Code(0))) (#field100 m)
      val field101 = (encodeOptional encodeInt32) (encodeKey(Tag(101), Code(0))) (#field101 m)
      val field102 = (encodeOptional encodeString) (encodeKey(Tag(102), Code(2))) (#field102 m)
      val field103 = (encodeOptional encodeString) (encodeKey(Tag(103), Code(2))) (#field103 m)
      val field29 = (encodeOptional encodeInt32) (encodeKey(Tag(29), Code(0))) (#field29 m)
      val field30 = (encodeOptional encodeBool) (encodeKey(Tag(30), Code(0))) (#field30 m)
      val field60 = (encodeOptional encodeInt32) (encodeKey(Tag(60), Code(0))) (#field60 m)
      val field271 = (encodeOptional encodeInt32) (encodeKey(Tag(271), Code(0))) (#field271 m)
      val field272 = (encodeOptional encodeInt32) (encodeKey(Tag(272), Code(0))) (#field272 m)
      val field150 = (encodeOptional encodeInt32) (encodeKey(Tag(150), Code(0))) (#field150 m)
      val field23 = (encodeOptional encodeInt32) (encodeKey(Tag(23), Code(0))) (#field23 m)
      val field24 = (encodeOptional encodeBool) (encodeKey(Tag(24), Code(0))) (#field24 m)
      val field25 = (encodeOptional encodeInt32) (encodeKey(Tag(25), Code(0))) (#field25 m)
      val field15 = (encodeOptional SizeMessage1SubMessage.encode) (encodeKey(Tag(15), Code(2))) (#field15 m)
      val field78 = (encodeOptional encodeBool) (encodeKey(Tag(78), Code(0))) (#field78 m)
      val field67 = (encodeOptional encodeInt32) (encodeKey(Tag(67), Code(0))) (#field67 m)
      val field68 = (encodeOptional encodeInt32) (encodeKey(Tag(68), Code(0))) (#field68 m)
      val field128 = (encodeOptional encodeInt32) (encodeKey(Tag(128), Code(0))) (#field128 m)
      val field129 = (encodeOptional encodeString) (encodeKey(Tag(129), Code(2))) (#field129 m)
      val field131 = (encodeOptional encodeInt32) (encodeKey(Tag(131), Code(0))) (#field131 m)
    in
      encodeMessage (Word8Vector.concat [
        field1,
        field9,
        field18,
        field80,
        field81,
        field2,
        field3,
        field280,
        field6,
        field22,
        field4,
        field5,
        field59,
        field7,
        field16,
        field130,
        field12,
        field17,
        field13,
        field14,
        field104,
        field100,
        field101,
        field102,
        field103,
        field29,
        field30,
        field60,
        field271,
        field272,
        field150,
        field23,
        field24,
        field25,
        field15,
        field78,
        field67,
        field68,
        field128,
        field129,
        field131
      ])
    end

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
        else case (t) of 1 => decodeNextUnpacked (decodeString) (Builder.set_field1) (decodeNextField) obj buff remaining
        | 9 => decodeNextUnpacked (decodeString) (Builder.set_field9) (decodeNextField) obj buff remaining
        | 18 => decodeNextUnpacked (decodeString) (Builder.set_field18) (decodeNextField) obj buff remaining
        | 80 => decodeNextUnpacked (decodeBool) (Builder.set_field80) (decodeNextField) obj buff remaining
        | 81 => decodeNextUnpacked (decodeBool) (Builder.set_field81) (decodeNextField) obj buff remaining
        | 2 => decodeNextUnpacked (decodeInt32) (Builder.set_field2) (decodeNextField) obj buff remaining
        | 3 => decodeNextUnpacked (decodeInt32) (Builder.set_field3) (decodeNextField) obj buff remaining
        | 280 => decodeNextUnpacked (decodeInt32) (Builder.set_field280) (decodeNextField) obj buff remaining
        | 6 => decodeNextUnpacked (decodeInt32) (Builder.set_field6) (decodeNextField) obj buff remaining
        | 22 => decodeNextUnpacked (decodeInt64) (Builder.set_field22) (decodeNextField) obj buff remaining
        | 4 => decodeNextUnpacked (decodeString) (Builder.set_field4) (decodeNextField) obj buff remaining
        | 5 => if (c = 2) then (decodeNextPacked (decodeFixed64) (Builder.add_field5) (decodeNextField) obj buff remaining)
        else (decodeNextUnpacked (decodeFixed64) (Builder.add_field5) (decodeNextField) obj buff remaining)

        | 59 => decodeNextUnpacked (decodeBool) (Builder.set_field59) (decodeNextField) obj buff remaining
        | 7 => decodeNextUnpacked (decodeString) (Builder.set_field7) (decodeNextField) obj buff remaining
        | 16 => decodeNextUnpacked (decodeInt32) (Builder.set_field16) (decodeNextField) obj buff remaining
        | 130 => decodeNextUnpacked (decodeInt32) (Builder.set_field130) (decodeNextField) obj buff remaining
        | 12 => decodeNextUnpacked (decodeBool) (Builder.set_field12) (decodeNextField) obj buff remaining
        | 17 => decodeNextUnpacked (decodeBool) (Builder.set_field17) (decodeNextField) obj buff remaining
        | 13 => decodeNextUnpacked (decodeBool) (Builder.set_field13) (decodeNextField) obj buff remaining
        | 14 => decodeNextUnpacked (decodeBool) (Builder.set_field14) (decodeNextField) obj buff remaining
        | 104 => decodeNextUnpacked (decodeInt32) (Builder.set_field104) (decodeNextField) obj buff remaining
        | 100 => decodeNextUnpacked (decodeInt32) (Builder.set_field100) (decodeNextField) obj buff remaining
        | 101 => decodeNextUnpacked (decodeInt32) (Builder.set_field101) (decodeNextField) obj buff remaining
        | 102 => decodeNextUnpacked (decodeString) (Builder.set_field102) (decodeNextField) obj buff remaining
        | 103 => decodeNextUnpacked (decodeString) (Builder.set_field103) (decodeNextField) obj buff remaining
        | 29 => decodeNextUnpacked (decodeInt32) (Builder.set_field29) (decodeNextField) obj buff remaining
        | 30 => decodeNextUnpacked (decodeBool) (Builder.set_field30) (decodeNextField) obj buff remaining
        | 60 => decodeNextUnpacked (decodeInt32) (Builder.set_field60) (decodeNextField) obj buff remaining
        | 271 => decodeNextUnpacked (decodeInt32) (Builder.set_field271) (decodeNextField) obj buff remaining
        | 272 => decodeNextUnpacked (decodeInt32) (Builder.set_field272) (decodeNextField) obj buff remaining
        | 150 => decodeNextUnpacked (decodeInt32) (Builder.set_field150) (decodeNextField) obj buff remaining
        | 23 => decodeNextUnpacked (decodeInt32) (Builder.set_field23) (decodeNextField) obj buff remaining
        | 24 => decodeNextUnpacked (decodeBool) (Builder.set_field24) (decodeNextField) obj buff remaining
        | 25 => decodeNextUnpacked (decodeInt32) (Builder.set_field25) (decodeNextField) obj buff remaining
        | 15 => decodeNextUnpacked (SizeMessage1SubMessage.decode) (Builder.set_field15) (decodeNextField) obj buff remaining
        | 78 => decodeNextUnpacked (decodeBool) (Builder.set_field78) (decodeNextField) obj buff remaining
        | 67 => decodeNextUnpacked (decodeInt32) (Builder.set_field67) (decodeNextField) obj buff remaining
        | 68 => decodeNextUnpacked (decodeInt32) (Builder.set_field68) (decodeNextField) obj buff remaining
        | 128 => decodeNextUnpacked (decodeInt32) (Builder.set_field128) (decodeNextField) obj buff remaining
        | 129 => decodeNextUnpacked (decodeString) (Builder.set_field129) (decodeNextField) obj buff remaining
        | 131 => decodeNextUnpacked (decodeInt32) (Builder.set_field131) (decodeNextField) obj buff remaining
        | n => raise Exception(DECODE, "Unknown field tag")
      end

  fun decode buff = decodeFullHelper decodeNextField (Builder.build) (Builder.init ()) buff

end
type sizeMessage1 = SizeMessage1.t

signature SIZEMESSAGE2 =
sig
  type t
  structure Builder : sig
    type t
    type parentType

    val clear_field1: t -> t
    val set_field1: t * string -> t

    val clear_field3: t -> t
    val set_field3: t * int -> t

    val clear_field4: t -> t
    val set_field4: t * int -> t

    val clear_field30: t -> t
    val set_field30: t * int -> t

    val clear_field75: t -> t
    val set_field75: t * bool -> t

    val clear_field6: t -> t
    val set_field6: t * string -> t

    val clear_field2: t -> t
    val set_field2: t * Word8Vector.vector -> t

    val clear_field21: t -> t
    val set_field21: t * int -> t

    val clear_field71: t -> t
    val set_field71: t * int -> t

    val clear_field25: t -> t
    val set_field25: t * real -> t

    val clear_field109: t -> t
    val set_field109: t * int -> t

    val clear_field210: t -> t
    val set_field210: t * int -> t

    val clear_field211: t -> t
    val set_field211: t * int -> t

    val clear_field212: t -> t
    val set_field212: t * int -> t

    val clear_field213: t -> t
    val set_field213: t * int -> t

    val clear_field216: t -> t
    val set_field216: t * int -> t

    val clear_field217: t -> t
    val set_field217: t * int -> t

    val clear_field218: t -> t
    val set_field218: t * int -> t

    val clear_field220: t -> t
    val set_field220: t * int -> t

    val clear_field221: t -> t
    val set_field221: t * int -> t

    val clear_field222: t -> t
    val set_field222: t * real -> t

    val clear_field63: t -> t
    val set_field63: t * int -> t

    val clear_field128: t -> t
    val set_field128: t * string list -> t
    val merge_field128: t * string list -> t
    val add_field128: t * string -> t

    val clear_field131: t -> t
    val set_field131: t * int -> t

    val clear_field127: t -> t
    val set_field127: t * string list -> t
    val merge_field127: t * string list -> t
    val add_field127: t * string -> t

    val clear_field129: t -> t
    val set_field129: t * int -> t

    val clear_field130: t -> t
    val set_field130: t * int list -> t
    val merge_field130: t * int list -> t
    val add_field130: t * int -> t

    val clear_field205: t -> t
    val set_field205: t * bool -> t

    val clear_field206: t -> t
    val set_field206: t * bool -> t

    val init : unit -> t

    val build : t -> parentType
  end where type parentType = t
  val encode : t -> Word8Vector.vector
  val decode : ByteInputStream.stream -> t * parseResult
end

structure SizeMessage2 : SIZEMESSAGE2 = 
struct
  type t = {
    field1: string option,
    field3: int option,
    field4: int option,
    field30: int option,
    field75: bool option,
    field6: string option,
    field2: Word8Vector.vector option,
    field21: int option,
    field71: int option,
    field25: real option,
    field109: int option,
    field210: int option,
    field211: int option,
    field212: int option,
    field213: int option,
    field216: int option,
    field217: int option,
    field218: int option,
    field220: int option,
    field221: int option,
    field222: real option,
    field63: int option,
    field128: string list,
    field131: int option,
    field127: string list,
    field129: int option,
    field130: int list,
    field205: bool option,
    field206: bool option
  }
  structure Builder = 
  struct
    type parentType = t
    type t = {
      field1: string option ref,
      field3: int option ref,
      field4: int option ref,
      field30: int option ref,
      field75: bool option ref,
      field6: string option ref,
      field2: Word8Vector.vector option ref,
      field21: int option ref,
      field71: int option ref,
      field25: real option ref,
      field109: int option ref,
      field210: int option ref,
      field211: int option ref,
      field212: int option ref,
      field213: int option ref,
      field216: int option ref,
      field217: int option ref,
      field218: int option ref,
      field220: int option ref,
      field221: int option ref,
      field222: real option ref,
      field63: int option ref,
      field128: string list option ref,
      field131: int option ref,
      field127: string list option ref,
      field129: int option ref,
      field130: int list option ref,
      field205: bool option ref,
      field206: bool option ref
    }

    fun clear_field1 msg = 
    ((#field1 msg) := NONE; msg)
    fun set_field1 (msg, l) = 
    ((#field1 msg) := SOME(l); msg)

    fun clear_field3 msg = 
    ((#field3 msg) := NONE; msg)
    fun set_field3 (msg, l) = 
    ((#field3 msg) := SOME(l); msg)

    fun clear_field4 msg = 
    ((#field4 msg) := NONE; msg)
    fun set_field4 (msg, l) = 
    ((#field4 msg) := SOME(l); msg)

    fun clear_field30 msg = 
    ((#field30 msg) := NONE; msg)
    fun set_field30 (msg, l) = 
    ((#field30 msg) := SOME(l); msg)

    fun clear_field75 msg = 
    ((#field75 msg) := NONE; msg)
    fun set_field75 (msg, l) = 
    ((#field75 msg) := SOME(l); msg)

    fun clear_field6 msg = 
    ((#field6 msg) := NONE; msg)
    fun set_field6 (msg, l) = 
    ((#field6 msg) := SOME(l); msg)

    fun clear_field2 msg = 
    ((#field2 msg) := NONE; msg)
    fun set_field2 (msg, l) = 
    ((#field2 msg) := SOME(l); msg)

    fun clear_field21 msg = 
    ((#field21 msg) := NONE; msg)
    fun set_field21 (msg, l) = 
    ((#field21 msg) := SOME(l); msg)

    fun clear_field71 msg = 
    ((#field71 msg) := NONE; msg)
    fun set_field71 (msg, l) = 
    ((#field71 msg) := SOME(l); msg)

    fun clear_field25 msg = 
    ((#field25 msg) := NONE; msg)
    fun set_field25 (msg, l) = 
    ((#field25 msg) := SOME(l); msg)

    fun clear_field109 msg = 
    ((#field109 msg) := NONE; msg)
    fun set_field109 (msg, l) = 
    ((#field109 msg) := SOME(l); msg)

    fun clear_field210 msg = 
    ((#field210 msg) := NONE; msg)
    fun set_field210 (msg, l) = 
    ((#field210 msg) := SOME(l); msg)

    fun clear_field211 msg = 
    ((#field211 msg) := NONE; msg)
    fun set_field211 (msg, l) = 
    ((#field211 msg) := SOME(l); msg)

    fun clear_field212 msg = 
    ((#field212 msg) := NONE; msg)
    fun set_field212 (msg, l) = 
    ((#field212 msg) := SOME(l); msg)

    fun clear_field213 msg = 
    ((#field213 msg) := NONE; msg)
    fun set_field213 (msg, l) = 
    ((#field213 msg) := SOME(l); msg)

    fun clear_field216 msg = 
    ((#field216 msg) := NONE; msg)
    fun set_field216 (msg, l) = 
    ((#field216 msg) := SOME(l); msg)

    fun clear_field217 msg = 
    ((#field217 msg) := NONE; msg)
    fun set_field217 (msg, l) = 
    ((#field217 msg) := SOME(l); msg)

    fun clear_field218 msg = 
    ((#field218 msg) := NONE; msg)
    fun set_field218 (msg, l) = 
    ((#field218 msg) := SOME(l); msg)

    fun clear_field220 msg = 
    ((#field220 msg) := NONE; msg)
    fun set_field220 (msg, l) = 
    ((#field220 msg) := SOME(l); msg)

    fun clear_field221 msg = 
    ((#field221 msg) := NONE; msg)
    fun set_field221 (msg, l) = 
    ((#field221 msg) := SOME(l); msg)

    fun clear_field222 msg = 
    ((#field222 msg) := NONE; msg)
    fun set_field222 (msg, l) = 
    ((#field222 msg) := SOME(l); msg)

    fun clear_field63 msg = 
    ((#field63 msg) := NONE; msg)
    fun set_field63 (msg, l) = 
    ((#field63 msg) := SOME(l); msg)

    fun clear_field128 msg = 
    ((#field128 msg) := NONE; msg)
    fun set_field128 (msg, l) = 
    ((#field128 msg) := SOME(l); msg)
    fun add_field128 (msg, v) = 
      ((case (!(#field128 msg)) of NONE => (#field128 msg) := SOME([v])
      | SOME(l) => (#field128 msg) := SOME(v :: l)); msg)
    fun merge_field128 (msg, l) = 
      ((case (!(#field128 msg)) of NONE => (#field128 msg) := SOME(l)
      | SOME(ll) => (#field128 msg) := SOME(List.concat [ll, l])); msg)

    fun clear_field131 msg = 
    ((#field131 msg) := NONE; msg)
    fun set_field131 (msg, l) = 
    ((#field131 msg) := SOME(l); msg)

    fun clear_field127 msg = 
    ((#field127 msg) := NONE; msg)
    fun set_field127 (msg, l) = 
    ((#field127 msg) := SOME(l); msg)
    fun add_field127 (msg, v) = 
      ((case (!(#field127 msg)) of NONE => (#field127 msg) := SOME([v])
      | SOME(l) => (#field127 msg) := SOME(v :: l)); msg)
    fun merge_field127 (msg, l) = 
      ((case (!(#field127 msg)) of NONE => (#field127 msg) := SOME(l)
      | SOME(ll) => (#field127 msg) := SOME(List.concat [ll, l])); msg)

    fun clear_field129 msg = 
    ((#field129 msg) := NONE; msg)
    fun set_field129 (msg, l) = 
    ((#field129 msg) := SOME(l); msg)

    fun clear_field130 msg = 
    ((#field130 msg) := NONE; msg)
    fun set_field130 (msg, l) = 
    ((#field130 msg) := SOME(l); msg)
    fun add_field130 (msg, v) = 
      ((case (!(#field130 msg)) of NONE => (#field130 msg) := SOME([v])
      | SOME(l) => (#field130 msg) := SOME(v :: l)); msg)
    fun merge_field130 (msg, l) = 
      ((case (!(#field130 msg)) of NONE => (#field130 msg) := SOME(l)
      | SOME(ll) => (#field130 msg) := SOME(List.concat [ll, l])); msg)

    fun clear_field205 msg = 
    ((#field205 msg) := NONE; msg)
    fun set_field205 (msg, l) = 
    ((#field205 msg) := SOME(l); msg)

    fun clear_field206 msg = 
    ((#field206 msg) := NONE; msg)
    fun set_field206 (msg, l) = 
    ((#field206 msg) := SOME(l); msg)

    fun init () = { field1 = ref NONE,
      field3 = ref NONE,
      field4 = ref NONE,
      field30 = ref NONE,
      field75 = ref NONE,
      field6 = ref NONE,
      field2 = ref NONE,
      field21 = ref NONE,
      field71 = ref NONE,
      field25 = ref NONE,
      field109 = ref NONE,
      field210 = ref NONE,
      field211 = ref NONE,
      field212 = ref NONE,
      field213 = ref NONE,
      field216 = ref NONE,
      field217 = ref NONE,
      field218 = ref NONE,
      field220 = ref NONE,
      field221 = ref NONE,
      field222 = ref NONE,
      field63 = ref NONE,
      field128 = ref NONE,
      field131 = ref NONE,
      field127 = ref NONE,
      field129 = ref NONE,
      field130 = ref NONE,
      field205 = ref NONE,
      field206 = ref NONE
    }

    fun build msg = 
    let
      val field1Val = (!(#field1 msg))
      val field3Val = (!(#field3 msg))
      val field4Val = (!(#field4 msg))
      val field30Val = (!(#field30 msg))
      val field75Val = (!(#field75 msg))
      val field6Val = (!(#field6 msg))
      val field2Val = (!(#field2 msg))
      val field21Val = (!(#field21 msg))
      val field71Val = (!(#field71 msg))
      val field25Val = (!(#field25 msg))
      val field109Val = (!(#field109 msg))
      val field210Val = (!(#field210 msg))
      val field211Val = (!(#field211 msg))
      val field212Val = (!(#field212 msg))
      val field213Val = (!(#field213 msg))
      val field216Val = (!(#field216 msg))
      val field217Val = (!(#field217 msg))
      val field218Val = (!(#field218 msg))
      val field220Val = (!(#field220 msg))
      val field221Val = (!(#field221 msg))
      val field222Val = (!(#field222 msg))
      val field63Val = (!(#field63 msg))
      val field128Val = case (!(#field128 msg)) of NONE => [] | SOME(v) => v
      val field131Val = (!(#field131 msg))
      val field127Val = case (!(#field127 msg)) of NONE => [] | SOME(v) => v
      val field129Val = (!(#field129 msg))
      val field130Val = case (!(#field130 msg)) of NONE => [] | SOME(v) => v
      val field205Val = (!(#field205 msg))
      val field206Val = (!(#field206 msg))
    in { 
      field1 = field1Val,
      field3 = field3Val,
      field4 = field4Val,
      field30 = field30Val,
      field75 = field75Val,
      field6 = field6Val,
      field2 = field2Val,
      field21 = field21Val,
      field71 = field71Val,
      field25 = field25Val,
      field109 = field109Val,
      field210 = field210Val,
      field211 = field211Val,
      field212 = field212Val,
      field213 = field213Val,
      field216 = field216Val,
      field217 = field217Val,
      field218 = field218Val,
      field220 = field220Val,
      field221 = field221Val,
      field222 = field222Val,
      field63 = field63Val,
      field128 = field128Val,
      field131 = field131Val,
      field127 = field127Val,
      field129 = field129Val,
      field130 = field130Val,
      field205 = field205Val,
      field206 = field206Val
    }
    end
  end
  fun encode m = 
    let
      val field1 = (encodeOptional encodeString) (encodeKey(Tag(1), Code(2))) (#field1 m)
      val field3 = (encodeOptional encodeInt64) (encodeKey(Tag(3), Code(0))) (#field3 m)
      val field4 = (encodeOptional encodeInt64) (encodeKey(Tag(4), Code(0))) (#field4 m)
      val field30 = (encodeOptional encodeInt64) (encodeKey(Tag(30), Code(0))) (#field30 m)
      val field75 = (encodeOptional encodeBool) (encodeKey(Tag(75), Code(0))) (#field75 m)
      val field6 = (encodeOptional encodeString) (encodeKey(Tag(6), Code(2))) (#field6 m)
      val field2 = (encodeOptional encodeBytes) (encodeKey(Tag(2), Code(2))) (#field2 m)
      val field21 = (encodeOptional encodeInt32) (encodeKey(Tag(21), Code(0))) (#field21 m)
      val field71 = (encodeOptional encodeInt32) (encodeKey(Tag(71), Code(0))) (#field71 m)
      val field25 = (encodeOptional encodeFloat) (encodeKey(Tag(25), Code(5))) (#field25 m)
      val field109 = (encodeOptional encodeInt32) (encodeKey(Tag(109), Code(0))) (#field109 m)
      val field210 = (encodeOptional encodeInt32) (encodeKey(Tag(210), Code(0))) (#field210 m)
      val field211 = (encodeOptional encodeInt32) (encodeKey(Tag(211), Code(0))) (#field211 m)
      val field212 = (encodeOptional encodeInt32) (encodeKey(Tag(212), Code(0))) (#field212 m)
      val field213 = (encodeOptional encodeInt32) (encodeKey(Tag(213), Code(0))) (#field213 m)
      val field216 = (encodeOptional encodeInt32) (encodeKey(Tag(216), Code(0))) (#field216 m)
      val field217 = (encodeOptional encodeInt32) (encodeKey(Tag(217), Code(0))) (#field217 m)
      val field218 = (encodeOptional encodeInt32) (encodeKey(Tag(218), Code(0))) (#field218 m)
      val field220 = (encodeOptional encodeInt32) (encodeKey(Tag(220), Code(0))) (#field220 m)
      val field221 = (encodeOptional encodeInt32) (encodeKey(Tag(221), Code(0))) (#field221 m)
      val field222 = (encodeOptional encodeFloat) (encodeKey(Tag(222), Code(5))) (#field222 m)
      val field63 = (encodeOptional encodeInt32) (encodeKey(Tag(63), Code(0))) (#field63 m)
      val field128 = (encodeRepeated encodeString) (encodeKey(Tag(128), Code(2))) (#field128 m)
      val field131 = (encodeOptional encodeInt64) (encodeKey(Tag(131), Code(0))) (#field131 m)
      val field127 = (encodeRepeated encodeString) (encodeKey(Tag(127), Code(2))) (#field127 m)
      val field129 = (encodeOptional encodeInt32) (encodeKey(Tag(129), Code(0))) (#field129 m)
      val field130 = (encodePackedRepeated encodeInt64) (encodeKey(Tag(130), Code(2))) (#field130 m)
      val field205 = (encodeOptional encodeBool) (encodeKey(Tag(205), Code(0))) (#field205 m)
      val field206 = (encodeOptional encodeBool) (encodeKey(Tag(206), Code(0))) (#field206 m)
    in
      encodeMessage (Word8Vector.concat [
        field1,
        field3,
        field4,
        field30,
        field75,
        field6,
        field2,
        field21,
        field71,
        field25,
        field109,
        field210,
        field211,
        field212,
        field213,
        field216,
        field217,
        field218,
        field220,
        field221,
        field222,
        field63,
        field128,
        field131,
        field127,
        field129,
        field130,
        field205,
        field206
      ])
    end

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
        else case (t) of 1 => decodeNextUnpacked (decodeString) (Builder.set_field1) (decodeNextField) obj buff remaining
        | 3 => decodeNextUnpacked (decodeInt64) (Builder.set_field3) (decodeNextField) obj buff remaining
        | 4 => decodeNextUnpacked (decodeInt64) (Builder.set_field4) (decodeNextField) obj buff remaining
        | 30 => decodeNextUnpacked (decodeInt64) (Builder.set_field30) (decodeNextField) obj buff remaining
        | 75 => decodeNextUnpacked (decodeBool) (Builder.set_field75) (decodeNextField) obj buff remaining
        | 6 => decodeNextUnpacked (decodeString) (Builder.set_field6) (decodeNextField) obj buff remaining
        | 2 => decodeNextUnpacked (decodeBytes) (Builder.set_field2) (decodeNextField) obj buff remaining
        | 21 => decodeNextUnpacked (decodeInt32) (Builder.set_field21) (decodeNextField) obj buff remaining
        | 71 => decodeNextUnpacked (decodeInt32) (Builder.set_field71) (decodeNextField) obj buff remaining
        | 25 => decodeNextUnpacked (decodeFloat) (Builder.set_field25) (decodeNextField) obj buff remaining
        | 109 => decodeNextUnpacked (decodeInt32) (Builder.set_field109) (decodeNextField) obj buff remaining
        | 210 => decodeNextUnpacked (decodeInt32) (Builder.set_field210) (decodeNextField) obj buff remaining
        | 211 => decodeNextUnpacked (decodeInt32) (Builder.set_field211) (decodeNextField) obj buff remaining
        | 212 => decodeNextUnpacked (decodeInt32) (Builder.set_field212) (decodeNextField) obj buff remaining
        | 213 => decodeNextUnpacked (decodeInt32) (Builder.set_field213) (decodeNextField) obj buff remaining
        | 216 => decodeNextUnpacked (decodeInt32) (Builder.set_field216) (decodeNextField) obj buff remaining
        | 217 => decodeNextUnpacked (decodeInt32) (Builder.set_field217) (decodeNextField) obj buff remaining
        | 218 => decodeNextUnpacked (decodeInt32) (Builder.set_field218) (decodeNextField) obj buff remaining
        | 220 => decodeNextUnpacked (decodeInt32) (Builder.set_field220) (decodeNextField) obj buff remaining
        | 221 => decodeNextUnpacked (decodeInt32) (Builder.set_field221) (decodeNextField) obj buff remaining
        | 222 => decodeNextUnpacked (decodeFloat) (Builder.set_field222) (decodeNextField) obj buff remaining
        | 63 => decodeNextUnpacked (decodeInt32) (Builder.set_field63) (decodeNextField) obj buff remaining
        | 128 => decodeNextUnpacked (decodeString) (Builder.add_field128) (decodeNextField) obj buff remaining
        | 131 => decodeNextUnpacked (decodeInt64) (Builder.set_field131) (decodeNextField) obj buff remaining
        | 127 => decodeNextUnpacked (decodeString) (Builder.add_field127) (decodeNextField) obj buff remaining
        | 129 => decodeNextUnpacked (decodeInt32) (Builder.set_field129) (decodeNextField) obj buff remaining
        | 130 => if (c = 2) then (decodeNextPacked (decodeInt64) (Builder.add_field130) (decodeNextField) obj buff remaining)
        else (decodeNextUnpacked (decodeInt64) (Builder.add_field130) (decodeNextField) obj buff remaining)

        | 205 => decodeNextUnpacked (decodeBool) (Builder.set_field205) (decodeNextField) obj buff remaining
        | 206 => decodeNextUnpacked (decodeBool) (Builder.set_field206) (decodeNextField) obj buff remaining
        | n => raise Exception(DECODE, "Unknown field tag")
      end

  fun decode buff = decodeFullHelper decodeNextField (Builder.build) (Builder.init ()) buff

end
type sizeMessage2 = SizeMessage2.t

signature SIZEMESSAGE2GROUPEDMESSAGE =
sig
  type t
  structure Builder : sig
    type t
    type parentType

    val clear_field1: t -> t
    val set_field1: t * real -> t

    val clear_field2: t -> t
    val set_field2: t * real -> t

    val clear_field3: t -> t
    val set_field3: t * real -> t

    val clear_field4: t -> t
    val set_field4: t * bool -> t

    val clear_field5: t -> t
    val set_field5: t * bool -> t

    val clear_field6: t -> t
    val set_field6: t * bool -> t

    val clear_field7: t -> t
    val set_field7: t * bool -> t

    val clear_field8: t -> t
    val set_field8: t * real -> t

    val clear_field9: t -> t
    val set_field9: t * bool -> t

    val clear_field10: t -> t
    val set_field10: t * real -> t

    val clear_field11: t -> t
    val set_field11: t * int -> t

    val init : unit -> t

    val build : t -> parentType
  end where type parentType = t
  val encode : t -> Word8Vector.vector
  val decode : ByteInputStream.stream -> t * parseResult
end

structure SizeMessage2GroupedMessage : SIZEMESSAGE2GROUPEDMESSAGE = 
struct
  type t = {
    field1: real option,
    field2: real option,
    field3: real option,
    field4: bool option,
    field5: bool option,
    field6: bool option,
    field7: bool option,
    field8: real option,
    field9: bool option,
    field10: real option,
    field11: int option
  }
  structure Builder = 
  struct
    type parentType = t
    type t = {
      field1: real option ref,
      field2: real option ref,
      field3: real option ref,
      field4: bool option ref,
      field5: bool option ref,
      field6: bool option ref,
      field7: bool option ref,
      field8: real option ref,
      field9: bool option ref,
      field10: real option ref,
      field11: int option ref
    }

    fun clear_field1 msg = 
    ((#field1 msg) := NONE; msg)
    fun set_field1 (msg, l) = 
    ((#field1 msg) := SOME(l); msg)

    fun clear_field2 msg = 
    ((#field2 msg) := NONE; msg)
    fun set_field2 (msg, l) = 
    ((#field2 msg) := SOME(l); msg)

    fun clear_field3 msg = 
    ((#field3 msg) := NONE; msg)
    fun set_field3 (msg, l) = 
    ((#field3 msg) := SOME(l); msg)

    fun clear_field4 msg = 
    ((#field4 msg) := NONE; msg)
    fun set_field4 (msg, l) = 
    ((#field4 msg) := SOME(l); msg)

    fun clear_field5 msg = 
    ((#field5 msg) := NONE; msg)
    fun set_field5 (msg, l) = 
    ((#field5 msg) := SOME(l); msg)

    fun clear_field6 msg = 
    ((#field6 msg) := NONE; msg)
    fun set_field6 (msg, l) = 
    ((#field6 msg) := SOME(l); msg)

    fun clear_field7 msg = 
    ((#field7 msg) := NONE; msg)
    fun set_field7 (msg, l) = 
    ((#field7 msg) := SOME(l); msg)

    fun clear_field8 msg = 
    ((#field8 msg) := NONE; msg)
    fun set_field8 (msg, l) = 
    ((#field8 msg) := SOME(l); msg)

    fun clear_field9 msg = 
    ((#field9 msg) := NONE; msg)
    fun set_field9 (msg, l) = 
    ((#field9 msg) := SOME(l); msg)

    fun clear_field10 msg = 
    ((#field10 msg) := NONE; msg)
    fun set_field10 (msg, l) = 
    ((#field10 msg) := SOME(l); msg)

    fun clear_field11 msg = 
    ((#field11 msg) := NONE; msg)
    fun set_field11 (msg, l) = 
    ((#field11 msg) := SOME(l); msg)

    fun init () = { field1 = ref NONE,
      field2 = ref NONE,
      field3 = ref NONE,
      field4 = ref NONE,
      field5 = ref NONE,
      field6 = ref NONE,
      field7 = ref NONE,
      field8 = ref NONE,
      field9 = ref NONE,
      field10 = ref NONE,
      field11 = ref NONE
    }

    fun build msg = 
    let
      val field1Val = (!(#field1 msg))
      val field2Val = (!(#field2 msg))
      val field3Val = (!(#field3 msg))
      val field4Val = (!(#field4 msg))
      val field5Val = (!(#field5 msg))
      val field6Val = (!(#field6 msg))
      val field7Val = (!(#field7 msg))
      val field8Val = (!(#field8 msg))
      val field9Val = (!(#field9 msg))
      val field10Val = (!(#field10 msg))
      val field11Val = (!(#field11 msg))
    in { 
      field1 = field1Val,
      field2 = field2Val,
      field3 = field3Val,
      field4 = field4Val,
      field5 = field5Val,
      field6 = field6Val,
      field7 = field7Val,
      field8 = field8Val,
      field9 = field9Val,
      field10 = field10Val,
      field11 = field11Val
    }
    end
  end
  fun encode m = 
    let
      val field1 = (encodeOptional encodeFloat) (encodeKey(Tag(1), Code(5))) (#field1 m)
      val field2 = (encodeOptional encodeFloat) (encodeKey(Tag(2), Code(5))) (#field2 m)
      val field3 = (encodeOptional encodeFloat) (encodeKey(Tag(3), Code(5))) (#field3 m)
      val field4 = (encodeOptional encodeBool) (encodeKey(Tag(4), Code(0))) (#field4 m)
      val field5 = (encodeOptional encodeBool) (encodeKey(Tag(5), Code(0))) (#field5 m)
      val field6 = (encodeOptional encodeBool) (encodeKey(Tag(6), Code(0))) (#field6 m)
      val field7 = (encodeOptional encodeBool) (encodeKey(Tag(7), Code(0))) (#field7 m)
      val field8 = (encodeOptional encodeFloat) (encodeKey(Tag(8), Code(5))) (#field8 m)
      val field9 = (encodeOptional encodeBool) (encodeKey(Tag(9), Code(0))) (#field9 m)
      val field10 = (encodeOptional encodeFloat) (encodeKey(Tag(10), Code(5))) (#field10 m)
      val field11 = (encodeOptional encodeInt64) (encodeKey(Tag(11), Code(0))) (#field11 m)
    in
      encodeMessage (Word8Vector.concat [
        field1,
        field2,
        field3,
        field4,
        field5,
        field6,
        field7,
        field8,
        field9,
        field10,
        field11
      ])
    end

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
        else case (t) of 1 => decodeNextUnpacked (decodeFloat) (Builder.set_field1) (decodeNextField) obj buff remaining
        | 2 => decodeNextUnpacked (decodeFloat) (Builder.set_field2) (decodeNextField) obj buff remaining
        | 3 => decodeNextUnpacked (decodeFloat) (Builder.set_field3) (decodeNextField) obj buff remaining
        | 4 => decodeNextUnpacked (decodeBool) (Builder.set_field4) (decodeNextField) obj buff remaining
        | 5 => decodeNextUnpacked (decodeBool) (Builder.set_field5) (decodeNextField) obj buff remaining
        | 6 => decodeNextUnpacked (decodeBool) (Builder.set_field6) (decodeNextField) obj buff remaining
        | 7 => decodeNextUnpacked (decodeBool) (Builder.set_field7) (decodeNextField) obj buff remaining
        | 8 => decodeNextUnpacked (decodeFloat) (Builder.set_field8) (decodeNextField) obj buff remaining
        | 9 => decodeNextUnpacked (decodeBool) (Builder.set_field9) (decodeNextField) obj buff remaining
        | 10 => decodeNextUnpacked (decodeFloat) (Builder.set_field10) (decodeNextField) obj buff remaining
        | 11 => decodeNextUnpacked (decodeInt64) (Builder.set_field11) (decodeNextField) obj buff remaining
        | n => raise Exception(DECODE, "Unknown field tag")
      end

  fun decode buff = decodeFullHelper decodeNextField (Builder.build) (Builder.init ()) buff

end
type sizeMessage2GroupedMessage = SizeMessage2GroupedMessage.t

