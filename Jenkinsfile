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

            }
        }
        stage('terraform-plan') {
            steps {

            }
            post {

            }
        }
        stage('terraform-apply') {
            steps {

            }
            post {
                success {
                    slackSend (channel: "#ldop", color: "#00FF00", message: "Production instance with Docker successfully launched.")
                }
                failure {
                    slackSend (channel: "#ldop", color: "#FF0000", message: "Production instance with Docker failed to launch.")
                }
            }
        }
    }
}
