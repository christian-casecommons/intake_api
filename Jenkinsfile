node {
    checkout scm
    def branch = env.BRANCH_NAME ?: 'master'
    def curStage = 'Start'
    def emailList = EMAIL_NOTIFICATION_LIST ?: 'thomas.ramirez@osi.ca.gov'

    try {
        stage('Test') {
            curStage = 'Test'
//            sh 'make test'
        }
    
        stage('Publish') {
            curStage = 'Publish'
//            withEnv(["DOCKER_USER=${DOCKER_USER}",
//                     "DOCKER_PASSWORD=${DOCKER_PASSWORD}",
//                     "FROM_JENKINS=yes"]) {
//                sh './bin/publish_image.sh'
//            }
        }

        stage('Check Swagger') {
            def HOSTNAME = 'https://ci.mycasebook.org'
            def JOB_URL = "${HOSTNAME}/job/${env.JOB_NAME}/lastSuccessfulBuild/api/json?depth=1"
            def gitPreviousCommit = sh(returnStdout: true, script: /curl $JOB_URL -u ${JENKINS_CREDENTIALS} | grep -o lastBuiltRevision[^,]* | head -1 | cut -d '"' -f 5/)

            def gitCommit = sh(returnStdout: true, script: 'git rev-parse HEAD')
            sh "echo gitCommit ' ${gitCommit} '"
            sh "echo gitPreviousCommit ' ${gitPreviousCommit} '"
            def changedFiles = sh(
              script: "git diff --stat ${gitPreviousCommit} ${gitCommit} | grep '\\|' | awk '{print \$1}'",
              returnStdout: true)
            def environment = sh(
              script: "env",
              returnStdout: true)

            if(changedFiles.indexOf("swagger") != -1) {
                emailext (
                    to: 'thomas.ramirez@osi.ca.gov',
                    subject: "Swagger file updated for Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                    body: """<p>Notification: Swagger file updated</p>
                        <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>"""
                )
            } else {
                emailext (
                    to: 'thomas.ramirez@osi.ca.gov',
                    subject: "Swagger file not updated for Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                    body: """<p>changedFiles: ${changedFiles}</p>
                        <p>GIT_PREVIOUS_COMMIT: ${env.GIT_PREVIOUS_COMMIT}</p>
                        <p>GIT_COMMIT: ${gitCommit}</p>
                        <p>GIT_AUTHOR_NAME: ${env.GIT_AUTHOR_NAME}</p>
                        <p>GIT_URL: ${env.GIT_URL}</p>"""
                )
            }
        }

        stage('Deploy') {
            curStage = 'Deploy'
//            sh "printf \$(git rev-parse --short HEAD) > tag.tmp"
//            def imageTag = readFile 'tag.tmp'
//            build job: DEPLOY_JOB, parameters: [[
//                $class: 'StringParameterValue',
//                name: 'IMAGE_TAG',
//                value: 'cwds/intake_api_prototype:' + imageTag
//            ]]
        }
    }
    catch (e) {
         emailext (
            to: emailList,
            subject: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' in stage ${curStage}",
            body: """<p>FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' in stage '${curStage}' for branch '${branch}':</p>
                <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>
                <p>${e}</p>"""
        )

//        slackSend (color: '#FF0000', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' in stage '${curStage}' for branch '${branch}' (${env.BUILD_URL})")
    }
    finally {
        stage('Clean') {
            retry(1) {
                sh 'make clean'
            }
        }
    }
}
