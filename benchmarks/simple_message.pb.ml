use "MlGenLib.ml";

signature SIMPLEMESSAGE =
sig
  type t
  structure Builder : sig
    type t
    type parentType

    val clear_id: t -> t
    val set_id: t * int -> t

    val clear_name: t -> t
    val set_name: t * string -> t

    val clear_phone_number: t -> t
    val set_phone_number: t * string list -> t
    val merge_phone_number: t * string list -> t
    val add_phone_number: t * string -> t

    val init : unit -> t

    val build : t -> parentType
  end where type parentType = t
  val encode : t -> Word8Vector.vector
  val encodeToplevel : t -> Word8Vector.vector
  val decode : ByteInputStream.stream -> t * parseResult
  val decodeToplevel : ByteInputStream.stream -> t * parseResult
end

structure SimpleMessage : SIMPLEMESSAGE = 
struct
  type t = {
    id: int ,
    name: string option,
    phone_number: string list
  }
  structure Builder = 
  struct
    type parentType = t
    type t = {
      id: int option ref,
      name: string option ref,
      phone_number: string list option ref
    }

    fun clear_id msg = 
    ((#id msg) := NONE; msg)
    fun set_id (msg, l) = 
    ((#id msg) := SOME(l); msg)

    fun clear_name msg = 
    ((#name msg) := NONE; msg)
    fun set_name (msg, l) = 
    ((#name msg) := SOME(l); msg)

    fun clear_phone_number msg = 
    ((#phone_number msg) := NONE; msg)
    fun set_phone_number (msg, l) = 
    ((#phone_number msg) := SOME(l); msg)
    fun add_phone_number (msg, v) = 
      ((case (!(#phone_number msg)) of NONE => (#phone_number msg) := SOME([v])
      | SOME(l) => (#phone_number msg) := SOME(v :: l)); msg)
    fun merge_phone_number (msg, l) = 
      ((case (!(#phone_number msg)) of NONE => (#phone_number msg) := SOME(l)
      | SOME(ll) => (#phone_number msg) := SOME(List.concat [ll, l])); msg)

    fun init () = { id = ref NONE,
      name = ref NONE,
      phone_number = ref NONE
    }

    fun build msg = 
    let
      val idVal = case (!(#id msg)) of NONE => raise Exception(BUILD, "Required field missing.") | SOME(v) => v
      val nameVal = (!(#name msg))
      val phone_numberVal = case (!(#phone_number msg)) of NONE => [] | SOME(v) => v
    in { 
      id = idVal,
      name = nameVal,
      phone_number = phone_numberVal
    }
    end
  end
  fun encodeToplevel m = 
    let
      val id = (encodeRequired encodeInt32) (encodeKey(Tag(1), Code(0))) (#id m)
      val name = (encodeOptional encodeString) (encodeKey(Tag(2), Code(2))) (#name m)
      val phone_number = (encodeRepeated encodeString) (encodeKey(Tag(3), Code(2))) (#phone_number m)
    in
      Word8Vector.concat [
        id,
        name,
        phone_number
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
        else case (t) of 1 => decodeNextUnpacked (decodeInt32) (Builder.set_id) (decodeNextField) obj buff remaining
        | 2 => decodeNextUnpacked (decodeString) (Builder.set_name) (decodeNextField) obj buff remaining
        | 3 => decodeNextUnpacked (decodeString) (Builder.add_phone_number) (decodeNextField) obj buff remaining
        | n => raise Exception(DECODE, "Unknown field tag")
      end

  fun decode buff = decodeFullHelper false decodeNextField (Builder.build) (Builder.init ()) buff

  fun decodeToplevel buff = decodeFullHelper true decodeNextField (Builder.build) (Builder.init ()) buff

end
type simpleMessage = SimpleMessage.t

