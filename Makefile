
DEVELOPER = "iPhone Distribution: Daniel Blezek"
BETADIR = ${PWD}/../BetaTestApps/
BUILDDIR = ${PWD}/build/AdHocDistribution-iphoneos/

M1PROFILE = ${PWD}/ProvisioningProfiles/AlephOne_M1_Ad_Hoc.mobileprovision
M2PROFILE = ${PWD}/ProvisioningProfiles/AlephOne_M2_Ad_Hoc.mobileprovision
M3PROFILE = ${PWD}/ProvisioningProfiles/AlephOne_M3_Ad_Hoc.mobileprovision

DROPBOX_PUBLIC = ${HOME}/Documents/Dropbox/Public

all: release debug adhoc ipa

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
	(cd ${BETADIR} && ./BuildDistribution)
	rsync -r "${BETADIR}/M1" ${DROPBOX_PUBLIC}
	rsync -r "${BETADIR}/M2" ${DROPBOX_PUBLIC}
	rsync -r "${BETADIR}/MInf" ${DROPBOX_PUBLIC}
