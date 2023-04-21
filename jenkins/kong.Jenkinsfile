pipeline{   
   agent any
   stages {
        //Checkout Git Repo
        stage('Checkout') {
            steps {
                pwd()
                git  url: 'https://github.com/rk23597/ApiOps.git', branch: 'master'
            }
        }
        //Install Insomnia CLI
        stage('Install Insomnia CLI') {
            steps {
                sh '''wget https://github.com/Kong/insomnia/releases/download/lib%403.12.0/inso-linux-3.12.0.tar.xz
                      tar -xf inso-linux-3.12.0.tar.xz'''
            }
        }        
        //Lint the OpenAPI spec using Insomnia CLI
        stage('Lint OpenAPI Spec') {
            steps {
                sh './inso lint spec ./openSpec/mockAPI.yml'
            }
        }
        //Generate Kong configuration in declarative format
        stage('Generate Kong configuration in declarative format') {
            steps {
                sh './inso generate config ./openSpec/mockAPI.yml --type declarative -o ./openSpec/mockAPI-declarative.yml'
            }
        }
        //Display the contents of the generated Kong configuration
        stage('open kong.yaml') {
            steps {
                sh 'cat ./openSpec/mockAPI-declarative.yml'
            }
        }
        //Display the contents of the generated Kong configuration
        stage('install deck CLI') {
            steps {
                sh '''curl -sL https://github.com/kong/deck/releases/download/v1.17.2/deck_1.17.2_linux_amd64.tar.gz -o deck.tar.gz
                      tar -xf deck.tar.gz -C /tmp'''            
            }
        }
        //Validate the Kong configuration using deck CLI
        stage('Validate the Kong configuration using deck CLI') {
            steps {
                sh '/tmp/deck validate -s ./openSpec/mockAPI-declarative.yml'
            }
        }
        //Convert the Kong configuration to version 3.x using deck CLI
        stage('Convert kong declarative') {
            steps {
                
                sh '/tmp/deck convert --from kong-gateway-2.x --to kong-gateway-3.x --input-file ./openSpec/mockAPI-declarative.yml --output-file ./openSpec/mockAPI-declarative-3x.yml'
            }
        } 
        //Convert the Kong configuration to version 3.x using deck CLI
        stage('Deploy to Kong') {
            steps {
                sh '/tmp/deck sync -s ./openSpec/mockAPI-declarative-3x.yml --kong-addr http://34.125.213.153:8001 --tls-skip-verify'
            }
        }
   }
   post {
        always {
          deleteDir()
       }
    }
}