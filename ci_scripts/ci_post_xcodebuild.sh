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

defaults read com.apple.dt.Xcode >> /tmp/defaults_xcode.txt
defaults read com.apple.CoreSimulator >> /tmp/defaults_coresim.txt
