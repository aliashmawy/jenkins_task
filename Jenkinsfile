pipeline {
    agent any

    environment {
        KUBECONFIG = "/var/jenkins_home/.kube/config"  // use the kubeconfig in the repo
    }

    stages {
        stage('Show kubeconfig info') {
            steps {
                sh 'kubectl config get-contexts'
            }
        }

        stage('Apply Deployment and Service') {
            steps {
                sh '''
                    kubectl apply -f nginx-deployment.yaml
                    kubectl apply -f nginx-service.yaml
                '''
            }
        }
    }
}
