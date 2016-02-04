use "MlGenLib.ml";

signature PHONETYPE =
sig
  type t
end
structure PhoneType :> PHONETYPE = 
struct
  datatype t = MOBILE
    | HOME
    | WORK
    | UNKNOWN
end
type phoneType = PhoneType.t

signature PERSON =
sig
  structure PhoneType : sig
    type t
  end
  type phoneType
  structure PhoneNumber : sig
    type t
    val set_number: t * string option -> unit
    val set_type_: t * phoneType option -> unit
  end
  type phoneNumber
  type t
  val set_name: t * string option -> unit
  val set_id: t * int option -> unit
  val set_email: t * string option -> unit
  val set_phones: t * phoneNumber list -> unit
  val add_phones: t * phoneNumber -> unit
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
      number: string option ref,
      type_: phoneType option ref
    }
    fun set_number (msg, value) = 
    (#number msg) := value
    fun set_type_ (msg, value) = 
    (#type_ msg) := value
  end
  type phoneNumber = PhoneNumber.t
  type t = {
    name: string option ref,
    id: int option ref,
    email: string option ref,
    phones: phoneNumber list ref
  }
  fun set_name (msg, value) = 
  (#name msg) := value
  fun set_id (msg, value) = 
  (#id msg) := value
  fun set_email (msg, value) = 
  (#email msg) := value
  fun set_phones (msg, value) = 
  (#phones msg) := value
  fun add_phones (msg, value) = 
  (#phones msg) := value :: !(#phones msg)
end
type person = Person.t

signature ADDRESSBOOK =
sig
  type t
  val set_people: t * person list -> unit
  val add_people: t * person -> unit
end

structure AddressBook :> ADDRESSBOOK = 
struct
  type t = {
    people: person list ref
  }
  fun set_people (msg, value) = 
  (#people msg) := value
  fun add_people (msg, value) = 
  (#people msg) := value :: !(#people msg)
end
type addressBook = AddressBook.t

