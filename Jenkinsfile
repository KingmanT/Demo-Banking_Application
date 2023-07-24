pipeline {
  agent any
   stages {
    stage ('Build') {
      steps {
        sh '''#!/bin/bash
        python3.7 -m venv test
        source ./test/bin/activate
        pip install -r requirements.txt
        python database.py
        python load_data.py
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
         ./config.sh
         '''          
       } 
     }
    }
  }
