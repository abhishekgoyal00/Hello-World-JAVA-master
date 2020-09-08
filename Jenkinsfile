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
        stage ('Build')
        {
            steps
            {
                checkout scm
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
        stage('Upload to Artifactory') 
        {
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
        stage('Docker Image') 
        {
            steps {
                bat returnStdout: true, script: 'docker build -t dtr.nagarro.com:443/i-abhishekgoyal-master -f Dockerfile .'
            }
        }
        stage('Containers'){
            parallel{
                stage('PrecontainerCheck'){
                    steps{
                        script{
                            containerId = powershell(script:'docker ps --filter name=c-abhishekgoyal-master --format "{{.ID}}"', returnStdout:true, label:'')
                            if(containerId){
                                bat "docker stop ${containerId}"
                                bat "docker rm -f ${containerId}"
                            }
                        }   
                    }
                }
                stage('PushtoDTR'){
                    steps{
                        bat returnStdout: true, script: 'docker push dtr.nagarro.com:443/i-abhishekgoyal-master'
                    }
                }
            }    
        }
        stage('Docker deployment') {
            steps {
                bat 'docker run --name c-abhishekgoyal-master -d -p 6200:8080 dtr.nagarro.com:443/i-abhishekgoyal-master'
            }
        }
        stage('Helm Chart Deployment') {
            steps {
                bat 'kubectl create ns abhishek-master'
                bat 'helm install java-deployment-master my-chart --set image=dtr.nagarro.com:443/i-abhishekgoyal-master -n abhishek-master'
            }
        }
    }
}