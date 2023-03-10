# running

- First install dart. You can read [here](https://dart.dev/get-dart) how to do so. The bot only works on linux!

- get [mediafire-dl](https://github.com/Juvenal-Yescas/mediafire-dl), [gdown](https://github.com/wkentaro/gdown) and [Internet Archive CLI](https://archive.org/developers/internetarchive/installation.html#binaries). Also make sure you have [zip](https://sourceforge.net/projects/infozip/) installed.

- make an .env file in the root of the bot directory and write TOKEN=YOURTOKEN in it.

- Get all of the dart dependencies (you only need to run this once): `dart pub get`

- Now you can run the bot via `dart bin/main.dart`

# todo

- 0.1.2
	- add / commands
		- get info about an item (search on server)
		- get total items in archive 
		- get user stats
		- take screenshot of powerpoint file (for thumbnail)
		- add powerpoint flag to item (internet archive doesn't do this with most powerpoint type files)

## License
##### **license template made by brutal-org**

<a href="https://opensource.org/licenses/MIT">
  <img align="right" height="96" alt="MIT License" src="https://user-images.githubusercontent.com/58103738/214117133-1491b255-9ae9-4fc2-8134-714e23b813f3.png" />
</a>

The bot is licensed under the **MIT License**.

The full text of the license can be accessed via [this link](https://opensource.org/licenses/MIT) and is also included in the [license](LICENSE) file of this software package.