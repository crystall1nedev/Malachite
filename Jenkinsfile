pipeline {
    agent { label 'j773gap' }
    
    options {
        disableConcurrentBuilds(abortPrevious: true)
        disableRestartFromStage()
        timestamps()
    }

    environment {
        APP_ID         = credentials("9499df17-005d-4452-b2f9-007839cddaf5")
        BETA_GROUP_DEV = credentials("b615275d-d95c-4aa4-9764-c1883441bc51")
        BETA_GROUP_ALL = credentials("4e0c16ce-bac1-4e49-b2ea-3877bd4cc48e")
        KEYCHAIN_PASS  = credentials("6096f5d5-d70d-48ce-b8e7-c2058889cd33")
        KEYCHAIN       = credentials("ac8c08eb-7fb6-4cc6-85c4-eaef21b80daa")
        WEBHOOK_URL    = credentials("d3c23c9c-720c-49ba-9f8d-01e045a3c9b9")
    }

    stages {
        stage('Setup Environment') {
            steps {
                script {
                    discordSend(
                        customUsername: "crystll1ne jenkins",
                        title: "${env.JOB_NAME} started",
                        description: "Build #${env.BUILD_NUMBER} on branch ${env.BRANCH_NAME} started.",
                        link: env.BUILD_URL,
                        result: "SUCCESS",
                        webhookURL: env.WEBHOOK_URL
                    )
                    
                    env.VERSION = sh(
                        script: '''
                        xcodebuild -showBuildSettings | \
                        grep "^    MARKETING_VERSION =" | \
                        sed 's/.*= //'
                        ''',
                        returnStdout: true
                    ).trim()

                    env.BUILD_NUM = sh(
                        script: """
                        /opt/homebrew/bin/asc builds next-number \
                          --app-id \$APP_ID \
                          --version \$VERSION \
                          --platform ios
                        """,
                        returnStdout: true
                    ).trim()
                    
                    def branchName = env.BRANCH_NAME

                    def configMap = [
                        'dev'        : 'Internal',
                        'milestone'  : 'Debug',
                        'rel'        : 'Release'
                    ]
                    
                    env.CONFIG = configMap.find { branchName.startsWith(it.key) }?.value ?: 'Unknown'
                    
                    env.NOTES = sh(
                        script: '''
                        echo "For information on what to test in this build, join the Discord @ https://discord.crystall1ne.dev."
                        echo "Otherwise, here's the latest three commits:"
                        echo ""
                        git fetch --deepen 3 && git log -3 --pretty=format:"%h by %an (%as): %s%n"
                        ''',
                        returnStdout: true
                    ).trim()
                    
                    echo "Version: ${env.VERSION}"
                    echo "Build Number: ${env.BUILD_NUM}"
                    echo "Branch: ${branchName}, CONFIG: ${CONFIG}"
                }
            }
        }

        stage('Archive mlchtCamera') {
            steps {
                script {
                    sh """
                    cp mlchtCamera/Codesigning{.example,}.xcconfig
                    sed -i'' -e 's/Automatic/Manual/g' mlchtCamera/Codesigning.xcconfig
                    """
                    
                    xcodeBuild(
                        appURL: '',
                        assetPackManifestURL: '',
                        buildDir: '',
                        buildIpa: true,
                        bundleID: 'dev.crystll1ne.mlchtcamera',
                        bundleIDInfoPlistPath: 'mlchtCamera/Info.plist',
                        cfBundleShortVersionStringValue: "${env.VERSION}",
                        cfBundleVersionValue: "${env.BUILD_NUM}",
                        cleanBeforeBuild: true,
                        cleanResultBundlePath: true,
                        configuration: "${env.CONFIG}",
                        developmentTeamID: 'FBT742498U',
                        developmentTeamName: '',
                        displayImageURL: '',
                        fullSizeImageURL: '',
                        generateArchive: true,
                        ipaName: 'mlchtCamera',
                        ipaExportMethod: 'app-store',
                        ipaOutputDirectory: '..',
                        keychainId: '',
                        keychainPath: '/Volumes/BigDingus/Services/jenkins-eva/Library/Keychains/Login.keychain-db',
                        keychainPwd: hudson.util.Secret.fromString(env.KEYCHAIN_PASS),
                        logfileOutputDirectory: '',
                        provisioningProfiles: [
                            [provisioningProfileAppId: 'dev.crystll1ne.mlchtcamera',
                             provisioningProfileUUID: 'dev.crystll1ne.mlchtcamera AppStore'],
                            [provisioningProfileAppId: 'dev.crystll1ne.mlchtcamera.watchremote',
                             provisioningProfileUUID: 'dev.crystll1ne.mlchtcamera.watchremote AppStore'],
                            [provisioningProfileAppId: 'dev.crystll1ne.mlchtcamera.widgetbundle',
                             provisioningProfileUUID: 'dev.crystll1ne.mlchtcamera.widgetbundle AppStore'],
                            [provisioningProfileAppId: 'dev.crystll1ne.mlchtcamera.capturebundle',
                             provisioningProfileUUID: 'dev.crystll1ne.mlchtcamera.capturebundle AppStore'],
                            [provisioningProfileAppId: 'dev.crystll1ne.mlchtcamera.watchremote.widgetbundle',
                             provisioningProfileUUID: 'dev.crystll1ne.mlchtcamera.watchremote.widgetbundle AppStore']
                        ],
                        resultBundlePath: '',
                        sdk: '',
                        signingMethod: 'manual',
                        symRoot: '',
                        target: '',
                        thinning: '',
                        unlockKeychain: true,
                        xcodeProjectFile: '',
                        xcodeProjectPath: '',
                        xcodeSchema: 'mlchtCamera',
                        xcodeWorkspaceFile: '',
                        xcodebuildArguments: "-verbose CURRENT_PROJECT_VERSION=${env.BUILD_NUM} BRANCH_NAME=${env.BRANCH_NAME}"
                    )
                }
            }
        }
        
        stage('Upload IPA to Destinations') {
            parallel {
                stage('Upload to ASC') {
                    when {
                        expression { env.CHANGE_ID == null }
                    }
                    steps {
                        script {
                            env.UPLOAD_ID = sh(
                                script: """
                                /opt/homebrew/bin/asc builds upload \
                                  --app-id \$APP_ID \
                                  --file 'build/mlchtCamera.ipa' \
                                  --version \$VERSION \
                                  --build-number \$BUILD_NUM \
                                  --wait | \
                                  jq -r --arg build "\$BUILD_NUM" \
                                  '.data[] | select(.buildNumber==\$build) | .id'
                                """,
                                returnStdout: true
                            ).trim()

                            echo "Upload ID: ${env.UPLOAD_ID}"
                        }
                    }
                
                }

                stage('Upload to Jenkins') {
                    steps {
                        archiveArtifacts artifacts: 'build/*.ipa', fingerprint: true
                    }
                }
            }
        }

        stage('Finish ASC Setup and Submit') {
            when {
                expression { env.CHANGE_ID == null }
                expression { env.UPLOAD_ID != null }
                expression { env.UPLOAD_ID != ""   }
            }
            steps {
                script {
                    sh """
                    /opt/homebrew/bin/asc builds add-beta-group \
                      --build-id \$UPLOAD_ID \
                      --beta-group-id \$BETA_GROUP_DEV
                    """
                    
                    if (!BRANCH_NAME.contains("dev")) {
                        sh """
                        /opt/homebrew/bin/asc builds add-beta-group \
                          --build-id \$UPLOAD_ID \
                          --beta-group-id \$BETA_GROUP_ALL
                        """
                    }
                    
                    sh """
                    /opt/homebrew/bin/asc builds update-beta-notes \
                      --build-id \$UPLOAD_ID \
                      --locale en-US \
                      --notes "\$NOTES"
                    """
                                
                    sh """
                    /opt/homebrew/bin/asc beta-review submissions create \
                      --build-id \$UPLOAD_ID
                    """
                }
            }
        }
    }
    
    post {
        always {
            discordSend(
                customUsername: "crystll1ne jenkins",
                title: "${env.JOB_NAME} finished",
                description: "Build ${env.BUILD_NUMBER} on branch ${env.BRANCH_NAME} finished with result: ${currentBuild.result}",,
                enableArtifactsList: true,
                link: env.BUILD_URL,
                result: currentBuild.result,
                webhookURL: env.WEBHOOK_URL
            )
        }
    }
}
