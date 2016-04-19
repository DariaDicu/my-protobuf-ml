use "MlGenLib.ml";

signature M3 =
sig
  type t
  structure Builder : sig
    type t
    type parentType

    val init : unit -> t

    val build : t -> parentType
  end where type parentType = t
  val encode : t -> Word8Vector.vector
  val decode : ByteInputStream.stream -> t * parseResult
end

structure M3 : M3 = 
struct
  type t = {
  }
  structure Builder = 
  struct
    type parentType = t
    type t = {
    }

    fun init () = { }

    fun build msg = 
    let
    in { 
    }
    end
  end
  fun encode m = 
    let
    in
      encodeMessage (Word8Vector.concat [

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
        else case (t) of 
        | n => raise Exception(DECODE, "Unknown field tag")
      end

  fun decode buff = decodeFullHelper decodeNextField (Builder.build) (Builder.init ()) buff

end
type m3 = M3.t

signature M4 =
sig
  type t
  structure Builder : sig
    type t
    type parentType

    val clear_message3: t -> t
    val set_message3: t * M3.t -> t

    val init : unit -> t

    val build : t -> parentType
  end where type parentType = t
  val encode : t -> Word8Vector.vector
  val decode : ByteInputStream.stream -> t * parseResult
end

structure M4 : M4 = 
struct
  type t = {
    message3: m3 option
  }
  structure Builder = 
  struct
    type parentType = t
    type t = {
      message3: m3 option ref
    }

    fun clear_message3 msg = 
    ((#message3 msg) := NONE; msg)
    fun set_message3 (msg, l) = 
    ((#message3 msg) := SOME(l); msg)

    fun init () = { message3 = ref NONE
    }

    fun build msg = 
    let
      val message3Val = (!(#message3 msg))
    in { 
      message3 = message3Val
    }
    end
  end
  fun encode m = 
    let
      val message3 = (encodeOptional M3.encode) (encodeKey(Tag(1), Code(2))) (#message3 m)
    in
      encodeMessage (Word8Vector.concat [
        message3
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
        else case (t) of 1 => decodeNextUnpacked (M3.decode) (Builder.set_message3) (decodeNextField) obj buff remaining
        | n => raise Exception(DECODE, "Unknown field tag")
      end

  fun decode buff = decodeFullHelper decodeNextField (Builder.build) (Builder.init ()) buff

end
type m4 = M4.t

signature M1 =
sig
  structure M1 : sig
    type t
    structure Builder : sig
      type t
      type parentType

      val clear_message3: t -> t
      val set_message3: t * M3.t -> t

      val init : unit -> t

      val build : t -> parentType
    end where type parentType = t
    val encode : t -> Word8Vector.vector
    val decode : ByteInputStream.stream -> t * parseResult
  end
  type m1
  structure M2 : sig
    type t
    structure Builder : sig
      type t
      type parentType

      val clear_message1: t -> t
      val set_message1: t * M1.t -> t

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

    val clear_message5: t -> t
    val set_message5: t * M4.t -> t

    val init : unit -> t

    val build : t -> parentType
  end where type parentType = t
  val encode : t -> Word8Vector.vector
  val decode : ByteInputStream.stream -> t * parseResult
end

structure M1 : M1 = 
struct
  structure M1 = 
  struct
    type t = {
      message3: m3 option
    }
    structure Builder = 
    struct
      type parentType = t
      type t = {
        message3: m3 option ref
      }

      fun clear_message3 msg = 
      ((#message3 msg) := NONE; msg)
      fun set_message3 (msg, l) = 
      ((#message3 msg) := SOME(l); msg)

      fun init () = { message3 = ref NONE
      }

      fun build msg = 
      let
        val message3Val = (!(#message3 msg))
      in { 
        message3 = message3Val
      }
      end
    end
    fun encode m = 
      let
        val message3 = (encodeOptional M3.encode) (encodeKey(Tag(1), Code(2))) (#message3 m)
      in
        encodeMessage (Word8Vector.concat [
          message3
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
          else case (t) of 1 => decodeNextUnpacked (M3.decode) (Builder.set_message3) (decodeNextField) obj buff remaining
          | n => raise Exception(DECODE, "Unknown field tag")
        end

    fun decode buff = decodeFullHelper decodeNextField (Builder.build) (Builder.init ()) buff

  end
  type m1 = M1.t
  structure M2 = 
  struct
    type t = {
      message1: m1 option
    }
    structure Builder = 
    struct
      type parentType = t
      type t = {
        message1: m1 option ref
      }

      fun clear_message1 msg = 
      ((#message1 msg) := NONE; msg)
      fun set_message1 (msg, l) = 
      ((#message1 msg) := SOME(l); msg)

      fun init () = { message1 = ref NONE
      }

      fun build msg = 
      let
        val message1Val = (!(#message1 msg))
      in { 
        message1 = message1Val
      }
      end
    end
    fun encode m = 
      let
        val message1 = (encodeOptional M1.encode) (encodeKey(Tag(1), Code(2))) (#message1 m)
      in
        encodeMessage (Word8Vector.concat [
          message1
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
          else case (t) of 1 => decodeNextUnpacked (M1.decode) (Builder.set_message1) (decodeNextField) obj buff remaining
          | n => raise Exception(DECODE, "Unknown field tag")
        end

    fun decode buff = decodeFullHelper decodeNextField (Builder.build) (Builder.init ()) buff

  end
  type m2 = M2.t
  type t = {
    message5: m4 option
  }
  structure Builder = 
  struct
    type parentType = t
    type t = {
      message5: m4 option ref
    }

    fun clear_message5 msg = 
    ((#message5 msg) := NONE; msg)
    fun set_message5 (msg, l) = 
    ((#message5 msg) := SOME(l); msg)

    fun init () = { message5 = ref NONE
    }

    fun build msg = 
    let
      val message5Val = (!(#message5 msg))
    in { 
      message5 = message5Val
    }
    end
  end
  fun encode m = 
    let
      val message5 = (encodeOptional M4.encode) (encodeKey(Tag(1), Code(2))) (#message5 m)
    in
      encodeMessage (Word8Vector.concat [
        message5
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
        else case (t) of 1 => decodeNextUnpacked (M4.decode) (Builder.set_message5) (decodeNextField) obj buff remaining
        | n => raise Exception(DECODE, "Unknown field tag")
      end

  fun decode buff = decodeFullHelper decodeNextField (Builder.build) (Builder.init ()) buff

end
type m1 = M1.t

