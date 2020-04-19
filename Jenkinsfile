pipeline {
    agent any 
	 environment {
    		PATH = "C:\\Program Files\\Git\\usr\\bin;C:\\Program Files\\Git\\bin;${env.PATH}"
		 }
    stages {
        stage('generate_DDL') {
            steps {
		    
        	     bat 'sh -c ./exp_script.sh '
		    
		    
            
          }
      }
	  stage('Import_schema_to_docker') {
            steps {
		   	withCredentials([
					usernamePassword(
						credentialsId: '0467c09c-9a30-4e9f-bdc9-6126fd2482d4', 
						usernameVariable: 'USERNAME',
						passwordVariable: 'PASSWORD'
						
						
					)
			]){
        	     bat "sh  ./import_db_docker_image.sh ${USERNAME}  ${PASSWORD}"
		    }
		    
        	      
		    
		   
        	              }
        }  
	    stage('apply_script_in_docker') {
            steps {
		   
        	     bat "sh  ./apply_script_in_docker.sh.sh ${USERNAME}  ${PASSWORD}"
		    
		    
        	      
		    
		   
        	              }
        }  
        
   }
}
