import 'package:booksearchapp/data/firebase_storage.dart';
import 'package:booksearchapp/widgets/success_error_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController_ = TextEditingController();
  TextEditingController passwordController_ = TextEditingController();
  TextEditingController usernameController_ = TextEditingController();
  bool signUpCheck = false;
  bool loginError = false;
  String loginErrorMessage = "";
  XFile? pickedImage;

  void login() async {
    if (!signUpCheck) {
      try {       
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController_.text.trim(),
            password: passwordController_.text.trim());

      } on FirebaseAuthException catch (e) {
        MyToast().show(e.message.toString(), false, context);
      }
    } else {
      setState(() {
        signUpCheck = false;
      });
    }
  }

  void signInWithGoogle() async {
    try {
      await GoogleSignIn().signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      try {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({"username": googleUser?.displayName,
            "theme" : "lightTheme"});
      } catch (e) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .set({
          "username": googleUser?.displayName,
          "theme" : "lightTheme"
        });
      }


      await ProfilePicture().uploadProfilePhoto(
          FirebaseAuth.instance.currentUser!.uid,
          await ProfilePicture().downloadImageFromUrl(
              FirebaseAuth.instance.currentUser!.photoURL!));

    } on FirebaseAuthException catch (e) {
      MyToast().show(e.message.toString(), false, context);
    }
  }

  void signUp() async {
    if (signUpCheck) {
      try {
        final FirebaseAuth auth = FirebaseAuth.instance;
        await auth.createUserWithEmailAndPassword(
          email: emailController_.text.trim(),
          password: passwordController_.text.trim(),
        );

        await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .set({
          "username": usernameController_.text,
          "theme" : "lightTheme"
        });

        if(pickedImage!=null) await ProfilePicture().uploadProfilePhoto(
            FirebaseAuth.instance.currentUser!.uid, pickedImage);
      } on FirebaseAuthException catch (e) {     
        MyToast().show(e.message.toString(), false, context);
        setState(() {
          loginError = true;
        });
      } catch (e) {
        MyToast().show(e.toString(), false, context);
      }
    } else {
      setState(() {
        signUpCheck = true;
      });
    }
  }

  void forgotPassword() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      await auth.sendPasswordResetEmail(email: emailController_.text.trim());

      print('Password reset email sent!');
    } on FirebaseAuthException catch (e) {
      MyToast().show(e.message.toString(), false, context);
    } catch (e) {
      MyToast().show(e.toString(), false, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: Text(
                "BookMedia",
                style: TextStyle(
                  fontSize: 40,
                ),
              ),
            ),

            // Error about account
            if (loginError) Text(loginErrorMessage),

            // Email TextField
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: emailController_,
                decoration: InputDecoration(hintText: "Email"),
              ),
            ),

            // Username TextField
            if (signUpCheck)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: usernameController_,
                  decoration: InputDecoration(hintText: "Username"),
                ),
              ),

            // Password TextField
            TextField(
              controller: passwordController_,
              decoration: InputDecoration(hintText: "Password"),
              obscureText: true,
            ),

            // Photo TextButton
            if (signUpCheck)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Choosing Image Button
                  TextButton(
                    child: Text("Upload Profile Photo"),
                    onPressed: () async {
                      pickedImage = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      setState(() {});
                    },
                  ),

                  // Checking Image Button
                  if (pickedImage != null) Text("Uploaded"),
                ],
              ),

            // Forgot Password
            if (!signUpCheck)
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: forgotPassword,
                      child: const Text(
                        "Forgot Password?",
                      ),
                    ),
                  ],
                ),
              ),

            // Login and SignUp buttons
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: signUp,
                    child: const Text("Sign Up"),
                  ),
                  TextButton(onPressed: login, child: const Text("Login")),
                  TextButton(
                      onPressed: signInWithGoogle, child: const Text("Login with Google"))
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
