import "package:nyxx/nyxx.dart";
import "dart:io";

const String TOKEN =
    "MTA2NjQzNDIxMzcxODU0NDQ3Ng.Ghq3vW.LcT3Lcp9D0J9wElyG4PP4tdT4HpJoQGwICuLYM";

// Main function
void main() {
  // Create new bot instance
  final bot = NyxxFactory.createNyxxWebsocket(
      TOKEN,
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
  bot.eventsWs.onReady.listen((e) {
    print("Ready!");
  });

  Directory.current = '${Directory.current.path}\\downloads';

  // Listen to all incoming messages
  bot.eventsWs.onMessageReceived.listen((e) {
    var url, date, user, type;

    if (e.message.attachments.isNotEmpty) {
      e.message.attachments.forEach((attachment) async {
        url = attachment.url;
        date = attachment.createdAt;
        user = e.message.author.username;
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

      date = e.message.createdAt;

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

      date = e.message.createdAt;

      user = e.message.author.username;
    }

    if (e.message.content.contains('drive.google.com')) {
      url = e.message.content
          .split(' ')
          .where((element) => element.contains('drive.google.com'))
          .toList()[0]
          .split('\n')
          .where((element) => element.contains('drive.google.com'))
          .toList()[0];

      date = e.message.createdAt;

      user = e.message.author.username;
    }
    if (url != null) {
      if (url.contains("mediafire.com")) {
        type = "mediafire";
      } else if (url.contains("cdn.discordapp.com")) {
        type = "discord";
      } else if (url.contains("drive.google.com")) {
        type = "gdrive";
      }

      print('url: $url, date: $date, user: $user');
    }

    // go to the downloads directory native in dart
  });
}
