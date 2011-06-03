DEVELOPER = "iPhone Distribution: Daniel Blezek"
BETADIR = ${PWD}/../BetaTestApps/
BUILDDIR = ${PWD}/build/AdHocDistribution-iphoneos/

M1PROFILE = ${PWD}/ProvisioningProfiles/AlephOne_M1_Ad_Hoc.mobileprovision
M2PROFILE = ${PWD}/ProvisioningProfiles/AlephOne_M2_Ad_Hoc.mobileprovision
M3PROFILE = ${PWD}/ProvisioningProfiles/AlephOne_M3_Ad_Hoc.mobileprovision

XB = /Developer4/usr/bin/xcodebuild

DROPBOX_PUBLIC = ${HOME}/Documents/Dropbox/Public

all: release debug adhoc ipa

clean:
	${XB} -alltargets -configuration Release clean
	${XB} -alltargets -configuration Debug clean
	${XB} -alltargets -configuration AdHocDistribution clean

release:
	${XB} -alltargets -configuration Release -sdk iphoneos4.3
	${XB} -alltargets -configuration Release -sdk iphonesimulator4.3

debug:
	${XB} -alltargets -configuration Debug -sdk iphoneos4.3
	${XB} -alltargets -configuration Debug -sdk iphonesimulator4.3

adhoc:
	${XB} -alltargets -configuration AdHocDistribution -sdk iphoneos4.3
	${XB} -alltargets -configuration AdHocDistribution -sdk iphonesimulator4.3


ipa: adhoc
	/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${BUILDDIR}AlephOne-SDG.app" -o "${BETADIR}AlephOne.ipa" --sign ${DEVELOPER} --embed ${M1PROFILE}
	/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${BUILDDIR}AlephOne-SDG-2.app" -o "${BETADIR}AlephOne2.ipa" --sign ${DEVELOPER} --embed ${M2PROFILE}
	/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${BUILDDIR}AlephOne-SDG-3.app" -o "${BETADIR}AlephOneInf.ipa" --sign ${DEVELOPER} --embed ${M3PROFILE}

publish: ipa
	(cd ${BETADIR} && ./BuildDistribution)
	rsync -r "${BETADIR}/M1" ${DROPBOX_PUBLIC}
	rsync -r "${BETADIR}/M2" ${DROPBOX_PUBLIC}
	rsync -r "${BETADIR}/MInf" ${DROPBOX_PUBLIC}
