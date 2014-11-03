# JJDeployer

Script to deploy iOS apps (enterprise or adhoc). Builds, archives, generates an html &amp; uploads everything to a server (Requires Transmit).

## Requirements

- The app Icon must be in an image asset for the script to be able to correctly find it and use it
- [Transmit](http://panic.com/transmit/) is required to upload the files to a sever, but you can change the script to use a different method.
- Xcode & xcodebuild. This script has been tested with Xcode 6.1 (6A1052d), but it should work with older versions of Xcode too.

## How to use

1. Copy archive.sh to your project folder
2. Open archive.sh and modify the project constants according to your project
3. Open Terminal and run (from the project folder): ./archive.sh

## Additional Options

You can run archive.sh with these parameters:

-v (--verbose) will display all the xcodebuild output

## Creators

- José Manuel Sánchez ([@buscarini](https://twitter.com/buscarini))
- Javier Querol ([@JavierQuerol](https://twitter.com/JavierQuerol))

## License

JJDeployer is released under the MIT license. See LICENSE for details.