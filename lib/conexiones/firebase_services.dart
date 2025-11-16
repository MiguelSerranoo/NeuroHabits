// class FirebaseService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future SignUp(
//     String email,
//     String password,
//     String nombre,
//     String apellidos,
//   ) async {
//     await _auth.instance.createUserWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//     var userID = auth.currentUser!.uid;
//     addUser(nombre, email, apellidos);
//   }
// }
