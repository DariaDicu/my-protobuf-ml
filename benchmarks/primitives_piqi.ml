module rec Primitives_piqi:
  sig
    type uint32 = int32
    type uint64 = int64
    type float64 = float
    type float32 = float
    type protobuf_int32 = int32
    type protobuf_int64 = int64
    type uint32_fixed = Primitives_piqi.uint32
    type uint64_fixed = Primitives_piqi.uint64
    type int32_fixed = int32
    type int64_fixed = int64
    type binary = string
    type small_primitive_collection = Small_primitive_collection.t
    type full_primitive_collection = Full_primitive_collection.t
  end = Primitives_piqi
and Small_primitive_collection:
  sig
    type t = {
      mutable my_int32: Primitives_piqi.protobuf_int32 option;
      mutable my_int64: Primitives_piqi.protobuf_int64 option;
      mutable my_string: string option;
    }
  end = Small_primitive_collection
and Full_primitive_collection:
  sig
    type t = {
      mutable my_int32: Primitives_piqi.protobuf_int32 option;
      mutable my_int64: Primitives_piqi.protobuf_int64 option;
      mutable my_uint32: Primitives_piqi.uint32 option;
      mutable my_uint64: Primitives_piqi.uint64 option;
      mutable my_sint32: int32 option;
      mutable my_sint64: int64 option;
      mutable my_fixed32: Primitives_piqi.uint32_fixed option;
      mutable my_fixed64: Primitives_piqi.uint64_fixed option;
      mutable my_sfixed32: Primitives_piqi.int32_fixed option;
      mutable my_sfixed64: Primitives_piqi.int64_fixed option;
      mutable my_bool: bool option;
      mutable my_string: string option;
      mutable my_bytes: Primitives_piqi.binary option;
      mutable my_double: Primitives_piqi.float64 option;
      mutable my_float: Primitives_piqi.float32 option;
    }
  end = Full_primitive_collection


let rec parse_int32 x = Piqirun.int32_of_zigzag_varint x
and packed_parse_int32 x = Piqirun.int32_of_packed_zigzag_varint x

and parse_int64 x = Piqirun.int64_of_zigzag_varint x
and packed_parse_int64 x = Piqirun.int64_of_packed_zigzag_varint x

and parse_uint32 x = Piqirun.int32_of_varint x
and packed_parse_uint32 x = Piqirun.int32_of_packed_varint x

and parse_uint64 x = Piqirun.int64_of_varint x
and packed_parse_uint64 x = Piqirun.int64_of_packed_varint x

and parse_protobuf_int32 x = Piqirun.int32_of_signed_varint x
and packed_parse_protobuf_int32 x = Piqirun.int32_of_packed_signed_varint x

and parse_protobuf_int64 x = Piqirun.int64_of_signed_varint x
and packed_parse_protobuf_int64 x = Piqirun.int64_of_packed_signed_varint x

and parse_string x = Piqirun.string_of_block x

and parse_uint32_fixed x = Piqirun.int32_of_fixed32 x
and packed_parse_uint32_fixed x = Piqirun.int32_of_packed_fixed32 x

and parse_uint64_fixed x = Piqirun.int64_of_fixed64 x
and packed_parse_uint64_fixed x = Piqirun.int64_of_packed_fixed64 x

and parse_int32_fixed x = Piqirun.int32_of_signed_fixed32 x
and packed_parse_int32_fixed x = Piqirun.int32_of_packed_signed_fixed32 x

and parse_int64_fixed x = Piqirun.int64_of_signed_fixed64 x
and packed_parse_int64_fixed x = Piqirun.int64_of_packed_signed_fixed64 x

and parse_bool x = Piqirun.bool_of_varint x
and packed_parse_bool x = Piqirun.bool_of_packed_varint x

and parse_binary x = Piqirun.string_of_block x

and parse_float64 x = Piqirun.float_of_fixed64 x
and packed_parse_float64 x = Piqirun.float_of_packed_fixed64 x

and parse_float32 x = Piqirun.float_of_fixed32 x
and packed_parse_float32 x = Piqirun.float_of_packed_fixed32 x

and parse_small_primitive_collection x =
  let x = Piqirun.parse_record x in
  let _my_int32, x = Piqirun.parse_optional_field 1 parse_protobuf_int32 x in
  let _my_int64, x = Piqirun.parse_optional_field 2 parse_protobuf_int64 x in
  let _my_string, x = Piqirun.parse_optional_field 3 parse_string x in
  Piqirun.check_unparsed_fields x;
  {
    Small_primitive_collection.my_int32 = _my_int32;
    Small_primitive_collection.my_int64 = _my_int64;
    Small_primitive_collection.my_string = _my_string;
  }

and parse_full_primitive_collection x =
  let x = Piqirun.parse_record x in
  let _my_int32, x = Piqirun.parse_optional_field 1 parse_protobuf_int32 x in
  let _my_int64, x = Piqirun.parse_optional_field 2 parse_protobuf_int64 x in
  let _my_uint32, x = Piqirun.parse_optional_field 3 parse_uint32 x in
  let _my_uint64, x = Piqirun.parse_optional_field 4 parse_uint64 x in
  let _my_sint32, x = Piqirun.parse_optional_field 5 parse_int32 x in
  let _my_sint64, x = Piqirun.parse_optional_field 6 parse_int64 x in
  let _my_fixed32, x = Piqirun.parse_optional_field 7 parse_uint32_fixed x in
  let _my_fixed64, x = Piqirun.parse_optional_field 8 parse_uint64_fixed x in
  let _my_sfixed32, x = Piqirun.parse_optional_field 9 parse_int32_fixed x in
  let _my_sfixed64, x = Piqirun.parse_optional_field 10 parse_int64_fixed x in
  let _my_bool, x = Piqirun.parse_optional_field 11 parse_bool x in
  let _my_string, x = Piqirun.parse_optional_field 12 parse_string x in
  let _my_bytes, x = Piqirun.parse_optional_field 13 parse_binary x in
  let _my_double, x = Piqirun.parse_optional_field 14 parse_float64 x in
  let _my_float, x = Piqirun.parse_optional_field 15 parse_float32 x in
  Piqirun.check_unparsed_fields x;
  {
    Full_primitive_collection.my_int32 = _my_int32;
    Full_primitive_collection.my_int64 = _my_int64;
    Full_primitive_collection.my_uint32 = _my_uint32;
    Full_primitive_collection.my_uint64 = _my_uint64;
    Full_primitive_collection.my_sint32 = _my_sint32;
    Full_primitive_collection.my_sint64 = _my_sint64;
    Full_primitive_collection.my_fixed32 = _my_fixed32;
    Full_primitive_collection.my_fixed64 = _my_fixed64;
    Full_primitive_collection.my_sfixed32 = _my_sfixed32;
    Full_primitive_collection.my_sfixed64 = _my_sfixed64;
    Full_primitive_collection.my_bool = _my_bool;
    Full_primitive_collection.my_string = _my_string;
    Full_primitive_collection.my_bytes = _my_bytes;
    Full_primitive_collection.my_double = _my_double;
    Full_primitive_collection.my_float = _my_float;
  }


let rec gen__int32 code x = Piqirun.int32_to_zigzag_varint code x
and packed_gen__int32 x = Piqirun.int32_to_packed_zigzag_varint x

and gen__int64 code x = Piqirun.int64_to_zigzag_varint code x
and packed_gen__int64 x = Piqirun.int64_to_packed_zigzag_varint x

and gen__uint32 code x = Piqirun.int32_to_varint code x
and packed_gen__uint32 x = Piqirun.int32_to_packed_varint x

and gen__uint64 code x = Piqirun.int64_to_varint code x
and packed_gen__uint64 x = Piqirun.int64_to_packed_varint x

and gen__protobuf_int32 code x = Piqirun.int32_to_signed_varint code x
and packed_gen__protobuf_int32 x = Piqirun.int32_to_packed_signed_varint x

and gen__protobuf_int64 code x = Piqirun.int64_to_signed_varint code x
and packed_gen__protobuf_int64 x = Piqirun.int64_to_packed_signed_varint x

and gen__string code x = Piqirun.string_to_block code x

and gen__uint32_fixed code x = Piqirun.int32_to_fixed32 code x
and packed_gen__uint32_fixed x = Piqirun.int32_to_packed_fixed32 x

and gen__uint64_fixed code x = Piqirun.int64_to_fixed64 code x
and packed_gen__uint64_fixed x = Piqirun.int64_to_packed_fixed64 x

and gen__int32_fixed code x = Piqirun.int32_to_signed_fixed32 code x
and packed_gen__int32_fixed x = Piqirun.int32_to_packed_signed_fixed32 x

and gen__int64_fixed code x = Piqirun.int64_to_signed_fixed64 code x
and packed_gen__int64_fixed x = Piqirun.int64_to_packed_signed_fixed64 x

and gen__bool code x = Piqirun.bool_to_varint code x
and packed_gen__bool x = Piqirun.bool_to_packed_varint x

and gen__binary code x = Piqirun.string_to_block code x

and gen__float64 code x = Piqirun.float_to_fixed64 code x
and packed_gen__float64 x = Piqirun.float_to_packed_fixed64 x

and gen__float32 code x = Piqirun.float_to_fixed32 code x
and packed_gen__float32 x = Piqirun.float_to_packed_fixed32 x

and gen__small_primitive_collection code x =
  let _my_int32 = Piqirun.gen_optional_field 1 gen__protobuf_int32 x.Small_primitive_collection.my_int32 in
  let _my_int64 = Piqirun.gen_optional_field 2 gen__protobuf_int64 x.Small_primitive_collection.my_int64 in
  let _my_string = Piqirun.gen_optional_field 3 gen__string x.Small_primitive_collection.my_string in
  Piqirun.gen_record code (_my_int32 :: _my_int64 :: _my_string :: [])

and gen__full_primitive_collection code x =
  let _my_int32 = Piqirun.gen_optional_field 1 gen__protobuf_int32 x.Full_primitive_collection.my_int32 in
  let _my_int64 = Piqirun.gen_optional_field 2 gen__protobuf_int64 x.Full_primitive_collection.my_int64 in
  let _my_uint32 = Piqirun.gen_optional_field 3 gen__uint32 x.Full_primitive_collection.my_uint32 in
  let _my_uint64 = Piqirun.gen_optional_field 4 gen__uint64 x.Full_primitive_collection.my_uint64 in
  let _my_sint32 = Piqirun.gen_optional_field 5 gen__int32 x.Full_primitive_collection.my_sint32 in
  let _my_sint64 = Piqirun.gen_optional_field 6 gen__int64 x.Full_primitive_collection.my_sint64 in
  let _my_fixed32 = Piqirun.gen_optional_field 7 gen__uint32_fixed x.Full_primitive_collection.my_fixed32 in
  let _my_fixed64 = Piqirun.gen_optional_field 8 gen__uint64_fixed x.Full_primitive_collection.my_fixed64 in
  let _my_sfixed32 = Piqirun.gen_optional_field 9 gen__int32_fixed x.Full_primitive_collection.my_sfixed32 in
  let _my_sfixed64 = Piqirun.gen_optional_field 10 gen__int64_fixed x.Full_primitive_collection.my_sfixed64 in
  let _my_bool = Piqirun.gen_optional_field 11 gen__bool x.Full_primitive_collection.my_bool in
  let _my_string = Piqirun.gen_optional_field 12 gen__string x.Full_primitive_collection.my_string in
  let _my_bytes = Piqirun.gen_optional_field 13 gen__binary x.Full_primitive_collection.my_bytes in
  let _my_double = Piqirun.gen_optional_field 14 gen__float64 x.Full_primitive_collection.my_double in
  let _my_float = Piqirun.gen_optional_field 15 gen__float32 x.Full_primitive_collection.my_float in
  Piqirun.gen_record code (_my_int32 :: _my_int64 :: _my_uint32 :: _my_uint64 :: _my_sint32 :: _my_sint64 :: _my_fixed32 :: _my_fixed64 :: _my_sfixed32 :: _my_sfixed64 :: _my_bool :: _my_string :: _my_bytes :: _my_double :: _my_float :: [])


let gen_int32 x = gen__int32 (-1) x
let gen_int64 x = gen__int64 (-1) x
let gen_uint32 x = gen__uint32 (-1) x
let gen_uint64 x = gen__uint64 (-1) x
let gen_protobuf_int32 x = gen__protobuf_int32 (-1) x
let gen_protobuf_int64 x = gen__protobuf_int64 (-1) x
let gen_string x = gen__string (-1) x
let gen_uint32_fixed x = gen__uint32_fixed (-1) x
let gen_uint64_fixed x = gen__uint64_fixed (-1) x
let gen_int32_fixed x = gen__int32_fixed (-1) x
let gen_int64_fixed x = gen__int64_fixed (-1) x
let gen_bool x = gen__bool (-1) x
let gen_binary x = gen__binary (-1) x
let gen_float64 x = gen__float64 (-1) x
let gen_float32 x = gen__float32 (-1) x
let gen_small_primitive_collection x = gen__small_primitive_collection (-1) x
let gen_full_primitive_collection x = gen__full_primitive_collection (-1) x


let rec default_int32 () = 0l
and default_int64 () = 0L
and default_uint32 () = 0l
and default_uint64 () = 0L
and default_protobuf_int32 () = default_int32 ()
and default_protobuf_int64 () = default_int64 ()
and default_string () = ""
and default_uint32_fixed () = default_uint32 ()
and default_uint64_fixed () = default_uint64 ()
and default_int32_fixed () = default_int32 ()
and default_int64_fixed () = default_int64 ()
and default_bool () = false
and default_binary () = ""
and default_float64 () = 0.0
and default_float32 () = 0.0
and default_small_primitive_collection () =
  {
    Small_primitive_collection.my_int32 = None;
    Small_primitive_collection.my_int64 = None;
    Small_primitive_collection.my_string = None;
  }
and default_full_primitive_collection () =
  {
    Full_primitive_collection.my_int32 = None;
    Full_primitive_collection.my_int64 = None;
    Full_primitive_collection.my_uint32 = None;
    Full_primitive_collection.my_uint64 = None;
    Full_primitive_collection.my_sint32 = None;
    Full_primitive_collection.my_sint64 = None;
    Full_primitive_collection.my_fixed32 = None;
    Full_primitive_collection.my_fixed64 = None;
    Full_primitive_collection.my_sfixed32 = None;
    Full_primitive_collection.my_sfixed64 = None;
    Full_primitive_collection.my_bool = None;
    Full_primitive_collection.my_string = None;
    Full_primitive_collection.my_bytes = None;
    Full_primitive_collection.my_double = None;
    Full_primitive_collection.my_float = None;
  }


include Primitives_piqi
