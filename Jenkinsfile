pipeline {
  agent { label 'jenkins-node' }
  environment {
    AWS_REGION = 'us-east-1'
    ECR_REPO   = '123456789012.dkr.ecr.us-east-1.amazonaws.com/porttrack'
  }
  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/org/porttrack.git', branch: 'main'
      }
    }
    stage('Build') {
      steps {
        sh 'docker build -t $ECR_REPO:$BUILD_NUMBER .'
      }
    }
    stage('Test') {
      steps {
        sh './run-tests.sh'
      }
      post {
        always {
          junit '**/test-reports/*.xml'
        }
      }
    }
    stage('Push Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'ecr-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
          sh '$(aws ecr get-login --no-include-email)'
          sh 'docker push $ECR_REPO:$BUILD_NUMBER'
        }
      }
    }
    stage('Deploy to Staging') {
      when { branch 'main' }
      steps {
        sh 'kubectl apply -f k8s/manifests/staging/' 
      }
    }
    stage('Approve Prod') {
      when { branch 'main' }
      steps {
        input message: "Deploy to PRODUCTION?", ok: "Deploy"
      }
    }
    stage('Deploy to Prod') {
      when { branch 'main' }
      steps {
        sh './scripts/deploy_via_codedeploy.sh $BUILD_NUMBER'
      }
    }
  }
  post {
    success {
      slackSend channel: '#deployments', message: "Deploy SUCCESS: Build $BUILD_NUMBER"
    }
    failure {
      slackSend channel: '#deployments', message: "Deploy FAILURE: Build $BUILD_NUMBER"
    }
  }
}