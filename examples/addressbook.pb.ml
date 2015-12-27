datatype PhoneType = MOBILE
  | HOME
  | WORK;
structure Person = struct
    structure PhoneNumber = struct
        type t = {
          number: string option,
          type: PhoneType option,
        }
      end
    datatype PhoneType = MOBILE
      | HOME
      | WORK;
    type t = {
      name: string option,
      id: int option,
      email: string option,
      phones: PhoneNumber list,
    }
  end
structure AddressBook = struct
    type t = {
      people: Person list,
    }
  end
