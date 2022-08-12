#!/bin/sh

./scripts/build.sh prod ios $1 &&
echo "" &&
echo "Run the following to upload: " &&
echo "xcrun altool --upload-app --type ios -f build/ios/ipa/legumo.ipa --apiKey KF8UP9GAN9 --apiIssuer ac246c3d-529d-4eee-ac19-0a669b27790e" &&
echo "" &&
echo "After that, do the following:" &&
echo "1. Accept the ipa: https://appstoreconnect.apple.com/apps/1589305379/testflight/ios" &&
echo "  Answer 'Yes' to the first question (uses cryptography) and 'No' to the following one (Export Compliance Information, custom cryptography and besides Apple's)" &&
echo "2. Release: https://appstoreconnect.apple.com/apps/1589305379/appstore/ios/version/inflight"
