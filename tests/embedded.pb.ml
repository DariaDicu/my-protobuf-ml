use "MlGenLib.ml";

signature M3 =
sig
  type t
  structure Builder : sig
    type t
    type parentType

    val clear_name: t -> t
    val set_name: t * string -> t

    val init : unit -> t

    val build : t -> parentType
  end where type parentType = t
  val encode : t -> Word8Vector.vector
  val decode : ByteInputStream.stream -> t * parseResult
end

structure M3 : M3 = 
struct
  type t = {
    name: string option
  }
  structure Builder = 
  struct
    type parentType = t
    type t = {
      name: string option ref
    }

    fun clear_name msg = 
    ((#name msg) := NONE; msg)
    fun set_name (msg, l) = 
    ((#name msg) := SOME(l); msg)

    fun init () = { name = ref NONE
    }

    fun build msg = 
    let
      val nameVal = (!(#name msg))
    in { 
      name = nameVal
    }
    end
  end
  fun encode m = 
    let
      val name = (encodeOptional encodeString) (encodeKey(Tag(1), Code(2))) (#name m)
    in
      encodeMessage (Word8Vector.concat [
        name
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
        else case (t) of 1 => decodeNextUnpacked (decodeString) (Builder.set_name) (decodeNextField) obj buff remaining
        | n => raise Exception(DECODE, "Unknown field tag")
      end

  fun decode buff = decodeFullHelper decodeNextField (Builder.build) (Builder.init ()) buff

end
type m3 = M3.t

signature M1 =
sig
  structure M2 : sig
    type t
    structure Builder : sig
      type t
      type parentType

      val clear_name: t -> t
      val set_name: t * string -> t

      val clear_id: t -> t
      val set_id: t * int -> t

      val init : unit -> t

      val build : t -> parentType
    end where type parentType = t
    val encode : t -> Word8Vector.vector
    val decode : ByteInputStream.stream -> t * parseResult
  end
  type m2
  type t
  structure Builder : sig
    type t
    type parentType

    val clear_message2_1: t -> t
    val set_message2_1: t * M2.t -> t

    val clear_message2_2: t -> t
    val set_message2_2: t * M2.t -> t

    val clear_message3_list: t -> t
    val set_message3_list: t * M3.t list -> t
    val merge_message3_list: t * M3.t list -> t
    val add_message3_list: t * M3.t -> t

    val init : unit -> t

    val build : t -> parentType
  end where type parentType = t
  val encode : t -> Word8Vector.vector
  val decode : ByteInputStream.stream -> t * parseResult
end

structure M1 : M1 = 
struct
  structure M2 = 
  struct
    type t = {
      name: string option,
      id: int 
    }
    structure Builder = 
    struct
      type parentType = t
      type t = {
        name: string option ref,
        id: int option ref
      }

      fun clear_name msg = 
      ((#name msg) := NONE; msg)
      fun set_name (msg, l) = 
      ((#name msg) := SOME(l); msg)

      fun clear_id msg = 
      ((#id msg) := NONE; msg)
      fun set_id (msg, l) = 
      ((#id msg) := SOME(l); msg)

      fun init () = { name = ref NONE,
        id = ref NONE
      }

      fun build msg = 
      let
        val nameVal = (!(#name msg))
        val idVal = case (!(#id msg)) of NONE => raise Exception(BUILD, "Required field missing.") | SOME(v) => v
      in { 
        name = nameVal,
        id = idVal
      }
      end
    end
    fun encode m = 
      let
        val name = (encodeOptional encodeString) (encodeKey(Tag(1), Code(2))) (#name m)
        val id = (encodeRequired encodeInt32) (encodeKey(Tag(2), Code(0))) (#id m)
      in
        encodeMessage (Word8Vector.concat [
          name,
          id
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
          else case (t) of 1 => decodeNextUnpacked (decodeString) (Builder.set_name) (decodeNextField) obj buff remaining
          | 2 => decodeNextUnpacked (decodeInt32) (Builder.set_id) (decodeNextField) obj buff remaining
          | n => raise Exception(DECODE, "Unknown field tag")
        end

    fun decode buff = decodeFullHelper decodeNextField (Builder.build) (Builder.init ()) buff

  end
  type m2 = M2.t
  type t = {
    message2_1: m2 ,
    message2_2: m2 option,
    message3_list: m3 list
  }
  structure Builder = 
  struct
    type parentType = t
    type t = {
      message2_1: m2 option ref,
      message2_2: m2 option ref,
      message3_list: m3 list option ref
    }

    fun clear_message2_1 msg = 
    ((#message2_1 msg) := NONE; msg)
    fun set_message2_1 (msg, l) = 
    ((#message2_1 msg) := SOME(l); msg)

    fun clear_message2_2 msg = 
    ((#message2_2 msg) := NONE; msg)
    fun set_message2_2 (msg, l) = 
    ((#message2_2 msg) := SOME(l); msg)

    fun clear_message3_list msg = 
    ((#message3_list msg) := NONE; msg)
    fun set_message3_list (msg, l) = 
    ((#message3_list msg) := SOME(l); msg)
    fun add_message3_list (msg, v) = 
      ((case (!(#message3_list msg)) of NONE => (#message3_list msg) := SOME([v])
      | SOME(l) => (#message3_list msg) := SOME(v :: l)); msg)
    fun merge_message3_list (msg, l) = 
      ((case (!(#message3_list msg)) of NONE => (#message3_list msg) := SOME(l)
      | SOME(ll) => (#message3_list msg) := SOME(List.concat [ll, l])); msg)

    fun init () = { message2_1 = ref NONE,
      message2_2 = ref NONE,
      message3_list = ref NONE
    }

    fun build msg = 
    let
      val message2_1Val = case (!(#message2_1 msg)) of NONE => raise Exception(BUILD, "Required field missing.") | SOME(v) => v
      val message2_2Val = (!(#message2_2 msg))
      val message3_listVal = case (!(#message3_list msg)) of NONE => [] | SOME(v) => v
    in { 
      message2_1 = message2_1Val,
      message2_2 = message2_2Val,
      message3_list = message3_listVal
    }
    end
  end
  fun encode m = 
    let
      val message2_1 = (encodeRequired M2.encode) (encodeKey(Tag(1), Code(2))) (#message2_1 m)
      val message2_2 = (encodeOptional M2.encode) (encodeKey(Tag(2), Code(2))) (#message2_2 m)
      val message3_list = (encodeRepeated M3.encode) (encodeKey(Tag(3), Code(2))) (#message3_list m)
    in
      encodeMessage (Word8Vector.concat [
        message2_1,
        message2_2,
        message3_list
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
        else case (t) of 1 => decodeNextUnpacked (M2.decode) (Builder.set_message2_1) (decodeNextField) obj buff remaining
        | 2 => decodeNextUnpacked (M2.decode) (Builder.set_message2_2) (decodeNextField) obj buff remaining
        | 3 => decodeNextUnpacked (M3.decode) (Builder.add_message3_list) (decodeNextField) obj buff remaining
        | n => raise Exception(DECODE, "Unknown field tag")
      end

  fun decode buff = decodeFullHelper decodeNextField (Builder.build) (Builder.init ()) buff

end
type m1 = M1.t

