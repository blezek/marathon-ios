

release:
	xcodebuild -configuration Release -sdk iphoneos4.2
	xcodebuild -configuration Release -sdk iphonesimulator4.2

debug:
	xcodebuild -configuration Debug -sdk iphoneos4.2
	xcodebuild -configuration Debug -sdk iphonesimulator4.2

adhoc:
	xcodebuild -configuration AdHocDistribution -sdk iphoneos4.2
	xcodebuild -configuration AdHocDistribution -sdk iphonesimulator4.2


all: release debug adhoc

publish: adhoc
	echo '   Building for iPhone    '
	dd=`date +%Y%m%d`
	rm -rf AlephOneDistribution-$dd
	rm -rf AlephOneDistribution-$dd.zip
	mkdir -p AlephOneDistribution-$dd
	echo '   Building distribution package '
	cp -r build/AdHocDistribution-iphoneos/AlephOne-iPad.app AlephOneDistribution-$dd
	cp ProvisioningProfiles/AlephOne_Ad_Hoc.mobileprovision AlephOneDistribution-$dd
	zip -r AlephOneDistribution-$dd.zip AlephOneDistribution-$dd/
