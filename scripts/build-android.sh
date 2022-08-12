#!/bin/sh

./scripts/build.sh android $1 &&
echo "" &&
echo "Upload new version to https://play.google.com/console/u/2/developers/7747649071507748495/app/4974648599110955771/tracks/4697888902296038538?tab=releases" &&
open build/app/outputs/bundle/release/
