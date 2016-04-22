module rec Simple_message_piqi:
  sig
    type protobuf_int32 = int32
    type simple_message = Simple_message.t
  end = Simple_message_piqi
and Simple_message:
  sig
    type t = {
      mutable id: Simple_message_piqi.protobuf_int32;
      mutable name: string option;
      mutable phone_number: string list;
    }
  end = Simple_message


let rec parse_int32 x = Piqirun.int32_of_zigzag_varint x
and packed_parse_int32 x = Piqirun.int32_of_packed_zigzag_varint x

and parse_protobuf_int32 x = Piqirun.int32_of_signed_varint x
and packed_parse_protobuf_int32 x = Piqirun.int32_of_packed_signed_varint x

and parse_string x = Piqirun.string_of_block x

and parse_simple_message x =
  let x = Piqirun.parse_record x in
  let _id, x = Piqirun.parse_required_field 1 parse_protobuf_int32 x in
  let _name, x = Piqirun.parse_optional_field 2 parse_string x in
  let _phone_number, x = Piqirun.parse_repeated_field 3 parse_string x in
  Piqirun.check_unparsed_fields x;
  {
    Simple_message.id = _id;
    Simple_message.name = _name;
    Simple_message.phone_number = _phone_number;
  }


let rec gen__int32 code x = Piqirun.int32_to_zigzag_varint code x
and packed_gen__int32 x = Piqirun.int32_to_packed_zigzag_varint x

and gen__protobuf_int32 code x = Piqirun.int32_to_signed_varint code x
and packed_gen__protobuf_int32 x = Piqirun.int32_to_packed_signed_varint x

and gen__string code x = Piqirun.string_to_block code x

and gen__simple_message code x =
  let _id = Piqirun.gen_required_field 1 gen__protobuf_int32 x.Simple_message.id in
  let _name = Piqirun.gen_optional_field 2 gen__string x.Simple_message.name in
  let _phone_number = Piqirun.gen_repeated_field 3 gen__string x.Simple_message.phone_number in
  Piqirun.gen_record code (_id :: _name :: _phone_number :: [])


let gen_int32 x = gen__int32 (-1) x
let gen_protobuf_int32 x = gen__protobuf_int32 (-1) x
let gen_string x = gen__string (-1) x
let gen_simple_message x = gen__simple_message (-1) x


let rec default_int32 () = 0l
and default_protobuf_int32 () = default_int32 ()
and default_string () = ""
and default_simple_message () =
  {
    Simple_message.id = default_protobuf_int32 ();
    Simple_message.name = None;
    Simple_message.phone_number = [];
  }


include Simple_message_piqi
