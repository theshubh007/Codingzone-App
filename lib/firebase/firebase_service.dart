import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final GoogleSignIn googleSignIn = GoogleSignIn();
  CollectionReference dusers = FirebaseFirestore.instance.collection('users');
  User? user=FirebaseAuth.instance.currentUser;

  FirebaseService._();
  static final FirebaseService fbinstance=FirebaseService._();


  Future<UserCredential> signInWithGoogle() async {

    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);


  }



  Future<void> signOutFromGoogle() async{
    await googleSignIn.signOut();
    await auth.signOut();
  }

  Future<void> insert(Map<String,dynamic> data)async{
    await dusers.doc(user!.email).set(data);
  }






}





