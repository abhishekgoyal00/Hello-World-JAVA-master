pipeline
{
    agent any
    tools
    {
        maven 'Maven3'
    }
    options
    {
        // Append time stamp to the console output.
        timestamps()
      
        timeout(time: 1, unit: 'HOURS')
      
        // Do not automatically checkout the SCM on every stage. We stash what
        // we need to save time.
        skipDefaultCheckout()
      
        // Discard old builds after 10 days or 30 builds count.
        buildDiscarder(logRotator(daysToKeepStr: '10', numToKeepStr: '10'))
      
        //To avoid concurrent builds to avoid multiple checkouts
        disableConcurrentBuilds()
    }
    stages
    {
        stage ('checkout')
        {
            steps
            {
                checkout scm
            }
        }
        stage ('Build')
        {
            steps
            {
                bat "mvn clean install"
            }
        }
        stage ('Unit Testing')
        {
            steps
            {
                bat "mvn test"
            }
        }
        /*stage ('Sonar Analysis')
        {
            steps
            {
                withSonarQubeEnv("Test_Sonar") 
                {
                    bat "mvn sonar:sonar"
                }
            }
        }*/
            stage('Upload to Artifactory') {
            steps {
                rtMavenDeployer(
                    id: 'deployer',
                    serverId: '123456789@artifactory',
                    releaseRepo: 'CI-Automation-JAVA',
                    snapshotRepo: 'CI-Automation-JAVA'
                )
                rtMavenRun(
                    pom: 'pom.xml',
                    goals: 'clean install',
                    deployerId: 'deployer',
                )
                rtPublishBuildInfo(
                    serverId: '123456789@artifactory',
                )
            }
        }
            stage('Docker Image') {
            steps {
                bat returnStdout: true, script: 'docker build -t abhigoyaldev/i-abhishekgoyal-master:%BUILD_NUMBER% -f Dockerfile .'
            }
        }
            stage ('Container - Push to DTR') {         
            steps{  
                withCredentials([string(credentialsId: 'docker-pwd', variable: 'dockerHubPwd')]) {
                    bat returnStdout: true, script: "docker login -u abhigoyaldev -p ${dockerHubPwd}"
                }
                bat returnStdout: true, script: 'docker push abhigoyaldev/i-abhishekgoyal-master:%BUILD_NUMBER%'
            }
        }
           stage('Stop Running container') {
            steps {
                bat '''@echo off for / f "tokens=*" % % i-abhishekgoyal-master in ('docker ps -q --filter "name=abhigoyaldev/i-abhishekgoyal-master"') do docker stop % % i-abhishekgoyal-master && docker rm --force % % i-abhishekgoyal-master || exit / b 0 '''
            }
        }
            stage('Docker deployment') {
            steps {
                bat 'docker run --name i-abhishekgoyal-master -d -p 6000:8080 abhigoyaldev/i-abhishekgoyal-master:%BUILD_NUMBER%'
            }
        }
    }
    /*post {
        always {
            emailext attachmentsPattern: 'report.html', body: '${JELLY_SCRIPT,template="health"}', mimeType: 'text/html', recipientProviders: [
                [$class: 'RequesterRecipientProvider']
            ], replyTo: 'abhishek.goyal@nagarro.com', subject: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!', to: 'abhishek.goyal@nagarro.com'
        }
    }*/ 
}