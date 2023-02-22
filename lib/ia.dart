import 'package:http/http.dart';
import 'package:process_run/shell.dart';
import 'dart:convert';
import 'dart:io';

dynamic getJson(Uri url) async {
  var response = await get(url);
  var body = response.body.toString();
  var json = jsonDecode(body);

  return json;
}

class gdown {
  static Future<String> getName(String url) async {
    var response = await get(Uri.parse(url));
    var body = response.body.toString();
    var name = body.split("<title>")[1].split(" - Google Drive</title>")[0];

    return name;
  }

  static Future<String> download(String url, String name) async {
    await Directory('${Directory.current.path}/downloads/gdown-$name').create();

    var shell = Shell();
    bool isFolder = false;
    String options = "-O ${Directory.current.path}/downloads/gdown-$name";
    String path = "";

    if (url.contains("folders")) {
      options += " --folder";
      isFolder = true;
    }

    await shell.run('''gdown --fuzzy $url $options''');

    if (isFolder) {
      await shell.run(
          '''zip -r gdown-$name.zip ${Directory.current.path}/downloads/gdown-$name/*''');
      path = '${Directory.current.path}/downloads/gdown-$name.zip';
    } else {
      path = '${Directory.current.path}/downloads/gdown-$name/$name';
    }

    return path;
  }
}

class isFile {
  static bool powerpoint(String filename) {
    List<String> powerpointFiles = [
      'pptx',
      'pptm',
      'ppt',
      'potx',
      'potm',
      'pot',
      'ppsx',
      'pptx',
      'odf',
      'ppsm',
      'pps',
      'ppam',
      'ppa'
    ];

    return powerpointFiles.contains(filename.split('.').last);
  }

  static bool image(String filename) {
    List<String> imageFiles = [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp',
      'tiff',
      'svg',
      'webp'
    ];

    return imageFiles.contains(filename.split('.').last);
  }

  static bool video(String filename) {
    List<String> videoFiles = [
      'mp4',
      'webm',
      'ogv',
      'avi',
      'mov',
      'wmv',
      'flv',
      'mpg',
      'mpeg',
      'm4v',
      '3gp',
      '3g2',
      'mkv'
    ];

    return videoFiles.contains(filename.split('.').last);
  }

  static bool torrent(String filename) {
    return filename.split('.').last == 'torrent';
  }
}

Future<Map<String, dynamic>?> getIdentifierData(String identifier) async {
  var torrentUrl, powerpointUrl;
  String url =
      'https://archive.org/services/search/v1/scrape?fields=title,mediatype,date,creator&q=collection%3Apptos';
  String metadataUrl = 'https://archive.org/metadata/$identifier';

  dynamic itemInfo, itemMetadata;
  List<dynamic> itemInfoResults, itemMetadataResults;

  try {
    itemInfo = await getJson(Uri.parse(url));
    itemInfoResults = itemInfo['items'] as List;

    itemMetadata = await getJson(Uri.parse(metadataUrl));
    itemMetadataResults = itemMetadata['files'] as List;
  } catch (e) {
    print('No results found for identifier: "$identifier"');
    return null;
  }

  for (var result in itemMetadataResults) {
    var filename = result['name'] as String;

    if (isFile.powerpoint(filename)) {
      powerpointUrl = 'https://archive.org/download/$identifier/$filename'
          .replaceAll(' ', '%20');
    }

    if (isFile.torrent(filename)) {
      torrentUrl = 'https://archive.org/download/$identifier/$filename'
          .replaceAll(' ', '%20');
    }
  }

  for (var result in itemInfoResults) {
    if (result['identifier'] == identifier) {
      String title = result['title'] as String;
      String date;
      if (result['date'] == null) {
        date = DateTime.now().toString().split(" ")[0];
      } else {
        date = result['date'].split('T')[0] as String;
      }
      String creator = result['creator'] as String;
      String mediatype = result['mediatype'] as String;
      String thumbnail = 'https://archive.org/services/img/$identifier';

      return {
        'title': title,
        'date': date,
        'creator': creator,
        'mediatype': mediatype,
        'identifier': identifier,
        'powerpointUrl': powerpointUrl,
        'torrentUrl': torrentUrl,
        'thumbnail': thumbnail
      };
    }
  }

  return null;
}

Future<int> getNumberOfItemsInArchive() async {
  String url =
      'https://archive.org/services/search/v1/scrape?fields=title,mediatype,date,creator&q=collection%3Apptos';

  dynamic itemInfo = await getJson(Uri.parse(url));

  int itemInfoItems = itemInfo['total'] as int;

  return itemInfoItems;
}

void sleep5Minutes() {
  sleep(Duration(minutes: 5));
}
