![Logo](https://s3-eu-west-1.amazonaws.com/buscarini/jjdeploy.png "JJDeploy")

# JJDeploy

Script to deploy iOS apps (enterprise or adhoc). Archives &amp; exports your app as an ipa, commits and pushes your changes (git &amp; hg), generates an html &amp; uploads everything to a server. It can also optionally send an email when the process finishes correctly.

## Requirements

- The app icon must be in an image asset for the script to be able to correctly find it and use it
- For uploading to FTP the password must be stored in the Keychain
- [Xcode Command Line Tools](https://developer.apple.com/xcode/). You can install them using the command:

	`$ xcode-select --install`

## What does it do?

This is the process followed by the script, step by step:

1. Creates the archive path
2. Archives your app to a xcarchive file
3. Exports this archive to an ipa file
4. Asks you for a simple description of the changes made
5. Fills the html template file and generates an html file in the archive path
6. Finds the biggest icon in your image assets, and copies it to the archive path as Icon.png
7. If it finds a git or mercurial repository in your project, it will add any changes, commit using your provided changes, and push
8. Uploads the ipa, the html and the icon to your server

## How to use

JJDeploy uses [homebrew](http://brew.sh "Homebrew — The missing package manager for OS X") for installation. You will need to install it first if you don't have it already.

1. `$ brew tap buscarini/formulae`
2. `$ brew install jjdeploy`

Now you can run this in your project folder:

3. `$ jjdeploy init`

This creates a *jjdeploy.config* that you can fill with your project information.

We recommend that you use [liftoff](https://github.com/thoughtbot/liftoff) or something similar, so you can have your config file populated automatically when creating new projects.

The *jjdeploy_resources* folder contains all the css and html template files. JJDeploy uses the most specific resources folder it can find. You can have a copy in your project path and a global one in *~/.jjdeploy/jjdeploy_resources*. If these are not found then the default copy will be used.

Finally, run *jjdeploy* in your project folder: 

4. `$ jjdeploy`

*Note that you need to store the password in the Keychain before trying to upload to an ftp server*

### Store FTP password in the Keychain

1. Open Keychain
2. Tap +
3. Type whatever you want as the item name (It should match KEYCHAIN_ITEM in your config file)
4. Type the ftp user account (It should match FTPACCOUNT in your config file)
5. Enter the ftp password
6. Save


### Update

This is the command to update JJDeploy to the latest version:

`$ brew update && brew upgrade jjdeploy`

Be aware that until we reach version 1.0 any update might contain breaking changes, and you might need to update your existing config files.

## Additional Options

You can run jjdeploy with these parameters:

> *init* (Without any additional parameters: jjdeploy init). Creates a template config file with the name jjdeploy.config in the current directory

> *init resources* (Without any additional parameters: jjdeploy init resources). This creates a local directory with the resources used in the website. This allows to have different css/image files and to customize the html

> *upload* This will only upload a previous archive, without requiring to build and archive again.

> *-v (or --verbose)* will display all the xcodebuild output

> *-email* will send an email with the changes to the company email address in the script

> *-noemail* will avoid sending the email even if the config contains the information

> *--version* Displays the current script version

> *-h* Displays usage instructions

## Creators

- José Manuel Sánchez ([@buscarini](https://twitter.com/buscarini))
- Javier Querol ([@JavierQuerol](https://twitter.com/JavierQuerol))

## License

JJDeploy is released under the MIT license. See LICENSE for details.
