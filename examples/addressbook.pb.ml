datatype phoneType = MOBILE
  | HOME
  | WORK
  | UNKNOWN


signature PERSON =
sig
  structure PhoneNumber : sig
    type t
  end
  type t
  type phoneNumber
  type phoneType
end

structure Person :> PERSON = 
struct
  datatype phoneType = MOBILE
    | HOME
    | WORK
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


signature ADDRESSBOOK =
sig
  type t
end

structure AddressBook :> ADDRESSBOOK = 
struct
  type t = {
    people: person list
  }
end
type addressBook = AddressBook.t


