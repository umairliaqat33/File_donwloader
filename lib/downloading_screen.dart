import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';

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
            "https://redirector.googlevideo.com/videoplayback?expire=1696438978&ei=YkYdZa2aLYyk1gKPo6-4Bw&ip=2a01%3A4f8%3A242%3A16d9%3A%3A2&id=o-AEmZQMaRbPHYiBLgpQXGmHFx0_IrG9L9we5a-0lDCUJb&itag=22&source=youtube&requiressl=yes&mh=hb&mm=31%2C29&mn=sn-4g5lzney%2Csn-4g5edndz&ms=au%2Crdu&mv=m&mvi=1&pl=51&initcwndbps=532500&siu=1&vprv=1&mime=video%2Fmp4&cnr=14&ratebypass=yes&dur=962.560&lmt=1673891074030100&mt=1696417073&fvip=1&fexp=24007246&beids=24350018&c=ANDROID_TESTSUITE&txp=6318224&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Csiu%2Cvprv%2Cmime%2Ccnr%2Cratebypass%2Cdur%2Clmt&sig=AOq0QJ8wRAIgBqSCctLrieB6gh-ZDL8NeUx5i2epLpKd6WEHZG4Ql14CIHWhk9d6kvqLpqyR1EDy7sMh-CYN6s-Z4dcEfLHFUCn3&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AG3C_xAwRAIgB3t0utt95hITRKU0sg0_N6eNXuG1M2qBSw_kbYnsZcMCIGbsoPfE9xEe06WBnUgIWi35bvblbNJftScTwT9FTaGv&range=0-118866901&title=X2Download.app-Anime%20moment%20of%20impact%20makes%20the%20heart%20beat%20faster",
            "X2Download.app-Anime moment of impact makes the heart beat faster-(720p60).mp4") ??
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
      directory = (await getExternalStorageDirectory())!;
      Fluttertoast.showToast(
        msg: directory.path,
        timeInSecForIosWeb: 4,
      );
      log(directory.path);
      directory = Directory('/storage/emulated/0/File Downloader');
      log(directory.path);
      File savedFile = File('${directory.path}/$fileName');
      await dio.download(url, savedFile.path,
          onReceiveProgress: (downloaded, totalSize) {
        setState(() {
          progress = downloaded / totalSize;
        });
      });
      final result = await GallerySaver.saveVideo('${directory.path}/$fileName',
          albumName: 'File Downloader');
      log(result.toString());
      return true;
    } catch (e) {
      if (permissionStatus.isDenied) {
        Fluttertoast.showToast(msg: "Storage permission denied");
      }
      log(e.toString());
    }
    return null;
  }
}
