
DEVELOPER = "iPhone Distribution: Daniel Blezek"
BETADIR = "${PWD}/../BetaTestApps/"
BUILDDIR = "${PWD}/build/AdHocDistribution-iphoneos/"

M1PROFILE = "${PWD}/ProvisioningProfiles/AlephOne_M1.mobileprovision"
M2PROFILE = "${PWD}/ProvisioningProfiles/AlephOne_M2.mobileprovision"
M3PROFILE = "${PWD}/ProvisioningProfiles/AlephOne_M3.mobileprovision"

all: release debug adhoc

clean:
	xcodebuild -alltargets -configuration Release clean
	xcodebuild -alltargets -configuration Debug clean
	xcodebuild -alltargets -configuration AdHocDistribution clean

release:
	xcodebuild -alltargets -configuration Release -sdk iphoneos4.2
	xcodebuild -alltargets -configuration Release -sdk iphonesimulator4.2

debug:
	xcodebuild -alltargets -configuration Debug -sdk iphoneos4.2
	xcodebuild -alltargets -configuration Debug -sdk iphonesimulator4.2

adhoc:
	xcodebuild -alltargets -configuration AdHocDistribution -sdk iphoneos4.2
	xcodebuild -alltargets -configuration AdHocDistribution -sdk iphonesimulator4.2


ipa: adhoc
	/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${BUILDDIR}AlephOne-SDG.app" -o "${BETADIR}AlephOne.ipa" --sign ${DEVELOPER} --embed ${M1PROFILE}
	/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${BUILDDIR}AlephOne-SDG-2.app" -o "${BETADIR}AlephOne2.ipa" --sign ${DEVELOPER} --embed ${M2PROFILE}
	/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${BUILDDIR}AlephOne-SDG-3.app" -o "${BETADIR}AlephOneInf.ipa" --sign ${DEVELOPER} --embed ${M3PROFILE}

publish: ipa
	echo '   Building for iPhone    '
	dd=`date +%Y%m%d`
	rm -rf AlephOneDistribution-$dd
	rm -rf AlephOneDistribution-$dd.zip
	mkdir -p AlephOneDistribution-$dd
	echo '   Building distribution package '
	cp -r build/AdHocDistribution-iphoneos/AlephOne-iPad.app AlephOneDistribution-$dd
	cp ProvisioningProfiles/AlephOne_Ad_Hoc.mobileprovision AlephOneDistribution-$dd
	zip -r AlephOneDistribution-$dd.zip AlephOneDistribution-$dd/
