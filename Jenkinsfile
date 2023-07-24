pipeline {
  agent any
   stages {
    stage ('Build') {
      steps {
        sh '''#!/bin/bash
        python3.7 -m venv test
        source ./test/bin/activate
        pip install -r requirements.txt
        '''
     }
   }
    stage ('Test') {
      steps {
        sh '''#!/bin/bash
        echo "This is the test stage"
        ''' 
      }
    }
   
     stage('Deploy') {
       steps {
         sh '''#!/bin/bash
         chmod +x ./config.sh
         ./config.sh
         '''          
       } 
     }
    }
  }
