import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:tango_flutter_project/bloc/Userbloc/userbloc_bloc.dart';
import 'package:tango_flutter_project/services/getuser.dart';
import 'package:tango_flutter_project/widgets/snackbar.dart';

class CustomImageContainer extends StatefulWidget {
  @override
  _CustomImageContainerState createState() => _CustomImageContainerState();
}

class _CustomImageContainerState extends State<CustomImageContainer> {
  File? _imageFile; // Local variable to store picked image

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, right: 10.0),
      child: Container(
        height: 150,
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white38,
          border: Border.all(
            width: 1,
            color: Colors.white,
          ),
        ),
        child: (_imageFile == null)
            ? Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                    icon: Icon(
                      Icons.add_circle,
                    ),
                    onPressed: () async {
                      ImagePicker _picker = ImagePicker();
                      final XFile? pickedImage = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 50,
                      );

                      if (pickedImage == null) {
                        showSnackBar("No image was selected.", context);
                        return;
                      }

                      setState(() {
                        _imageFile = File(
                            pickedImage.path); // Store picked image locally
                        ActiveUser.imageFiles.add(pickedImage);
                      });

                      // Upload image to Firebase Storage

                      // Emit database state here after uplo
                    }))
            : Image.file(
                _imageFile!,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
