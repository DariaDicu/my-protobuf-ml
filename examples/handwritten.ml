signature Person = 
sig
  structure PhoneNumber : sig
    type t
  end
  structure PhoneEntry : sig
    type t
  end
  type t
  type phoneType
  type phoneNumber
end 

structure Person = 
struct
  structure PhoneEntry
  structure PhoneNumber = 
  	struct
  		datatype phoneType = MOBILE
   		 	| HOME
    		| WORK
    	type phoneT = phoneType
    	type phoneE = PhoneEntry.t
  		type t = {
		     number: string option,
          	 ttype: phoneT option
  		}
  	end
  structure PhoneEntry = 
  	struct
  		datatype phoneType = MOBILE
   		 	| HOME
    		| WORK
    	type phoneT = phoneType
    	type phoneN = PhoneNumber.t
  		type t = {
		     number: string option,
          	 ttype: phoneT option
  		}
  	end
  datatype phoneType = MOBILE
    | HOME
    | WORK
  type phoneNumber = PhoneNumber.t
  type t = {
    name: string option,
    id: int option,
    email: string option,
    phones: phoneNumber list
  }
end
