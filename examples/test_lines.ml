val b = Person.PhoneNumber.Builder.init ();
val b = Person.PhoneNumber.Builder.set_number (b, "074");
val b = Person.PhoneNumber.Builder.set_type_ (b, Person.PhoneType.MOBILE);




val pn = Person.PhoneNumber.Builder.build b;
fun id_pn x:Person.PhoneNumber.t = x;
id_pn pn;
val encoded_pn = Person.PhoneNumber.encode pn;       
ByteBuffer.fromVector encoded_pn;
Person.PhoneNumber.decode it;

