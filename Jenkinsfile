/* LDOP-296 LDOP Deployment Infrastructure */

pipeline {
    agent {
      docker {
        image "hashicorp/terraform:latest"
      }
    }
    stages {
        stage('terraform-lint') {
            steps {
                sh 'terraform validate'
            }
        }
        stage('terraform-plan') {
            steps {
                sh 'terraform plan > output'
                script {
                    planOutput = readFile('output')
                    /* do something with output */
                }
            }
            post {
                /* send something to Slack */
            }
        }
        stage('terraform-apply') {
            steps {
                sh 'terraform apply'
            }
            post {
                success {
                    slackSend (channel: "#ldop", color: "#00FF00", message: "Production instance successfully launched.")
                }
                failure {
                    slackSend (channel: "#ldop", color: "#FF0000", message: "Production instance failed to launch.")
                }
            }
        }
    }
}
