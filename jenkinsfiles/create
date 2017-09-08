pipeline {
    agent {
      docker {
        image "hashicorp/terraform:latest"
      }
    }
    stages {
        stage('terraform-lint') {
            steps {
                slackSend (channel: "#ldop", color: "#3AA552", message: "Beginning Terraform pipeline for:\n${env.GIT_COMMIT}.\n${env.JOB_URL}")
                sh 'terraform validate'
            }
            post {
                success {
                    slackSend (channel: "#ldop", color: "#3AA552", message: "Terraform validation succeeded.\n${env.JOB_URL}")
                }
                failure {
                    slackSend (channel: "#ldop", color: "#CF1318", message: "Terraform validation failed.\n${env.JOB_URL}")
                }
            }
        }
        stage('terraform-plan') {
            steps {
                sh 'terraform plan'
            }
            post {
                success {
                    slackSend (channel: "#ldop", color: "#3AA552", message: "Terraform plan was successful.\n${env.JOB_URL}")
                }
                failure {
                    slackSend (channel: "#ldop", color: "#CF1318", message: "Terraform plan failed.\n${env.JOB_URL}")
                }
            }
        }
        stage('terraform-apply') {
            when {
              expression { env.BRANCH_NAME == 'master' }
            }
            steps {
                slackSend (channel: "#ldop", color: "#FFA500", message: "Terraform needs permission to continue.\n${env.JOB_URL}")
                input 'Apply changes?'
                sh 'terraform apply'
            }
            post {
                success {
                    slackSend (channel: "#ldop", color: "#3AA552", message: "Production instance successfully launched.\n${env.JOB_URL}")
                }
                failure {
                    slackSend (channel: "#ldop", color: "#CF1318", message: "Production instance failed to launch.\n${env.JOB_URL}")
                }
            }
        }
    }
}
