fun included ([], l2) = true | 
	included (h::l, l2) = (List.exists (fn x => x = h) l2) andalso (included (l, l2));

fun list_eq (l1, l2) = 
(List.length l1) = (List.length l2) andalso (included (l1,l2)) andalso (included (l2,l1));