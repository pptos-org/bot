import "package:nyxx/nyxx.dart";
import "dart:io";
import 'package:process_run/shell.dart';
import 'package:dotenv/dotenv.dart';
import 'package:bot/ia.dart';
import 'package:bot/message.dart';

var env = DotEnv(includePlatformEnvironment: true)..load(); // load .env file

// Main function
void main() {
  // Check if token is provided
  if (env['TOKEN'] == null || !env.isDefined('TOKEN')) {
    print(
        'Please provide a token in the .env file in ${Directory.current.path}');
    exit(1);
  }

  // Create new bot instance
  List<Map<String, int>> servers = [
    {
      'server': 879086753099681843,
      'channel': 1066762516543311872
    }, // PPTOS server
    {
      'server': 526053172486078483,
      'channel': 735104834046525443
    } // Project PowerPoint server
  ];

  final bot = NyxxFactory.createNyxxWebsocket(
      env['TOKEN']!,
      GatewayIntents.allUnprivileged |
          GatewayIntents
              .messageContent) // Here we use the privilegied intent message content to receive incoming messages.
    ..registerPlugin(Logging()) // Default logging plugin
    ..registerPlugin(
        CliIntegration()) // Cli integration for nyxx allows stopping application via SIGTERM and SIGKILl
    ..registerPlugin(
        IgnoreExceptions()) // Plugin that handles uncaught exceptions that may occur
    ..connect();

  // Listen to ready event. Invoked when bot is connected to all shards. Note that cache can be empty or not incomplete.

  // listen only to messages from the specified channel in the specified server in the list above

  bot.eventsWs.onReady.listen((IReadyEvent e) {
    print("Ready!");
  });

  Directory.current = '${Directory.current.path}/downloads';

  // Listen to all incoming messages
  bot.eventsWs.onMessageReceived.listen((IMessageReceivedEvent e) async {
    var url, date, user, type, identifier, name;
    bool canRead = false;

    servers.forEach((element) {
      if (e.message.guild?.id == element['server'] &&
          e.message.channel.id == element['channel']) {
        canRead = true;
      }
    });

    if (canRead) {
      if (e.message.attachments.isNotEmpty) {
        e.message.attachments.forEach((attachment) async {
          url = attachment.url;
          user = e.message.author.username;
          identifier = url.split('/').last.split('.')[0];
        });
      }

      // if message contains text
      if (e.message.content.contains('mediafire.com')) {
        url = e.message.content
            .split(' ')
            .where((element) => element.contains('mediafire.com'))
            .toList()[0]
            .split('\n')
            .where((element) => element.contains('mediafire.com'))
            .toList()[0];

        user = e.message.author.username;
      }

      if (e.message.content.contains('cdn.discordapp.com')) {
        url = e.message.content
            .split(' ')
            .where((element) => element.contains('cdn.discordapp.com'))
            .toList()[0]
            .split('\n')
            .where((element) => element.contains('cdn.discordapp.com'))
            .toList()[0];

        user = e.message.author.username;

        identifier = url.split('/').last.split('.')[0];
      }

      if (e.message.content.contains('drive.google.com')) {
        url = e.message.content
            .split(' ')
            .where((element) => element.contains('drive.google.com'))
            .toList()[0]
            .split('\n')
            .where((element) => element.contains('drive.google.com'))
            .toList()[0];

        user = e.message.author.username;
      }

      if (url != null) {
        // name can contain spaces and special characters
        name = url
            .split('/')
            .last
            .replaceAll('%20', ' ')
            .replaceAll('-', ' ')
            .replaceAll('_', ' ')
            .split('.')[0];

        date = e.message.createdAt.toString().split(' ')[0];

        if (e.message.content.contains("user=")) {
          user = e.message.content.split("user=")[1].split(" ")[0];
        }

        if (url.contains("mediafire.com")) {
          type = "mediafire";
        } else if (url.contains("cdn.discordapp.com")) {
          type = "discord";
        } else if (url.contains("drive.google.com")) {
          type = "gdrive";
        }

        print('url: $url, date: $date, user: $user');

        if (type == 'mediafire') {
          Process.run('mediafire-dl', [url])
              .then((ProcessResult results) async {
            var path = results.stderr
                .toString()
                .split('\n')
                .where((element) => element.contains('To: '))
                .toList()[0]
                .split('To: ')[1];

            // if the the last 4 characters of the file name are not in the list of file types to not archive
            if (isFile.image(path.split('/').last) ||
                isFile.video(path.split('/').last)) {
              var filename = path.split('/').last;

              identifier = filename
                  .replaceAll('.', '-')
                  .substring(0, filename.lastIndexOf('.'))
                  .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

              name = path
                  .split('/')
                  .last
                  .replaceAll('-', ' ')
                  .replaceAll('_', ' ');

              await archiveFile(path, identifier, name, date.toString(), user);

              sleep5Minutes();

              replyWith.archivedEmbed(e, "PPTOS-$identifier");
            }
          });
        }

        if (type == 'discord') {
          Process.run('wget', [url]).then((ProcessResult results) async {
            var path = '${Directory.current.path}/${url.split('/').last}';

            if (isFile.image(path.split('/').last) ||
                isFile.video(path.split('/').last)) {
              await archiveFile(path, identifier, name, date.toString(), user);

              sleep5Minutes();

              replyWith.archivedEmbed(e, "PPTOS-$identifier");
            }
          });
        }

        if (type == 'gdrive') {
          name = await gdown.getName(url);
          identifier = name;

          await gdown.download(url, name);

          var path = '${Directory.current.path}/downloads/gdown-$name';

          await archiveFile(path, identifier, name, date.toString(), user);

          await Directory('${Directory.current.path}/downloads/gdown-$name')
              .delete(recursive: true);

          sleep5Minutes();

          replyWith.archivedEmbed(e, "PPTOS-$identifier");
        }
      }
    }
  });
}

Future<void> archiveFile(String path, String identifier, String name,
    String date, String user) async {
  // print the command that will be run

  var shell = Shell();

  await shell.run(
      '''ia upload PPTOS-$identifier "$path" --metadata="mediatype:data" --metadata="title:$name" --metadata="creator:$user" --metadata="collection:pptos" --metadata="subject:pptos" --metadata="subject:PPTOS" --metadata="subject:PowerPoint" --metadata="date:$date"''');

  // delete the file after it's been uploaded

  Process.run('rm', [path]).then((ProcessResult results) {
    print(results.stdout);
    print(results.stderr);
  });
}
