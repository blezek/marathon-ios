

release:
	xcodebuild -alltargets -configuration Release -sdk iphoneos4.2
	xcodebuild -alltargets -configuration Release -sdk iphonesimulator4.2

debug:
	xcodebuild -alltargets -configuration Debug -sdk iphoneos4.2
	xcodebuild -alltargets -configuration Debug -sdk iphonesimulator4.2

adhoc:
	xcodebuild -alltargets -configuration AdHocDistribution -sdk iphoneos4.2
	xcodebuild -alltargets -configuration AdHocDistribution -sdk iphonesimulator4.2


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
