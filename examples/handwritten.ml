signature PERSON = 
sig
  structure PhoneNumber : sig
    type t
  end
  type t
  type phoneType
  type phoneNumber
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
          	 type_: phoneType option,
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