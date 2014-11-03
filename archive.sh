#!/usr/bin/env bash

VERSION="0.0.4"

### Project Constants (Need to be set by project)

ROOT_DIR="."
APPNAME="##project_name##"
DISPLAY_APPNAME="##app_display_name##"
WORKSPACE="##workspace_name##.xcworkspace"
SCHEME="##scheme_for_archiving##"
PROVPROFILE="##provisioning_profile_for_archiving##"
PLISTFILE="##path_to_info.plist##"
PUBLISH_URL="##publish_url_folder##"

### Constants (Usually need to be set only once)

export COMPANYNAME="##your_company##"
COMPANYEMAIL="##company_email##"
REMOTEPATH="##your_server_remote_path##/${APPNAME}"
TRANSMIT_FAVNAME="##your_transmit_fav##"


### Script Constants

export PUBLISH_PLIST_URL="${PUBLISH_URL}/${APPNAME}.plist"
export PUBLISH_IPA_URL="${PUBLISH_URL}/${APPNAME}.ipa"

RESOURCESPATH="archive_resources"
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
ARCHIVEPATH="$HOME/Desktop/outbox/archive/${APPNAME}"
XCARCHIVEPATH="${ARCHIVEPATH}/${APPNAME}.xcarchive"
IPAARCHIVEPATH="${ARCHIVEPATH}/${APPNAME}.ipa"
PLISTPATH="${RESOURCESPATH}/app.plist"
PLISTARCHIVEPATH="${ARCHIVEPATH}/${APPNAME}.plist"

TEMPLATE_HTML_FILENAME="${RESOURCESPATH}/index_template.html"
HTML_FILENAME="index.html"
HTMLARCHIVEPATH="$ARCHIVEPATH/$HTML_FILENAME"
CSSPATH="${RESOURCESPATH}/css"
CSSARCHIVEPATH="$ARCHIVEPATH/css"
ICONARCHIVEPATH="$ARCHIVEPATH/Icon.png"

greenColor='\x1B[0;32m'
redColor='\x1B[0;31m'
endColor='\x1B[0m'

### Functions

function usage
{
    echo "usage: ./archive.sh [ [-v] [-h] [--version] ]"
}

verbose=0
send_email=0

while [ "$1" != "" ]; do
	case $1 in
		-v | --verbose )	verbose=1
							;;
		-email )			send_email=1
							;;
		--version )			echo $VERSION
							exit
							;;
		-h | --help )		usage
					  		exit
					  	  	;;
		* )            		usage
							exit 1
	esac
	shift
done

### Commands

#### Check required resources are copied into the project folder

if [ ! -d  "${RESOURCESPATH}" ]; then
	echo -e "${redColor} Error: Archive Resources not found. Please copy '${RESOURCESPATH}' folder into the project folder and run the script again.\n${endColor}"
	exit 1
fi

#### Archive
echo "Archiving…"

if [ ! -d "$ARCHIVEPATH" ]; then
	mkdir "$ARCHIVEPATH"
fi

build="xcodebuild -workspace \"$WORKSPACE\" -scheme \"$SCHEME\" -destination generic/platform=iOS archive -archivePath \"$XCARCHIVEPATH\""

[ $verbose -ne 1 ] && build=$build" | egrep -A 5 \"(error|warning):\""

eval $build

rm "$IPAARCHIVEPATH" > /dev/null 2> /dev/null

#### Export
echo "Exporting ipa file…"

archive="xcodebuild -exportArchive -exportFormat ipa -archivePath \"$XCARCHIVEPATH\" -exportPath \"$IPAARCHIVEPATH\" -exportProvisioningProfile \"$PROVPROFILE\""

[ $verbose -ne 1 ] && archive=$archive" > /dev/null"

eval $archive

rm -rf "$XCARCHIVEPATH"

export CURRENT_TIMESTAMP=`date +"%d.%m.%Y %H:%M"`

export APP_VERSION=`/usr/libexec/PlistBuddy -c Print:CFBundleShortVersionString "$PLISTFILE"`

export BUNDLE_ID=`/usr/libexec/PlistBuddy -c Print:CFBundleIdentifier "$PLISTFILE"`

export DISPLAY_APPNAME

#### Request changes

CHANGES=`osascript -e "set changes to the text returned of (display dialog \"What has changed?\" default answer \"Fixes\")
return changes"`

if [ -z "$CHANGES" ];
then
	echo "User Cancelled"
	exit 0
fi

export CHANGES

export COMPANYNAME

#### Fill template & generate html file
echo "Filling templates…"

perl -p -i -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < "${TEMPLATE_HTML_FILENAME}" > "${HTMLARCHIVEPATH}"

### Fill plist file
perl -p -i -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < "${PLISTPATH}" > "${PLISTARCHIVEPATH}"

if [ -f $HTMLARCHIVEPATH ];
then
	#### Copy css files
	cp -R "$CSSPATH" "$CSSARCHIVEPATH"
	
	#### Find Icon & copy to archive
	echo "Finding Icon…"
	
	iconpath=`find $ROOT_DIR -type d -name '*.appiconset' -print | head -n 1`
	if [ -n "$iconpath" ];
	then
		icon=`find ${iconpath} -type f -print0 | xargs -0 ls -1S | head -n 1`
		if [ -n "$icon" ];
		then
			cp "$icon" "$ICONARCHIVEPATH"
		else
			echo -e "${redColor} Error: Icon file not found. Please check that your image asset contains the app icon.\n${endColor}"
		fi
	else
		echo -e "${redColor} Error: Icon file not found. Image assets are required to display the app icon.\n${endColor}"
	fi
fi

if [ -f $IPAARCHIVEPATH ] && [ -f $HTMLARCHIVEPATH ];
then
	
	#### Commit & push changes
	
	if [ -d "$ROOT_DIR/.git" ]
	then
		if [ $verbose -ne 1 ]; then
			git add -A $ROOT_DIR > /dev/null
			git commit -m "$CHANGES"  > /dev/null
			git push  > /dev/null
		else
			git add -A $ROOT_DIR
			git commit -m "$CHANGES"
			git push
		fi
	elif [ -d "$ROOT_DIR/.hg" ]
	then
		if [ $verbose -ne 1 ]; then
			hg addrem $ROOT_DIR  > /dev/null
			hg commit -m "$CHANGES"  > /dev/null
			hg push  > /dev/null
		else
			hg addrem $ROOT_DIR
			hg commit -m "$CHANGES"
			hg push
		fi
	fi
	
	#### Upload with Transmit
	echo "Uploading…"
	
	osascript  -e "
	tell application \"Transmit\"
	set SuppressAppleScriptAlerts to true
	set server to item 1 of (favorites whose name is \"${TRANSMIT_FAVNAME}\")
		tell current tab of (make new document at end)
			connect to server
			tell remote browser
				upload item at path \"${IPAARCHIVEPATH}\" to \"${REMOTEPATH}\" with resume mode overwrite
				upload item at path \"${HTMLARCHIVEPATH}\" to \"${REMOTEPATH}\" with resume mode overwrite
				upload item at path \"${ICONARCHIVEPATH}\" to \"${REMOTEPATH}\" with resume mode overwrite
				upload item at path \"${CSSARCHIVEPATH}\" to \"${REMOTEPATH}\" with resume mode overwrite
				upload item at path \"${PLISTARCHIVEPATH}\" to \"${REMOTEPATH}\" with resume mode overwrite
			end tell
			close remote browser
		end tell
	end tell"
	
	#### Send email

	if [ send_email -eq 1 ];
	then
	echo "Sending email…"
	osascript -e "
	tell application \"Mail\"
		set theMessage to make new outgoing message with properties {subject:\"${APPNAME} ${APP_VERSION} Published\", content:${CHANGES}, visible:true}
		tell theMessage
			make new to recipient with properties {name:\"${COMPANYNAME}\", address:\"${COMPANYEMAIL}\"}
			send
		end tell
	end tell"
	fi
	
	echo -e "${greenColor}Done\n${endColor}"
else
	
	#### Report Error
	
	echo -e "${redColor} Error: no ipa or html file. Run with -v option and check the xcodebuild output. \n${endColor}"
	
	osascript  -e "display alert \"Error archiving ${APPNAME}. No ipa or html file\""
	open $ARCHIVEPATH
fi

tput bel
