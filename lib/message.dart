import "package:nyxx/nyxx.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
import 'package:bot/ia.dart';

class replyWith {
  static void archivedEmbed(IMessageReceivedEvent e, String identifier) async {
    var data = await getIdentifierData(identifier);
    if (data != null) {
      print(data);

      final replyBuilder = ReplyBuilder.fromMessage(e.message);
      final allowedMentionsBuilder = AllowedMentions()..allow(reply: false);
      final componentMessageBuilder = ComponentMessageBuilder();
      var componentRow = ComponentRowBuilder();
      // If you dont want to mention user that invoked that command, use AllowedMentions

      if (data["powerpointUrl"] != null) {
        componentRow
          ..addComponent(LinkButtonBuilder("download", data["powerpointUrl"]));
      }

      componentRow
        ..addComponent(LinkButtonBuilder("torrent", data["torrentUrl"]));

      final embed = EmbedBuilder()
        ..addAuthor((author) {
          author.name = data["creator"];
          author.url =
              "https://archive.org/details/pptos?&and[]=creator%3A%22${data["creator"]}%22";
        })
        ..addFooter((footer) {
          footer.iconUrl = "https://archive.org/services/img/pptos";
          footer.text = "pptos";
        });

      embed.imageUrl = data["thumbnail"];
      embed.url = "https://archive.org/details/$identifier";
      embed.timestamp = DateTime.parse(data["date"]);
      embed.title = data["title"];

      componentMessageBuilder.content = "🎉 Your file has been archived!";
      componentMessageBuilder.addComponentRow(componentRow);
      componentMessageBuilder.replyBuilder = replyBuilder;
      componentMessageBuilder.allowedMentions = allowedMentionsBuilder;
      componentMessageBuilder.embeds = [embed];

      await e.message.channel.sendMessage(componentMessageBuilder);
    }
  }
}
