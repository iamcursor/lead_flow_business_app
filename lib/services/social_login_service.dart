//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// // Google Sign-In Service Class
// class GoogleSignInService {
//    static final FirebaseAuth _auth = FirebaseAuth.instance;
//    static final GoogleSignIn _googleSignIn = GoogleSignIn(
//      scopes: ['email', 'profile'],
//    );
//    static Future<UserCredential?> signInWithGoogle() async{
//      try{
//        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//        if(googleUser == null)
//          return null;
//        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//        final credentials = GoogleAuthProvider.credential(
//          idToken: googleAuth.idToken,
//        );
//        final userCredentials = await _auth.signInWithCredential(credentials);
//        return userCredentials;
//      }
//      catch(e){
//        print("Google sign in error: $e");
//        return null;
//      }
//    }
//
// }