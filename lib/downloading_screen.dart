import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

// import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadingScreen extends StatefulWidget {
  const DownloadingScreen({super.key});

  @override
  State<DownloadingScreen> createState() => _DownloadingScreenState();
}

class _DownloadingScreenState extends State<DownloadingScreen> {
  bool loading = false;
  final Dio dio = Dio();
  double progress = 0;

  @override
  void initState() {
    super.initState();
    // createDirectory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: loading
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                ),
              )
            : ElevatedButton(
                onPressed: () => downloadButton(),
                child: const Text("click to download"),
              ),
      ),
    );
  }

  void downloadButton() async {
    setState(() {
      loading = true;
    });
    bool? downloaded;
    downloaded = await saveFile(
            "https://dt244.kokiuyar.xyz/download?file=ZGE0OWI3OWJlZGY5NzNkZThhMjQ1OTQxYmEwMGY0NWEyMmMxMWUxNTkwOWNhMTcxZWEyMzJlZjMxYWU0OWY1ZF83MjBwNjAubXA04pivWDJEb3dubG9hZC5hcHAtVG9wIEFkb3JhYmxlIEFuaW1lIEVsZiBDaGFyYWN0ZXJzIH4gRVhUUkVNRUxZIEJFQVVUSUZVTOKYrzcyMHA2MA",
            "anime video.mp4") ??
        false;
    if (downloaded) {
      log("file downloaded");
    } else {
      log("file download failed");
    }
    setState(() {
      loading = false;
    });
  }

  Future<bool?> saveFile(String url, String fileName) async {
    PermissionStatus permissionStatus = await Permission.storage.request();
    Directory directory;
    try {
      if (permissionStatus.isGranted) {
        if (Platform.isAndroid) {
          directory = (await getExternalStorageDirectory())!;
          Fluttertoast.showToast(
            msg: directory.path,
            timeInSecForIosWeb: 4,
          );
          log(directory.path);
          Fluttertoast.showToast(
            msg: directory.path,
          );
          String newPath = '';
          // /storage/emulated/0/Android/data/com.example.file_downloader/files
          List<String> folders = directory.path.split('/');
          for (int x = 1; x < folders.length; x++) {
            String folder = folders[x];
            if (folder != 'Android') {
              newPath += '/$folder';
            } else {
              break;
            }
          }
          newPath = '$newPath/File Downloader';
          directory = Directory(newPath);
          Fluttertoast.showToast(
            msg: directory.path,
            timeInSecForIosWeb: 4,
          );
          log(directory.path);
        } else {
          directory = await getTemporaryDirectory();
        }
        if (!await directory.exists()) {
          await directory.create();
        }
        File savedFile = File('${directory.path}/$fileName');
        if (await directory.exists()) {
          await dio.download(url, savedFile.path,
              onReceiveProgress: (downloaded, totalSize) {
            setState(() {
              progress = downloaded / totalSize;
            });
          });
        }
        if (Platform.isIOS) {
          await ImageGallerySaver.saveFile(savedFile.path,
              isReturnPathOfIOS: true);
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (permissionStatus.isDenied) {
        Fluttertoast.showToast(msg: "Storage permission denied");
      }
      log(e.toString());
    }
    // return null;
  }
}
