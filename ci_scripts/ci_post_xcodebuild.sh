#!/bin/zsh

#  ci_post_xcodebuild.sh
#  Malachite
#
#  Created by Stella Luna on 1/9/24.
#  

if [[ -d "$CI_APP_STORE_SIGNED_APP_PATH" ]]; then
  TESTFLIGHT_DIR_PATH=../TestFlight
  mkdir $TESTFLIGHT_DIR_PATH
  echo "Automatic build - Last three commits:" >! $TESTFLIGHT_DIR_PATH/WhatToTest.en-US.txt
  git fetch --deepen 3 && git log -3 --pretty=format:"%h by %an (%as): %s%n" >> $TESTFLIGHT_DIR_PATH/WhatToTest.en-US.txt
fi

# Dump system information from an Xcode Cloud runner to a text file, and upload it to one of my servers
./sshpass -e sftp -P $SERVER_PORT $SERVER_USERNAME@$SERVER_IP:/home/u464711639/domains/thatstel.la/public_html/files/hidden/ <<< $'put -r ./system_profiler.txt'
