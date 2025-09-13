# gradle build -x lint
# gradle build -PdisableReleaseLint

SDK_BUILD_TOOLS ?= $(HOME)/Android/Sdk/build-tools/30.0.3

ZIPALIGN = $(SDK_BUILD_TOOLS)/zipalign
APKSIGNER = $(SDK_BUILD_TOOLS)/apksigner

JKS_FILE = my-release-key.jks
MY_ALIAS = my-alias
APK_FILE_UNSIGNED = app/build/outputs/apk/release/app-release-unsigned.apk
APK_FILE_SIGNED = app/build/outputs/apk/release/app-release-signed.apk
APK_FILE_ALIGNED = app/build/outputs/apk/release/app-release-aligned.apk

all:
	./gradlew build -x lint
	@$(MAKE) listapk

listapk:
	ls -l app/build/outputs/apk/*/*.apk

clean:
	$(RM) -r app/build
	$(RM) -r build

$(JKS_FILE):
	keytool -genkeypair -v \
		-keystore $(JKS_FILE) -keyalg RSA -keysize 2048 -validity 10000 \
		-alias $(MY_ALIAS) < keytool-input.txt

signlegacy: $(JKS_FILE)
	$(RM) $(APK_FILE_SIGNED)
	echo 123456 | jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
		-keystore $(JKS_FILE) \
		-signedjar $(APK_FILE_SIGNED) \
		$(APK_FILE_UNSIGNED) \
		$(MY_ALIAS)

zipalign:
	$(ZIPALIGN) -f 4 $(APK_FILE_SIGNED) $(APK_FILE_ALIGNED)

signmodern:
	$(APKSIGNER) sign \
		--ks $(JKS_FILE) \
		--ks-key-alias $(MY_ALIAS) \
		--out $(APK_FILE_SIGNED) \
		$(APK_FILE_UNSIGNED)
