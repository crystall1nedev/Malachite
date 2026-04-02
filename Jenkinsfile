pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                sh '''cd ${WORKSPACE}
                    mv mlchtCamera/Codesigning.example.xcconfig mlchtCamera/Codesigning.xcconfig
                    xcodebuild -project mlchtCamera.xcodeproj -target mlchtCamera -configuration Internal CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
                    mkdir build/Payload && mv build/Internal-iphoneos/mlchtCamera.app build/Payload/mlchtCamera.app
                    cd build && zip -r Payload.ipa Payload/
                    cd ..'''
                archiveArtifacts artifacts: 'build/Payload.ipa', fingerprint: true
            }
        }
    }
}
