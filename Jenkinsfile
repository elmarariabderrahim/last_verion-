

pipeline {
    agent any 
	 environment {
    		PATH = "C:\\Program Files\\Git\\usr\\bin;C:\\Program Files\\Git\\bin;${env.PATH}"
		 }
		 parameters {
           choice(name: 'CHOIX',
	       choices: ['no_data', 'ddl'],
	       description: '1 : Exportation complete de la DB\n2 : Choix des composants necessaires')
         } 
    stages {
        stage('import_db_to_docker_image') {          
              steps {
		    withCredentials([
					usernamePassword(
						credentialsId: '0467c09c-9a30-4e9f-bdc9-6126fd2482d4', 
						usernameVariable: 'USERNAME',
						passwordVariable: 'PASSWORD'
						
						
					)
			]){
        script{
                    if(CHOIX == 'no_data')
                        bat "sh  ./export_db_no_data.sh ${USERNAME}  ${PASSWORD}"
                    else
                        bat "sh  ./exp_script.sh"
                }
		    }
      }
          
          
          
      }
	  stage('Import_schema_to_docker') {
		    when {
			    CHOIX : 'ddl'
	                }
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
		   withCredentials([
					usernamePassword(
						credentialsId: '0467c09c-9a30-4e9f-bdc9-6126fd2482d4', 
						usernameVariable: 'USERNAME',
						passwordVariable: 'PASSWORD'
						
						
					)
			]){
        	     bat "sh  ./apply_script_in_docker.sh ${USERNAME}  ${PASSWORD}"
		   }
        	              }
        }  
        
   }
}

