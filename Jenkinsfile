pipeline {
    agent { node { label 'docker_image' } }

    options {
        disableConcurrentBuilds()
    }

    stages {
        stage('Build Zeppelin image') {
            steps {
                script {
                    sh "docker build -t saagie/zeppelin-nbk:v2 ."
                }
            }
        }

        stage('Push techno images') {
            steps {
                script {
                    withCredentials(
        [usernamePassword(credentialsId: '8fc4964e-30c6-4bb9-8a19-69e37ea905b6',
                usernameVariable: 'USERNAME',
                passwordVariable: 'PASSWORD')]) {

                        sh "docker login -u $USERNAME -p $PASSWORD"
                        sh "docker push saagie/zeppelin-nbk:v2"
                    }
                }
            }
        }
    }
}
