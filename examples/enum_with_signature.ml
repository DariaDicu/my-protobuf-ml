datatype phoneType = MOBILE
  | HOME
  | WORK
  | UNKNOWN

signature PERSON =
sig
  structure PhoneType : sig
    type t
  end
  type phoneType
  structure PhoneNumber : sig
    type t
    (*
    val set_number: string option * t -> t
    val set_type_: phoneType option * t -> t
  *)
  end
  type phoneNumber
  type t
  (*
  val set_name: string option * t -> t
  val set_id: int option * t -> t
  val set_email: string option * t -> t
  val set_phones: phoneNumber list * t -> t
*)
end

structure Person :> PERSON = 
struct
  structure PhoneType = 
  struct
    datatype t = MOBILE
    | HOME
    | WORK
  end
  type phoneType = PhoneType.t
  structure PhoneNumber = 
  struct
    type t = {
      number: string option,
      type_: phoneType option
    }
  end
  type phoneNumber = PhoneNumber.t
  type t = {
    name: string option,
    id: int option,
    email: string option,
    phones: phoneNumber list
  }
end
type person = Person.t

fun encodePhoneType e =
  case e of MOBILE => encodeVarint 0
  | HOME => encodeVarint 1
  | WORK => encodeVarint 2

signature ADDRESSBOOK =
sig
  type t
  val set_people: person list * t -> t
end

structure AddressBook :> ADDRESSBOOK = 
struct
  type t = {
    people: person list
  }
end
type addressBook = AddressBook.t


fun encodePhoneType e =
  case e of MOBILE => encodeVarint 0
  | HOME => encodeVarint 1
  | WORK => encodeVarint 2
  | UNKNOWN => encodeVarint 3

fun encodePhoneType e =
  case e of MOBILE => encodeVarint 0
  | HOME => encodeVarint 1
  | WORK => encodeVarint 2


