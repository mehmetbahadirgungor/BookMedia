import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ProfilePicture {
  // Create a storage reference
  final storageRef = FirebaseStorage.instance.ref().child('profile_pictures');

  Future<File> downloadImageFromUrl(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      final filename = basename(imageUrl);
      final tempDir = await getTemporaryDirectory();
      File file = File(join(tempDir.path, filename));

      file = await file.writeAsBytes(response.bodyBytes);

      print("file: $file");

      // Return the downloaded file
      return file;
    } else {
      // Handle download error (e.g., throw an exception)
      throw Exception('Failed to download image from $imageUrl');
    }
  }

  Future<void> uploadProfilePhoto(
      String currentUserUid, pickedImage) async {
    dynamic imageFile = pickedImage;
    // Get the file object
    if (pickedImage.runtimeType == XFile) imageFile = File(pickedImage.path);

    // Create a unique filename based on user ID (replace with your logic)
    final filename = '$currentUserUid.jpg';
    // Create a reference to the storage location
    final uploadTask = storageRef.child(filename).putFile(imageFile);

    // Track upload progress (optional)
    await uploadTask.whenComplete(() => null);
  }

  Future<String?> getProfilePictureUrl(String currentUserUid) async {
    try {
      // Construct the filename based on user ID (replace with your logic)
      final filename = '$currentUserUid.jpg';

      // Get the download URL for the image
      final ref = storageRef.child(filename);
      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteProfilePhoto(currentUserUid) async {
    try {
      await storageRef.child("$currentUserUid.jpg").delete();
    } catch (e) {
      print(e);
    }
  }
}
