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
         python3.7 -m venv test
         source ./test/bin/activate
         git clone https://github.com/KingmanT/Banking_Application.git
         cd ./Banking_Application
         pip install -r requirements.txt
         python database.py
         python load_data.py
         python app.py
         '''          
       } 
     }
    }
  }
