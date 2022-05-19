pipeline {
    
    agent any
  
    environment{
        CI = true
        ARTIFACTORY_ACCESS_TOKEN = credentials('jenkins-artifactory-access-token')
    }
    
    tools{
        nodejs 'node-lts'
    }
    
    stages {
      
        stage('Installing dependecies'){
            steps{
                sh 'npm install'
            }
        }
      
        stage('snyk testing') {
          steps {
            echo 'Testing...'
            snykSecurity(
              snykInstallation: 'snyk-1',
              snykTokenId: 'snyk-token',
              failOnIssues: false,
              failOnError: false
            )
          }
        }
      
        stage('run build') {
            steps {
                sh 'npm run build'
            }
        }
      
        stage('Create a tar file'){
            steps{
                sh "tar cvzf react-shopping-cart-${BUILD_NUMBER}.tar.gz build"
            }
        }
      
        stage('Upload to Artifactory') {
          agent {
            docker {
              image 'releases-docker.jfrog.io/jfrog/jfrog-cli-v2:2.2.0' 
              reuseNode true
            }
          }
          steps {
            sh "jfrog rt upload --url https://drexxcbba.jfrog.io/artifactory --access-token ${ARTIFACTORY_ACCESS_TOKEN} react-shopping-cart-${BUILD_NUMBER}.tar.gz react-shopping-cart-generic-local/"
          }
        }
      
        stage('Docker Build') {
          steps {
            sh 'docker build -t drexxcbba/docker-react-shopping-cart:latest .'
          }
        }
      
        stage('Testing the container with Snyk') {
          steps{
            snykSecurity( 
              snykInstallation: 'snyk-1', 
              snykTokenId: 'snyk-token', 
              targetFile: 'Dockerfile',
              additionalArguments: '--docker drexxcbba/docker-react-shopping-cart',
              failOnIssues: false,
              failOnError: false
            )
          }
        }
      
        stage('Docker Push') {
          steps {
            withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
              sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPassword}"
              sh 'docker push drexxcbba/docker-react-shopping-cart:latest'
            }
          }
        }
      
        stage('Docker pull & Docker run') {
          steps{
            script{
              def remote = [:]
              remote.name = 'test'
              remote.host = '192.168.0.10'
              remote.user = 'rodrigo'
              remote.password = 'rodrigo24'
              remote.allowAnyHosts = true
              def val1 = sshCommand remote: remote, command: "echo rodrigo24 | sudo -S docker ps -aq -f name=app-react-shopping-cart"
              def val2 = sshCommand remote: remote, command: "echo rodrigo24 | sudo -S docker ps -aq -f status=exited -f name=app-react-shopping-cart"
              if(val1){
                if(!val2){
                  sshCommand remote: remote, command: "echo rodrigo24 | sudo -S docker stop app-react-shopping-cart"
                }
                sshCommand remote: remote, command: "echo rodrigo24 | sudo -S docker rm app-react-shopping-cart"
              }
              sshCommand remote: remote, command: "echo rodrigo24 | sudo -S docker pull drexxcbba/docker-react-shopping-cart"
              sshCommand remote: remote, command: "echo rodrigo24 | sudo -S docker run -d -p 3000:3000 --name app-react-shopping-cart drexxcbba/docker-react-shopping-cart"
            }
          }
        }
    }
    
    post{
        always{
            echo 'Sending Email Notifications'
            script {
                emailext attachLog: true,
                body: "Hello\n\n Pipeline: ${env.JOB_NAME}\nBuild Number: ${env.BUILD_NUMBER}\nStatus: ${currentBuild.currentResult}\n" +
                    "Log file: Attached to this email.\n\n Regards\n\n Jenkins\nCI Server\n\n",
                subject: "Build ${currentBuild.currentResult}: Pipeline ${env.JOB_NAME}", to: 'juanjenkinsmail@gmail.com'
            }
        }
    }
}
