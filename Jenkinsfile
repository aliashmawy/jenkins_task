pipeline {
    agent any

    environment {
        KUBECONFIG = "${HOME}/.kube/config" // Adjust path if needed
    }


        stage('Deploy to Minikube') {
            steps {
                sh '''
                    kubectl apply -f deployments.yaml
                    kubectl apply -f NodePort.yaml
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    kubectl get deployments
                    kubectl get svc -o wide
                '''
            }
        }
    }

    post {
        failure {
            echo 'Deployment failed!'
        }
        success {
            echo 'Deployment successful!'
        }
    }
