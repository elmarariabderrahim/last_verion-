

#!/bin/bash
#
#========================================================================================================
# NOM DU SCRIPT 		:  handle_scripts_sql.sh
#========================================================================================================
#--------------------------------------------------------------------------------------------------------
# AUTEURS				: JEL
# DATE DE CREATION		: 12/02/2018
# VERSION 	 			: 1.0
# -------------------------------------------------------------------------------------------------------
# OBJECT				: Ce script a pour objectif de preparer les scripts sql a executer pour le 
#						  deploiement en cours. 
#						  Il va recuperer les scripts sql depuis leur emplacement relatif au deploiement en 
#						  cours. Ensuite il va eliminer ceux qui ont deja ete livres dans d'autres 
#						  deploiements de la même version de release (parametre numero de version)
#						  pour eviter de livrer des scripts deja livres
#--------------------------------------------------------------------------------------------------------
# PARAMETRES 			: $1 Nom du job en cours d'execution
#						  $2 Chemin dans le file system du workspace job en cours d'execution
#						  $3 Numero de la version en cours qui permettra de deduire les dossiers de 
#						  PATT_UTILS/sql a cibler pour deduire les scripts a preparer pour le deploiement
#						  Exemple : 6.1.4
#						  $4 Nom du projet contient les scripts sql
#						  $5 plateforme source a partir de laquelle prendre les sources sql et les binaires.
#					      Ce parametre n'est present que dans le cas des plateformes (cibles) recette, test
# 						  et prod
#--------------------------------------------------------------------------------------------------------
#========================================================================================================

JOB_NAME=$1
WORKSPACE=$2
VERSION_NUMBER=$3
PROJECT_SQL_NAME=$6
PLATEFORME_SOURCE=$7
VERSION_NAME="V$3"
PLATEFORME=`echo $JOB_NAME |cut -d"_" -f1`
export username=$4
export password=$5
#BRANCHE=`echo $JOB_NAME |cut -d"_" -f2`
# lecture des parametres / variables environnements
SCRIPT_NAME=`basename "$0"`
SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_BASEDIR_PATH=$(dirname "$SCRIPT_PATH")
. ${SCRIPT_BASEDIR_PATH}/environment_config.sh
#list des scripts qui sont deja a la table de register
list_script=( $( mysql --batch mysql -u $username -p$password -N -e "use db5; select script_name from scripts where version='$VERSION_NAME';"  ) )
#list des checksum qui sont deja a la table de register
list_checksum=( $( mysql --batch mysql -u $username -p$password -N -e "use db5; select CHECKSUM_VALUE from scripts where version='$VERSION_NAME';"  ) )
#list des scripts qui sont mal nommer
list_rejected_scripts=( $( mysql --batch mysql -u $username -p$password -N -e "use db5; select CHECKSUM_VALUE from scripts where script_name_regex='ko' and version='$VERSION_NAME';"  ) )
THERE_WERE_REJECTED_FILES=0
SCRIPT_HANDLED_LIST=()
Read_DB_Name() {
	DB_INSTRUCTION="NODBINSTRUCTIONINTHEFILE"
	while read -r line
	do
    	TEMP=$(echo $line | tr '[:lower:]' '[:upper:]')
    	#echo "line $TEMP"
    	if [[ $TEMP = *"USE"* ]]; then
    		if [[ $2 -eq 1 ]]; then
    			DB_INSTRUCTION=$TEMP
    		else 
    			DB_INSTRUCTION=$line
    		fi
    		break
    	fi
	done < "$1"
	RESULT=""
	if [[ $DB_INSTRUCTION = *"\`"* ]] 
		then 
		RESULT=$(echo $DB_INSTRUCTION | cut -d"\`" -f2 | xargs)
	else
		RESULT=$(echo $DB_INSTRUCTION | cut -d" " -f2 | cut -d";" -f1 | xargs)
	fi
  	echo -e "${RESULT}"
}

if [[ ! ($VERSION_NAME =~ $VERSION_REGEXP) ]]; then
	log "le numero de version indique $VERSION_NAME ne respecte pas le format attendu (ex V6.1.4) "
	log "FIN DES TRAITEMENTS AVEC ERREUR VOIR FICHIER DE LOG ${LOG_FILE}"
	exit 1
fi

#DEPLOYMENT_DIRECTORY="/appli/deployment/${JOB_NAME/$KEY_TO_REPLACE/$REPLACEMENT}"

TIMESTAMP=`date '+%Y-%m-%d-%H:%M:%S'`
echo =======================================$TIMESTAMP
DATE_NOW=`date '+%Y-%m-%d-%H-%M-%S'`
log "DATE_NOW $DATE_NOW"
log "PLATEFORME $PLATEFORME"
PIPE="|"

Handle_Directory_Script() {
#for inode in `ls -1 $VERSIONED_SQL_SCRIPTS_DIRECTORY`
	SCRIPT_NOT_HANDLED_LIST=()
	log " Traitement du repertoire sql $1 "
	for inode in `ls -1 $1`
	do
		log "------------------------------------------------------------------------------------------"
		log "inode $inode"
		SCRIPT_PF_DEPENDANT=1
		CHECKSUM_VALUE=`md5sum $1/$inode | awk '{print $1}'`
		#verification si le contenu de script est modifier ou si il s'agit d'un nouveau script ou s'il est renommé
		if [[ !(${list_script[*]} =~ "$inode") ]] && [[ !(${list_checksum[*]} =~ "$CHECKSUM_VALUE") ]] || [[ ${list_script[*]} =~ "$inode" ]] && [[ !(${list_checksum[*]} =~ "$CHECKSUM_VALUE") ]] || [[ ${list_rejected_scripts[*]} =~ "$CHECKSUM_VALUE" ]]
		then
		
			log "Le fichier $inode est a traiter car il n'est pas dans register ou il y est mais avec un checksum different"
			DB_NAME_IN_SCRIPT_UPPERCASE=`Read_DB_Name $1/$inode 1`
			DB_NAME_IN_SCRIPT_LOWERCASE=`Read_DB_Name $1/$inode 2`
			log "DB_NAME_IN_SCRIPT_UPPERCASE $DB_NAME_IN_SCRIPT_UPPERCASE"
			INODE_UPPERCASE=$(echo $inode | tr '[:lower:]' '[:upper:]')
			if [[ ! ($INODE_UPPERCASE =~ $SCRIPT_NAME_REGEXP) ]] || [[ $INODE_UPPERCASE != *"${DB_NAME_IN_SCRIPT_UPPERCASE}"* ]]
			
				then
				SCRIPT_NOT_HANDLED_LIST+=("$inode")
				if [[ !(${list_script[*]} =~ "$inode") ]] 
				then
					#script mal nommer => script_handled =  ko
			     mysql -u$username -p$password -Bse "use db5;insert into scripts (script_name,date_build,script_name_regex,script_handled,CHECKSUM_VALUE,version ,script_platform ) values('$inode','$TIMESTAMP','ko','encour','$CHECKSUM_VALUE','$VERSION_NAME','encour');"
			 		log "Le fichier $inode ne peut etre traite car il est mal nomme ou contient une incoherence au niveau du nom de la base de donnees"
				
			 	fi
			 	#si le script est renommé mais ne respecte pas l'expression spécifiée
			 	if [[ ${list_rejected_scripts[*]} =~ "$CHECKSUM_VALUE" ]] 
			 	then
			 		 mysql -u$username -p$password -Bse "use db5;update  scripts set  script_name='$inode' where CHECKSUM_VALUE='CHECKSUM_VALUE';"
			 		 log "le script $inode est encour mal nomme"
			 	fi
			 	THERE_WERE_REJECTED_FILES=1
				
			else
				{
					NAME_PF_PART_TEMP="${INODE_UPPERCASE/$DB_NAME_IN_SCRIPT_UPPERCASE/$PIPE}"
					log "DB_NAME_IN_SCRIPT_UPPERCASE $DB_NAME_IN_SCRIPT_UPPERCASE"
					log "NAME_PF_PART_TEMP $NAME_PF_PART_TEMP"
					#NAME_PF_PART=$(echo $inode | awk '{split($0, a, "${DB_NAME_IN_SCRIPT_UPPERCASE}"); print a[1]}')
					NAME_PF_PART=$(echo $NAME_PF_PART_TEMP | awk 'BEGIN { FS = "|" } ; { print $1 }')
					log "NAME_PF_PART $NAME_PF_PART"
					NAME_PF_PART=$(echo $NAME_PF_PART | awk 'BEGIN { FS = "PF" } ; { print $2 }')
					log "NAME_PF_PART $NAME_PF_PART"
					# TODO a revoir pour prendre en compte les cas où c'est écrit REC, ou INT ou REC_INT_TEST
					if [[ $NAME_PF_PART != *"RCT1_"* ]] && [[ $NAME_PF_PART != *"RCT2_"* ]] && [[ $NAME_PF_PART != *"RCT_"* ]] &&[[ $NAME_PF_PART != *"REC1_"* ]] && [[ $NAME_PF_PART != *"REC2_"* ]] && [[ $NAME_PF_PART != *"REC_"* ]] && [[ $NAME_PF_PART != *"INT_"* ]] && [[ $NAME_PF_PART != *"PROD_"* ]] && [[ $NAME_PF_PART != *"DEV_"* ]] && [[ $NAME_PF_PART != *"TEST_"* ]] && [[ $NAME_PF_PART != *"INT0_"* ]] && [[ $NAME_PF_PART != *"INT1_"* ]] && [[ $NAME_PF_PART != *"INT2_"* ]] && [[ $NAME_PF_PART != *"INT3_"* ]] && [[ $NAME_PF_PART != *"INT4_"* ]] && [[ $NAME_PF_PART != *"INT5_"* ]]
						then
							SCRIPT_PF_DEPENDANT=0
					fi
					if [ $SCRIPT_PF_DEPENDANT -eq "1" ]; then
						if [[ $NAME_PF_PART = *"RCT_"* ]]; then
							NAME_PF_PART="${NAME_PF_PART}RCT1_RCT2_"
						fi
						if [[ $NAME_PF_PART = *"REC_"* ]]; then
							NAME_PF_PART="${NAME_PF_PART}REC1_REC2_"
						fi
						NAME_PF_PART="${NAME_PF_PART//REC/RCT}"
						if [[ $NAME_PF_PART = *"INT_"* ]]; then
							NAME_PF_PART="${NAME_PF_PART}INT0_INT1_INT2_INT3_INT4_INT5_"
						fi
						log "NAME_PF_PART $NAME_PF_PART"
					fi
					log "SCRIPT_PF_DEPENDANT $SCRIPT_PF_DEPENDANT"
					
					# COPY_TARGET="${VERSIONED_SQL_DEPLOYMENT_DIRECTORY_PROCESSED}"
					
					# COPY_TARGET2="${VERSIONED_SQL_DEPLOYMENT_DIRECTORY_PROCESSED}/$DATE_NOW/${DB_NAME_IN_SCRIPT_LOWERCASE}"
					
					# SCRIPT_HANDLED_LIST+=("$1|$inode|${CHECKSUM_VALUE}|${COPY_TARGET}|${COPY_TARGET2}|${SCRIPT_PF_DEPENDANT}|${NAME_PF_PART}")
					if [ $SCRIPT_PF_DEPENDANT -eq "0" ] || { [ $SCRIPT_PF_DEPENDANT -eq "1" ] && [[ $NAME_PF_PART = *"$PLATEFORME"* ]]; }
					then
						#si le script est bien nommé 
						if [[ !(${list_script[*]} =~ "$inode") ]] && [[ !(${list_checksum[*]} =~ "$CHECKSUM_VALUE") ]]
							then
							mysql -u$username -p$password -Bse "use db5;insert into scripts (date_build,script_name,script_handled,CHECKSUM_VALUE,script_name_regex,version ,script_platform) values('$TIMESTAMP','$inode','encour','$CHECKSUM_VALUE','ok','$VERSION_NAME','encour');"
							log "Le fichier $inode a ete traite avec succes et ajoute dans le registre des scripts traites"

						fi
						#si le contenu du script est modifier il faud le  retester (script_state='failed' pour le prendre en considération dans la phase de test)
						if [[ ${list_script[*]} =~ "$inode" ]] && [[ !(${list_checksum[*]} =~ "$CHECKSUM_VALUE") ]]
						then 
							log " le script $inode a ete modifier "
							mysql -u$username -p$password -Bse "use db5;update scripts set CHECKSUM_VALUE='$CHECKSUM_VALUE', script_handled='encour', date_build='$TIMESTAMP', script_state='failed' where script_name='$inode';"
						fi
						#si le nom de script est rectifier => script_name_regex='ok' 
						if [[ ${list_rejected_scripts[*]} =~ "$CHECKSUM_VALUE" ]] 
 						then

 							mysql -u$username -p$password -Bse "use db5;update  scripts set  script_name='$inode',date_build='$TIMESTAMP',script_name_regex='ok' where CHECKSUM_VALUE='$CHECKSUM_VALUE';"
 							log "le nom du script $inode a ete corriger "
 						fi
					fi		
				}	
			fi
		fi
	done



}
	

#if [ $# -gt 3 ]; then 
if [[ ${PLATEFORME_SOURCE} != "" ]]; then 
# VERSIONED_SQL_SCRIPTS_DIRECTORY=${SQL_DEPLOYMENT_DIRECTORY}/${PLATEFORME_SOURCE}/$VERSION_NUMBER/PROCESSED
		VERSIONED_SQL_SCRIPTS_DIRECTORY="appli/deployment/sql/${PLATEFORME_SOURCE}/$VERSION_NUMBER/PROCESSED"
# afin de tester les scripts déjà testés dans PLATEFORME_SOURCE  dans PLATEFORME
	# mysql --batch mysql -u $username -p$password -N -e "use db5; update scripts set  script_state='failed' , script_handled ='encour'  where version='$VERSION_NAME' ;"
	mysql --batch mysql -u $username -p$password -N -e "use db5; update scripts set  script_state='failed',date_build='$TIMESTAMP' , script_handled ='encour'  where script_id IN (select script_id from execution_plateforme where \`$PLATEFORME\`=0)  and version='$VERSION_NAME' and script_state='valid' ;"
		# mysql --batch mysql -u $username -p$password -N -e "use db5; update scripts set  script_state='failed' , date_build='$TIMESTAMP',script_handled ='encour'  where script_id  IN (select script_id from execution_plateforme where \`$PLATEFORME\`=0) and version='$VERSION_NAME' and  script_state='invalid' ;"

else 
	VERSIONED_SQL_SCRIPTS_DIRECTORY=${VERSIONED_GIT_SQL_SCRIPTS_DIRECTORY}
fi

SQL_SCRIPTS_DIRECTORY_COUNT=0
if [ -d "$VERSIONED_SQL_SCRIPTS_DIRECTORY" ]; then
	SQL_SCRIPTS_DIRECTORY_COUNT=`ls -1 $VERSIONED_SQL_SCRIPTS_DIRECTORY | wc -l`
fi





log "SQL_SCRIPTS_DIRECTORY_COUNT $SQL_SCRIPTS_DIRECTORY_COUNT"
# log "REJECTED_FILE ${REJECTED_FILE}"

if [ $SQL_SCRIPTS_DIRECTORY_COUNT -gt 0 ]
	then
		log "creation du repertoire ${VERSIONED_SQL_DEPLOYMENT_DIRECTORY} "
		# mkdir -p ${VERSIONED_SQL_DEPLOYMENT_DIRECTORY}
		mkdir -p appli/deployment/sql/$PLATEFORME/$VERSION_NUMBER
		log "De nouveaux scripts sql sont a traiter dans les dossiers $VERSIONED_SQL_SCRIPTS_DIRECTORY "
		#mkdir -p $VERSIONED_SQL_DEPLOYMENT_DIRECTORY
		
		#mkdir -p $VERSIONED_SQL_DEPLOYMENT_DIRECTORY_PROCESSED/$DATE_NOW
		# Clean_VERSIONED_Folder $PLATEFORME_SQL_DEPLOYMENT_DIRECTORY
		# Clean_VERSIONED_Folder appli/deployment/sql/$PLATEFORME

		
	else	
		log "Aucun script trouve dans les dossiers $VERSIONED_SQL_SCRIPTS_DIRECTORY ! Veuillez verifier le numero de version indique"
		log "FIN DES TRAITEMENTS AVEC SUCCES MAIS IL N'Y AVAIT AUCUN SCRIPT A TRAITER"
		exit 0
fi



if [ $SQL_SCRIPTS_DIRECTORY_COUNT -gt 0 ]; then
	Handle_Directory_Script $VERSIONED_SQL_SCRIPTS_DIRECTORY
fi



if [ $THERE_WERE_REJECTED_FILES -gt 0 ] || [ ${#rejected_script[@]} -gt 0 ]  ; then
	log "Rectifier les scripts rejetes (voir la table rejected_scripts)"
else 
	log "Tous les scripts qui sont bien nommes ont ete pris "
fi
log "------------------------------------------------------------------------------------------"
#========================================================================================================
#   Clone des BD specifiers dans les scripts 
#========================================================================================================

# list des script qui sont bien nomme
list_script_alredy_succes=( $( mysql --batch mysql -u $username -p$password -N -e "use db5; select script_name from scripts where  script_handled='encour' and script_name_regex ='ok' or  script_handled='encour' and script_name_regex ='ok' and script_state ='invalid' or script_handled='traite' and script_name_regex ='ok' and script_state ='failed' "  ) )
echo $list_script_alredy_succes

list_database_in_script=()
flag=""
Read_DB_Name() {
	DB_INSTRUCTION="NODBINSTRUCTIONINTHEFILE"
	while read -r line
	do
    	TEMP=$(echo $line | tr '[:lower:]' '[:upper:]')
    	#echo "line $TEMP"
    	if [[ $TEMP = *"USE"* ]]; then
    		
    			DB_INSTRUCTION=$TEMP
    		 
    			DB_INSTRUCTION=$line
    		
    		
    	fi
	done < "$1"
	RESULT=""
	if [[ $DB_INSTRUCTION = *"\`"* ]] 
		then 
		RESULT=$(echo $DB_INSTRUCTION | cut -d"\`" -f2 | xargs)
	else
		RESULT=$(echo $DB_INSTRUCTION | cut -d" " -f2 | cut -d";" -f1 | xargs)
	fi
  	echo -e "${RESULT}"
}

	for script_name in `ls -1 $VERSIONED_SQL_SCRIPTS_DIRECTORY` 
	 do
		# script_name=$(echo $f| cut -d'/' -f5)
		script_type=$(echo $script_name| cut -d'_' -f1)
				if [[ ( ${list_script_alredy_succes[*]} =~ $script_name ) ]]
				then
				# extract dbname 
				DB_NAME=`Read_DB_Name $VERSIONED_SQL_SCRIPTS_DIRECTORY/$script_name `
				
				count=${#list_database_in_script[@]}
				flag1=""
				for (( c=0; c<$count; c++ ))
				do 
					
								if [[  ${list_database_in_script[$c]} = ${DB_NAME} ]]; then 
									flag1=1
								else 
									flag1=0
								fi

				done
				mysql -u$username -p$password -Bse "use db5;update scripts set  script_handled ='traite',db_in_script='$DB_NAME' where script_name='$script_name';"

					if [[  $DB_NAME != "NODBINSTRUCTIONINTHEFILE" ]] ; then 
					 	if [[  $flag1 != 1 ]] && [[  $script_type < 200 ]]; then 
							list_database_in_script+=($DB_NAME)		
						fi
					else
						log " ****** la base de donnee n'est pas specifier dans le script $script_name ******"
					fi
				fi
	done

	db_number=${#list_database_in_script[@]}
	if [[ $db_number != 0 ]]
	then 
	log "nombre des bases invoquer dans les scripts est $db_number (${list_database_in_script[@]})	" 
	fi

	 # inportation des bases invoquer dans les scripts
	str=$(docker port test-mysql)
	IFS=':'
	read -ra ADDR <<< "$str"
	docker_mysql_port=${ADDR[1]}

	for d in ${list_database_in_script[@]}; do
		mysqldump -u $username -p$password --no-data $d > $d.sql
		mysql -P $docker_mysql_port --protocol=tcp -u $username -p$password -Bse "DROP DATABASE IF EXISTS $d; CREATE DATABASE  $d; "
		docker exec -i dadbc6ef4b91  mysql -u $username -p$password  $d < $d.sql
		rm -rf $d.sql
	done

log "------------------------------------------------------------------------------------------"
#========================================================================================================
#   test des scripts qui respecet name regex 
#========================================================================================================
	# list des scripts qui doivent etre tester
RESULTS_OF_SCRIPT_SHOULD_BE_TESTED=( $( mysql --batch mysql -u $username -p$password -N -e "use db5; select script_name from scripts where script_handled='traite' and script_state is null and script_name_regex ='ok' or script_handled='traite' and script_state='failed' and script_name_regex ='ok' or script_handled='traite' and script_state='invalid' and script_name_regex ='ok' ;"  ) )
# list des scripts échoué
results_of_failed_scripts=( $( mysql --batch mysql -u $username -p$password -N -e "use db5; select script_name from scripts where script_state='failed';"  ) )
RESULTS_OF_REJECTED_SCRIPTS=( $( mysql --batch mysql -u $username -p$password -N -e "use db5; select script_name from scripts where script_name_regex ='ko';"  ) )
str=$(docker port test-mysql)
IFS=':'
read -ra ADDR <<< "$str"
docker_mysql_port=${ADDR[1]}
echo ${docker_mysql_port}

flag=""

#récupération des scripts 


for f in  $VERSIONED_SQL_SCRIPTS_DIRECTORY/*
do
	
	script_name=$(echo ${f##*/})

  # script type (<200 ou >=200)
   script_type=$(echo $script_name| cut -d'_' -f1)
		
	# verification 
	if [[ ( ${RESULTS_OF_SCRIPT_SHOULD_BE_TESTED[*]} =~ $script_name ) ]]
		then

			flag="0"
			# echo "$script_name n'est pas encore testé"
			 
		else 
			flag="1"
			# echo "$script_name est deja testé"
			
		fi
		
		
			if [[ $flag -eq 0 ]] && [[ $script_type < 200 ]] ; then	
	                input="./$f"
					varrr=""	 
					while IFS= read -r line
					do
					    varrr="${varrr}$line"
					done < "$input" 

					mysql -P $docker_mysql_port --protocol=tcp -u$username -p$password -Bse "$varrr" 



					if [ "$?" -eq 0 ]; then
							if [[ ${results_of_failed_scripts[*]} =~ "$script_name" ]] 
							then
								mysql -u$username -p$password -Bse "use db5;update scripts set  script_state = 'succes' where script_name='$script_name';"
								log "****** le script $script_name est passer avec succes ******"
							else
								log "****** le script $script_name est passer avec succes ******"
								mysql -u$username -p$password -Bse "use db5;update scripts set script_state = 'succes' where script_name='$script_name';;"
							fi
					else
							if [[ ${results_of_failed_scripts[*]} =~ "$script_name" ]] 
							then
							log "****** le script $script_name n'a pas été corrigé ******"
							else
							log "****** le script ${script_name} a échoué ******"
							 
							mysql -u$username -p$password -Bse "use db5;update scripts set script_state = 'failed' where script_name='$script_name';"
							fi
					fi 
			elif [ $flag -eq 0 ] && (( $script_type >= 200 )) 
			then	
					 input="./$f"
					varrr=""	 
					while IFS= read -r line
					do
						if [[ $line != *"commit;"* ]]; then
						varrr="${varrr}$line"
						fi
					    
					done < "$input" 
					
					# mysql -P $docker_mysql_port --protocol=tcp -uroot -ppixid123 -Bse " START TRANSACTION;"
					mysql -u$username -p$password -Bse " START TRANSACTION;"
					
					# mysql -P $docker_mysql_port --protocol=tcp -uroot -ppixid123 -Bse "SET AUTOCOMMIT=0; $varrr commit;" 
					mysql  -u$username -p$password -Bse "SET AUTOCOMMIT=0; $varrr " 

					if [ "$?" -eq 0 ]; then
						log "****** l'insertion est passer par succes dans $script_name ******"
						# mysql -P $docker_mysql_port --protocol=tcp -uroot -ppixid123 -Bse "commit;"
						mysql  -u$username -p$password -Bse "ROLLBACK;"

						if [[ ${results_of_failed_scripts[*]} =~ "$script_name" ]] 
							then
								mysql -u$username -p$password -Bse "use db5;update scripts set  script_state = 'succes' where script_name='$script_name';"
						else
							
								mysql -u$username -p$password -Bse "use db5;update scripts set script_state = 'succes' where script_name='$script_name';"
						fi
						
					else
						
						# mysql -P $docker_mysql_port --protocol=tcp -uroot -ppixid123 -Bse "ROLLBACK;"
						mysql  -u$username -p$password -Bse "ROLLBACK;"
						if [[ ${results_of_failed_scripts[*]} =~ "$script_name" ]] 
							then
								log "****** le script $script_name n'a pas été corrigé ******"
						else
							log " ****** l'insertion  a échoué dans $script_name ******"
								mysql -u$username -p$password -Bse "use db5;update scripts set script_state = 'failed' where script_name='$script_name';"
						fi
					fi
			else
				if [[ !(${RESULTS_OF_REJECTED_SCRIPTS[*]} =~ "$script_name") ]] 
				then
					log "****** le script $script_name est deja testé ******"
				fi
			fi
done
# register rejected scripts (test failed ou mal nommé)
SCRIPT_REJECTED_LIST=( $( mysql --batch mysql -u $username -p$password -N -e "use db5;  select script_name from scripts where (script_name_regex ='ko' or script_handled ='traite' and script_state ='failed') and version='$VERSION_NAME';"  ) )

echo "$TIMESTAMP" >> appli/deployment/sql/$PLATEFORME/$VERSION_NUMBER/rejected

SCRIPT_NOT_HANDLED_COUNT=${#SCRIPT_REJECTED_LIST[@]}
	if [ $SCRIPT_NOT_HANDLED_COUNT -gt "0" ]
		then
		
		log "Certains fichiers n'ont pas ete traites: "
		for SCRIPT_NOT_HANDLED in "${SCRIPT_REJECTED_LIST[@]}"
			do
				# log "Le fichier $SCRIPT_NOT_HANDLED est mal nomme : Soit il ne respecte pas le format attendu soit le schema indique dans le nom du fichier est different du schema utilise dans le contenu du script "
				echo  $SCRIPT_NOT_HANDLED >> appli/deployment/sql/$PLATEFORME/$VERSION_NUMBER/rejected
				#$VERSIONED_SQL_DEPLOYMENT_DIRECTORY_REJECTED/REJECTED
		done
		

	fi

sh ./cpy.sh $JOB_NAME $VERSION_NUMBER $username $password $PROJECT_SQL_NAME $WORKSPACE $PLATEFORME_SOURCE
