#!/bin/bash
#----------------------------------------------------------------------------------------------
# Nom : 			   	environnement_config.sh
# Développeur :			JEL
# Description de la procédure:	Script de configuration des variables globale d'environnement
#				    	 
# 
#----------------------------------------------------------------------------------------------

## racine appli
export RACINE_APPLI=/appli

## chemin vers le dossier des scripts sh
export SCRIPTS_PATH=$RACINE_APPLI/scripts

## chemin vers le fichier de version contenant le numéro du build en cours
##if [[ $PLATEFORME = *"INT"* ]]; then
	export VERSION_INCREMENT_FILE=$SCRIPTS_PATH/$PLATEFORME/$VERSION_NUMBER
##else
##	export VERSION_INCREMENT_FILE=$SCRIPTS_PATH/$VERSION_NUMBER
##fi

## Valeur du numero de build actuel
if [[ -f $VERSION_INCREMENT_FILE ]]; then
	export CURRENT_INCREMENT=`cat $VERSION_INCREMENT_FILE`
else 
	##if [[ $PLATEFORME = *"INT"* ]]; then
	mkdir -p $SCRIPTS_PATH/$PLATEFORME
	##fi
	export CURRENT_INCREMENT=0
fi

## chemin vers le dossier global de deploiement
export DEPLOYMENT_DIRECTORY=/appli/deployment

## chemin vers le sous dossier sql du dossier de deploiement
export SQL_DEPLOYMENT_DIRECTORY=${DEPLOYMENT_DIRECTORY}/sql

## chemin vers le dossier de deploiement des binaires de type ear
export EAR_BINARIES_TOP_DIRECTORY=/appli/deployment/ear

## chemin vers le dossier de deploiement des binaires de Jobminute
export JOBMINUTE_BINARIES_TOP_DIRECTORY=/appli/deployment/jobminute

## chemin vers le dossier de deploiement des binaires de type ear de la plateforme, branche en cours
export EAR_BINARIES_DIRECTORY_PLATEFORME=$EAR_BINARIES_TOP_DIRECTORY/${PLATEFORME}

## chemin vers le dossier de deploiement des binaires de jobminute de la plateforme, branche en cours
export JOBMINUTE_BINARIES_DIRECTORY_PLATEFORME=$JOBMINUTE_BINARIES_TOP_DIRECTORY/${PLATEFORME}

## chemin vers le dossier de deploiement des binaires de type ear de la plateforme, branche et la version en cours
#/appli/deployment/ear/INT2/release/6.2.4
export EAR_BINARIES_DIRECTORY=${EAR_BINARIES_DIRECTORY_PLATEFORME}/${VERSION_NUMBER}

## chemin vers le dossier de deploiement des binaires de jobminute de la plateforme, branche et la version en cours
#/appli/deployment/jobminute/INT2/release/6.2.4
export JOBMINUTE_BINARIES_DIRECTORY=${JOBMINUTE_BINARIES_DIRECTORY_PLATEFORME}/${VERSION_NUMBER}

## chemin vers le dossier de deploiement des binaires de Services
#export EAR_BINARIES_DIRECTORY_PATT="${EAR_BINARIES_DIRECTORY}/${JOB_NAME/$KEY_TO_REPLACE/$REPLACEMENT}/Patt"
export EAR_BINARIES_DIRECTORY_PATT="${EAR_BINARIES_DIRECTORY}/Patt"

## chemin vers le dossier de deploiement des binaires de MyPixid
#export EAR_BINARIES_DIRECTORY_MYPIXID="${EAR_BINARIES_DIRECTORY}/${JOB_NAME/$KEY_TO_REPLACE/$REPLACEMENT}/MyPixid"
export EAR_BINARIES_DIRECTORY_MYPIXID="${EAR_BINARIES_DIRECTORY}/MyPixid"

## chemin vers le dossier de deploiement des binaires de Job Minute SPA
export EAR_BINARIES_DIRECTORY_JOBMINUTE="${JOBMINUTE_BINARIES_DIRECTORY}/spa"

## chemin vers le dossier de deploiement des binaires de Orchestrator tracker SPA
export EAR_BINARIES_DIRECTORY_ORCHESTRATOR_TRACKER="${JOBMINUTE_BINARIES_DIRECTORY}/spa"

## chemin vers le dossier de deploiement des binaires des MicroServices
export EAR_BINARIES_DIRECTORY_MICROSERVICES="${JOBMINUTE_BINARIES_DIRECTORY}/microservices"

## chemin vers le dossier de deploiement des binaires de registry
export EAR_BINARIES_DIRECTORY_REGISTRY="${JOBMINUTE_BINARIES_DIRECTORY}/registry"

## chemin vers le dossier d'archivage des binaires de Services
export EAR_BINARIES_DIRECTORY_PATT_ARCHIVE=$EAR_BINARIES_DIRECTORY_PATT/archive

## chemin vers le dossier d'archivage des binaires de MyPixid
export EAR_BINARIES_DIRECTORY_MYPIXID_ARCHIVE=$EAR_BINARIES_DIRECTORY_MYPIXID/archive

## chemin vers le dossier de generation des binaires PATT
export EAR_BINARIES_WORKSPACE_SOURCE_DIRECTORY_PATT=$WORKSPACE/PACK_PATT_EAR/target/PATT_EAR.ear

## chemin vers le dossier de generation des binaires PATT
export EAR_BINARIES_WORKSPACE_SOURCE_DIRECTORY_PATT_THEME=$WORKSPACE/PATT_WEB/target/pattTheme.zip

## chemin vers le dossier de generation des binaires MyPixid
export EAR_BINARIES_WORKSPACE_SOURCE_DIRECTORY_MYPIXID=$WORKSPACE/PACK_MYPIXID_EAR/target/MYPIXID_EAR.ear

## chemin vers le dossier de generation des binaires MyPixid
export EAR_BINARIES_WORKSPACE_SOURCE_DIRECTORY_MYPIXID_THEME=$WORKSPACE/MyPixid/target/myPixidTheme.zip

## chemin vers le dossier de generation des binaires MyPixid
export EAR_BINARIES_WORKSPACE_SOURCE_DIRECTORY_MYPIXID_I18N=$WORKSPACE/MyPixid/target/myPixid-i18n.zip

## chemin vers le dossier de deploiement des binaires de type war
export WAR_BINARIES_TOP_DIRECTORY=/appli/deployment/war

## chemin vers le dossier de deploiement des binaires de type war de la plateforme, branche en cours
export WAR_BINARIES_DIRECTORY_PLATEFORME=$WAR_BINARIES_TOP_DIRECTORY/${PLATEFORME}
#/appli/deployment/war/INT2/release/6.2.4
## chemin vers le dossier de deploiement des binaires de type war de la plateforme, branche et version en cours
export WAR_BINARIES_DIRECTORY=${WAR_BINARIES_DIRECTORY_PLATEFORME}/${VERSION_NUMBER}

## chemin vers le dossier de deploiement des binaires de provide
export WAR_BINARIES_DIRECTORY_PROVIDER="${WAR_BINARIES_DIRECTORY}/Provider"

## chemin vers le dossier de deploiement des binaires de cas
export WAR_BINARIES_DIRECTORY_CAS="${WAR_BINARIES_DIRECTORY}/Cas"

## chemin vers le dossier d'archivage des binaires de provider
export WAR_BINARIES_DIRECTORY_PROVIDER_ARCHIVE=$WAR_BINARIES_DIRECTORY_PROVIDER/archive

## chemin vers le dossier d'archivage des binaires de cas
export WAR_BINARIES_DIRECTORY_CAS_ARCHIVE=$WAR_BINARIES_DIRECTORY_CAS/archive

## chemin vers le dossier d'archivage des binaires de microservices
export WAR_BINARIES_DIRECTORY_MICROSERVICES_ARCHIVE=$EAR_BINARIES_DIRECTORY_MICROSERVICES/archive

## chemin vers le dossier d'archivage des binaires de jobminute spa
export ZIP_BINARIES_DIRECTORY_JOBMINUTE_ARCHIVE=$EAR_BINARIES_DIRECTORY_JOBMINUTE/archive

## chemin vers le dossier d'archivage des binaires de orchestrator tracker spa
export ZIP_BINARIES_DIRECTORY_ORCHESTRATOR_TRACKER_ARCHIVE=$EAR_BINARIES_DIRECTORY_ORCHESTRATOR_TRACKER/archive

## chemin vers le dossier d'archivage des binaires registry
export WAR_BINARIES_DIRECTORY_REGISTRY_ARCHIVE=$EAR_BINARIES_DIRECTORY_REGISTRY/archive

## chemin vers le dossier de generation des binaires provider
export WAR_BINARIES_WORKSPACE_SOURCE_DIRECTORY_PROVIDER=$WORKSPACE/provider/target/provider.war

## chemin vers le dossier de generation des binaires cas
export WAR_BINARIES_WORKSPACE_SOURCE_DIRECTORY_CAS=$WORKSPACE/CAS_SERVER_WEBAPP/target/cas.war

## chemin vers le dossier de generation des binaires de microservices
export WAR_BINARIES_WORKSPACE_SOURCE_DIRECTORY_MICROSERVICES=$WORKSPACE/microservice/*/

## chemin vers le dossier de generation des binaires de registry
export WAR_BINARIES_WORKSPACE_SOURCE_DIRECTORY_REGISTRY=$WORKSPACE/Registry/

## chemin vers le sous dossier de la plateforme actuelle du dossier de deploiement sql
export PLATEFORME_SQL_DEPLOYMENT_DIRECTORY=${SQL_DEPLOYMENT_DIRECTORY}/${PLATEFORME}

## chemin vers le sous dossier de la version en cours du dossier de deploiement de la plateforme actuelle
export VERSIONED_SQL_DEPLOYMENT_DIRECTORY=$PLATEFORME_SQL_DEPLOYMENT_DIRECTORY/$VERSION_NUMBER

## chemin vers le sous dossier processed du dossier de deploiement de la version en cours
export VERSIONED_SQL_DEPLOYMENT_DIRECTORY_PROCESSED=$VERSIONED_SQL_DEPLOYMENT_DIRECTORY/PROCESSED

## chemin vers le sous dossier rejected du dossier de deploiement de la version en cours
#export VERSIONED_SQL_DEPLOYMENT_DIRECTORY_REJECTED=$VERSIONED_SQL_DEPLOYMENT_DIRECTORY/REJECTED

## chemin vers le dossier contenant les scripts sql recuperes depuis git
#export SQL_SCRIPTS_DIRECTORY=$WORKSPACE/PATT_UTILS/sql
export GIT_SQL_SCRIPTS_DIRECTORY=$WORKSPACE/$PROJECT_SQL_NAME/sql

## chemin vers le sous dossier de la version en cours du dossier contenant les scripts sql recuperes depuis git
#export VERSIONED_SQL_SCRIPTS_DIRECTORY=$SQL_SCRIPTS_DIRECTORY/$VERSION_NAME
export VERSIONED_GIT_SQL_SCRIPTS_DIRECTORY=$GIT_SQL_SCRIPTS_DIRECTORY/$VERSION_NAME

## chemin vers le fichier register de deploiement sql de la version en cours
export REGISTER_FILE=$VERSIONED_SQL_DEPLOYMENT_DIRECTORY/register

## chemin vers le fichier des rejets de deploiement sql de la version en cours
export REJECTED_FILE=$VERSIONED_SQL_DEPLOYMENT_DIRECTORY/rejected

## Expression reguliere pour le controle des versions de release
export VERSION_REGEXP='^V([0-9]+\.){0,3}(\*|[0-9]+)$'

## Expression reguliere pour le controle des noms de fichiers sql
export SCRIPT_NAME_REGEXP='^([0-9]){3,4}(_[0-9]){0,1}_([A-Z]){3,4}(_PF([-_](DEV|INT|INT0|INT1|INT2|INT3|INT4|INT5|REC|REC1|REC2|RCT|RCT1|RCT2|TEST|PROD))+){0,1}_(PIXID|DWHSTAGE|DWHTMP|PROVIDER|MISSION|OFFREEMPLOI){1}_(TI[-_][0-9]{1,10})(_ST[-_][0-9]{1,10})?_([A-Z0-9_-]+)(\.SQL)$'

## chemin vers le dossier de livraison dans le partage CIFS
export TARGET_BASE_FOLDER=/data/DEVOPS/CICD

## Nom du host CIFS
export TARGET_HOST=CIFS-DEVOPS

## chemin vers le fichier de log
export LOG_FILE=appli/deployment/log/execution_${SCRIPT_NAME}.log

if [ -f "$LOG_FILE" ]
	then
		LAST_MODIFIED_DATE=`date '+%Y-%m-%d' -r ${LOG_FILE}`		
		DATE=`date '+%Y-%m-%d'`
		if [[ "${LAST_MODIFIED_DATE}" < "${DATE}" ]]; then
			savelog -n -c 2 ${LOG_FILE}
		fi
	else
		mkdir -p appli/deployment/log
fi

## chemin vers le dossier de livraison de l'environnement en cours
export TARGET_ENV_FOLDER=$TARGET_BASE_FOLDER/$PLATEFORME

## chemin vers le dossier de livraison de l'environnement en cours, la version en cours et l'increment en cours de Services
export TARGET_PATT_FOLDER=$TARGET_ENV_FOLDER/$VERSION_NUMBER/$CURRENT_INCREMENT/ear/pixid

## chemin vers le dossier de livraison de l'environnement en cours, la version en cours et l'increment en cours de MyPixid
export TARGET_MYPIXID_FOLDER=$TARGET_ENV_FOLDER/$VERSION_NUMBER/$CURRENT_INCREMENT/ear/mypixid

## chemin vers le dossier de livraison de l'environnement en cours, la version en cours et l'increment en cours de Job Minute
export TARGET_JOBMINUTE_FOLDER=$TARGET_ENV_FOLDER/$VERSION_NUMBER/$CURRENT_INCREMENT/jobminute/spa

## chemin vers le dossier de livraison de l'environnement en cours, la version en cours et l'increment en cours de MicroServices
export TARGET_MICROSERVICES_FOLDER=$TARGET_ENV_FOLDER/$VERSION_NUMBER/$CURRENT_INCREMENT/jobminute/microservices

## chemin vers le dossier de livraison de l'environnement en cours, la version en cours et l'increment en cours de Registry
export TARGET_REGISTRY_FOLDER=$TARGET_ENV_FOLDER/$VERSION_NUMBER/$CURRENT_INCREMENT/jobminute/registry

## chemin vers le dossier de livraison de l'environnement en cours, la version en cours et l'increment en cours de Services
export TARGET_PROVIDER_FOLDER=$TARGET_ENV_FOLDER/$VERSION_NUMBER/$CURRENT_INCREMENT/war/provider

## chemin vers le dossier de livraison de l'environnement en cours, la version en cours et l'increment en cours de MyPixid
export TARGET_CAS_FOLDER=$TARGET_ENV_FOLDER/$VERSION_NUMBER/$CURRENT_INCREMENT/war/cas

## chemin vers le fichier contenant les resultats des executions des scripts sql du deploiement en cours
export SQL_EXECUTION_RESULT_FILE=$TARGET_BASE_FOLDER/$PLATEFORME/$VERSION_NUMBER/$CURRENT_INCREMENT/resultat_execution
#export SQL_EXECUTION_RESULT_FILE=/appli/deployment/sql/INT2/6.2.4/resultat_execution

# chemin vers la classe java html tag à modifier avec les bonnes valeurs de la version et de la date de release
NEW_HTML_TAG=$WORKSPACE/PATT_WEB/src/main/java/com/pixid/tech/v1/presentation/taglib/NewHtmlTag.java

# API KEY du workspace Non Regression dont l'uid est c24aa5e1-8ed7-436d-8326-77f0b34fa27d
# L'API KEY est généré dans POSTMAN dans https://web.postman.co/integrations/services/pm_pro_api?workspace=c24aa5e1-8ed7-436d-8326-77f0b34fa27d
POSTMAN_APPLICATION_API_KEY=c5b12a76888e47598abe51141a30016c

# url d'acces au site public postman
POSTMAN_API_URL_GENERIQUE=https://api.getpostman.com

# url generique d'acces aux collections mise en place dans postman
# les params qui seront ajoutes a cette url permettent d'aller au tests cibles d'une appli en particulier
POSTMAN_API_URL_COLLECTIONS=${POSTMAN_API_URL_GENERIQUE}/collections

# url generique d'acces aux environnements mise en place dans postman 
# les params qui seront ajoutes a cette url permettent d'aller au tests cibles d'une appli en particulier
POSTMAN_API_URL_ENVIRONMENTS=${POSTMAN_API_URL_GENERIQUE}/environments

# chemin d'acces au projet NG-MYPIXID
export WORKSPACE_SOURCE_DIRECTORY_NG_MYPIXID=${WORKSPACE}/NG-MYPIXID

# chemin d'acces au projet PIXID_CANDIDAT_FRONT
export WORKSPACE_SOURCE_DIRECTORY_PIXID_CANDIDAT_FRONT=${WORKSPACE}/PIXID_CANDIDAT_FRONT

# chemin d'acces au projet PIXID_ORCHESTRATOR_TRACKER
export WORKSPACE_SOURCE_DIRECTORY_PIXID_ORCHESTRATOR_TRACKER=${WORKSPACE}/PIXID_ORCHESTRATOR_TRACKER

# chemin d'acces au dossier de binaire du projet NG-MYPIXID
export BINARY_WORKSPACE_SOURCE_DIRECTORY_NG_MYPIXID=${WORKSPACE_SOURCE_DIRECTORY_NG_MYPIXID}/dist

# chemin d'acces au dossier de binaire du projet PIXID_CANDIDAT_FRONT
export BINARY_WORKSPACE_SOURCE_DIRECTORY_PIXID_CANDIDAT_FRONT=${WORKSPACE_SOURCE_DIRECTORY_PIXID_CANDIDAT_FRONT}/build/www

# chemin d'acces au dossier de binaire du projet PIXID_ORCHESTRATOR_TRACKER
export BINARY_WORKSPACE_SOURCE_DIRECTORY_PIXID_ORCHESTRATOR_TRACKER=${WORKSPACE_SOURCE_DIRECTORY_PIXID_ORCHESTRATOR_TRACKER}/build/www

# Nom du binaire du projet NG-MYPIXID
export NG_MYPIXID_BINARY_NAME=myPixidProject

# Nom du binaire du projet PIXID_CANDIDAT_FRONT
export PIXID_CANDIDAT_FRONT_BINARY_NAME=JobMinute

# Nom du binaire du projet PIXID_CANDIDAT_FRONT
export PIXID_ORCHESTRATOR_TRACKER_BINARY_NAME=OrchestratorTracker

# Nom du binaire des microservices
export MICROSERVICES_BINARY_NAME=microservices

# chemin d'acces au binaire du projet NG-MYPIXID
export UNZIPPED_BINARY_WORKSPACE_SOURCE_DIRECTORY_NG_MYPIXID=${BINARY_WORKSPACE_SOURCE_DIRECTORY_NG_MYPIXID}/$NG_MYPIXID_BINARY_NAME

# chemin d'acces au binaire du projet PIXID_CANDIDAT_FRONT
export UNZIPPED_BINARY_WORKSPACE_SOURCE_DIRECTORY_PIXID_CANDIDAT_FRONT=${BINARY_WORKSPACE_SOURCE_DIRECTORY_PIXID_CANDIDAT_FRONT}/$PIXID_CANDIDAT_FRONT_BINARY_NAME

# chemin d'acces au binaire du projet PIXID_ORCHESTRATOR_TRACKER
export UNZIPPED_BINARY_WORKSPACE_SOURCE_DIRECTORY_PIXID_ORCHESTRATOR_TRACKER=${BINARY_WORKSPACE_SOURCE_DIRECTORY_PIXID_ORCHESTRATOR_TRACKER}/$PIXID_ORCHESTRATOR_TRACKER_BINARY_NAME

# chemin d'acces au binaire du projet NG-MYPIXID
export ZIP_BINARY_WORKSPACE_SOURCE_DIRECTORY_NG_MYPIXID=${BINARY_WORKSPACE_SOURCE_DIRECTORY_NG_MYPIXID}/$NG_MYPIXID_BINARY_NAME.zip

# chemin d'acces au binaire du projet PIXID_CANDIDAT_FRONT
export ZIP_BINARY_WORKSPACE_SOURCE_DIRECTORY_PIXID_CANDIDAT_FRONT=${BINARY_WORKSPACE_SOURCE_DIRECTORY_PIXID_CANDIDAT_FRONT}/$PIXID_CANDIDAT_FRONT_BINARY_NAME.zip

# chemin d'acces au binaire du projet PIXID_ORCHESTRATOR_TRACKER
export ZIP_BINARY_WORKSPACE_SOURCE_DIRECTORY_PIXID_ORCHESTRATOR_TRACKER=${BINARY_WORKSPACE_SOURCE_DIRECTORY_PIXID_ORCHESTRATOR_TRACKER}/$PIXID_ORCHESTRATOR_TRACKER_BINARY_NAME.zip

# chemin d'acces au projet NG-PIXID
export WORKSPACE_SOURCE_DIRECTORY_NG_PIXID=${WORKSPACE}/NG-PIXID

# chemin d'acces au dossier de binaire du projet NG-PIXID
export BINARY_WORKSPACE_SOURCE_DIRECTORY_NG_PIXID=${WORKSPACE_SOURCE_DIRECTORY_NG_PIXID}/dist

# Nom du binaire du projet NG-PIXID
export NG_PIXID_BINARY_NAME=pattProject

# chemin d'acces au binaire du projet NG-PIXID
export UNZIPPED_BINARY_WORKSPACE_SOURCE_DIRECTORY_NG_PIXID=${BINARY_WORKSPACE_SOURCE_DIRECTORY_NG_PIXID}/$NG_PIXID_BINARY_NAME

# chemin d'acces au binaire du projet NG-PIXID
export ZIP_BINARY_WORKSPACE_SOURCE_DIRECTORY_NG_PIXID=${BINARY_WORKSPACE_SOURCE_DIRECTORY_NG_PIXID}/$NG_PIXID_BINARY_NAME.zip

function log {
	 DATE=`date '+%Y-%m-%d %H:%M:%S'`
     echo "$DATE $1"
	 echo "$DATE $1">>${LOG_FILE}
}
# nettoyage du dossier sql de l'historique de dossier Vx.y.z de façon a ne garder que deux dossiers a chaque fois
Clean_VERSIONED_Folder() {
if [ -d "$1" ]; then 
	#log "Clean_VERSIONED_Folder folder : $1"
	DEPLOYMENT_DIRECTORY_COUNT=`ls -1d $1/*/ | wc -l`
	#log "DEPLOYMENT_DIRECTORY_COUNT $DEPLOYMENT_DIRECTORY_COUNT"
	if [ $DEPLOYMENT_DIRECTORY_COUNT -gt 2 ]; then
		
		TO_BE_DELETED=()
		COUNT=0
		for I_DIR in `ls -1d $1/*/ | sort -Vr`
		do
			DIR_NAME=`basename $I_DIR`
			if [[ ! ("V$DIR_NAME" =~ $VERSION_REGEXP) ]]; then
				#log "Clean_VERSIONED_Folder :  $I_DIR ne respecte pas $VERSION_REGEXP "
				TO_BE_DELETED+=("$I_DIR")
			else
				if [ $COUNT -gt 1 ]; then
					TO_BE_DELETED+=("$I_DIR")
				fi
				((COUNT++))
				#X_DIGIT=`echo ${DIR_NAME:1} | awk -F'.' '{printf("%03d\n",$1)}'`
				#Y_DIGIT=`echo ${DIR_NAME:1} | awk -F'.' '{printf("%03d\n",$2)}'`
				#Z_DIGIT=`echo ${DIR_NAME:1} | awk -F'.' '{printf("%03d\n",$3)}'`
				#FULL_VERSION_NUMBER=$X_DIGIT$Y_DIGIT$Z_DIGIT
			fi
		done
		for DIR_TO_BE_DELETED in "${TO_BE_DELETED[@]}"
		do
			rm -rf $DIR_TO_BE_DELETED
		done
	fi	
fi
}
