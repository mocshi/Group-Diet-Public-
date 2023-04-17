import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;

import 'common.dart';

Future<String?> select_icon(BuildContext context) async {
  const String SELECT_ICON = "アイコンを選択";
  const List<String> SELECT_ICON_OPTIONS = ["写真から選択", "写真を撮影"];
  const int GALLERY = 0;
  const int CAMERA = 1;

  var _select_type = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(SELECT_ICON),
          children: SELECT_ICON_OPTIONS.asMap().entries.map((e) {
            return SimpleDialogOption(
              child: ListTile(
                title: Text(e.value),
              ),
              onPressed: () => Navigator.of(context).pop(e.key),
            );
          }).toList(),
        );
      });

  final picker = ImagePicker();
  var _img_src;

  if (_select_type == null) {
    return null;
  }
  //カメラで撮影
  else if (_select_type == CAMERA) {
    _img_src = ImageSource.camera;
  }
  //ギャラリーから選択
  else if (_select_type == GALLERY) {
    _img_src = ImageSource.gallery;
  }

  final pickedFile = await picker.pickImage(
      maxHeight: 1020, maxWidth: 1020, source: _img_src, imageQuality: 5);

  if (pickedFile == null) {
    return null;
  } else {
    return pickedFile.path;
  }
}

Future<String> uploadFile(String sourcePath, String uploadFileName) async {
  late String response;
  bool flg = true;

  AppParts.iconList.forEach((key, value) {
    if (value == sourcePath) {
      flg = false;
    }
  });

  bool islocal = await io.File(sourcePath).exists();
  if (!islocal) {
    flg = false;
  }

  if (flg) {
    final FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("icon"); //保存するフォルダ

    io.File file = io.File(sourcePath);

    UploadTask task = ref.child(uploadFileName).putFile(file);

    try {
      var res = await task;
      response = await res.ref.getDownloadURL();
    } catch (FirebaseException) {
      //エラー処理
      customSnackBar(
        content: 'Storage Error',
      );
      return "";
    }
  } else {
    response = sourcePath;
  }

  return response;
}

void delFile(String sourcePath) async {
  bool flg = true;

  AppParts.iconList.forEach((key, value) {
    if (value == sourcePath) {
      flg = false;
    }
  });

  if (flg) {
    final FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("icon");
    try {
      await ref.child(sourcePath).delete();
    } catch (e) {
      customSnackBar(
        content: 'Storage Error',
      );
    }
  }
}

Future<String> _getImgs(String imgPathLocal, String imgPathRemote) async {
  bool existLocal = await io.File(imgPathLocal).exists();
  String imgPathUse = "";

  if (existLocal) {
    //ローカルに存在する場合はローカルの画像を使う
    imgPathUse = imgPathLocal;
  } else {
    if ((imgPathRemote != "") && (imgPathRemote != null)) {
      try {
        //ローカルに存在しない場合はリモートのデータをダウンロード
        imgPathUse = await FirebaseStorage.instance
            .ref()
            .child("icon")
            .child(imgPathRemote)
            .getDownloadURL();
      } catch (FirebaseException) {
        imgPathUse = "";
      }
    } else {
      imgPathUse = "";
    }
  }
  return imgPathUse;
}
