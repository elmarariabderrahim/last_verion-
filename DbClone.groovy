import groovy.sql.Sql
import java.sql.DriverManager


class DbClone {

	def sql
	def foundDbs = []
	def finalTables = []
	def finalViews = []
	def finalTriggers =[]
	def listOfScripts = []
	def additionalScripts = []
	File file = new File("output.sql")
	def dependencyTables = []
	File viewFile
	File triggerFile
	
	
	//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	def getReady(String user,String pass,String folderName){
		file.write "/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */; /*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */; /*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */; /*!50503 SET NAMES utf8mb4 */; /*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */; /*!40103 SET TIME_ZONE='+00:00' */; /*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */; /*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */; /*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */; /*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;\n"
		//-----------------
		// Getting DB names
		//-----------------
		sql = Sql.newInstance('jdbc:mysql://localhost:3306/', user, pass,'com.mysql.jdbc.Driver')
		def tableSchemas = []  
		sql.eachRow('show databases'){
			row-> row[0]
			tableSchemas.add(row[0])
		}
		//---------------
		//Get SQL scripts
		//---------------
		def sqlFolder = new File(folderName)
		def text
		sqlFolder.eachFile{
			text = it.getText('UTF-8')
			listOfScripts.add(text.toLowerCase())
		}
		//----------------------
		//Cleaning those scripts
		//----------------------
		for(def int i=0 ; i<listOfScripts.size() ; i++){
			listOfScripts[i] = listOfScripts[i].replaceAll("[^a-zA-Z0-9_]", " ")
			listOfScripts[i] = listOfScripts[i].replaceAll(" +", " ")
			listOfScripts[i] = listOfScripts[i].split(" ")
		}
		//------------------
		//seach for used DBs
		//------------------
		for(def int i=0 ; i<tableSchemas.size() ; i++)
			for(def int j=0 ; j<listOfScripts.size() ; j++)
				for(def int k=0 ; k<listOfScripts[j].size() ; k++)
					if(listOfScripts[j][k].equals(tableSchemas[i]))
						foundDbs.add(tableSchemas[i])
		foundDbs = foundDbs.unique()
	}
	//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	def getMySqlTables(String folderName){
		def currentText
		additionalScripts.each{
			File currentFile = new File(it)
			currentText = currentFile.getText('UTF-8').toLowerCase()
			currentText = currentText.replaceAll("[^a-zA-Z0-9_]", " ")
			currentText = currentText.replaceAll(" +", " ")
			currentText = currentText.split(" ")
			listOfScripts.add(currentText)
			println currentText.size()
		}
		
	def finalScript = ''
	def stmt
		//----------------------------------
		//Extract table names from databases
		//----------------------------------
		def tableQuery;
		def tableNames = []
		def foundDbTables = []
		foundDbs.each{
			tableQuery = "select TABLE_NAME from information_schema.tables where TABLE_TYPE='BASE TABLE' AND TABLE_SCHEMA= $it"
			sql.eachRow(tableQuery){
				row-> row[0]
				tableNames.add(row[0])
			}
		}
		//---------------------------------------------
		//Next we need to find out what tables are used
		//---------------------------------------------
		def usedTables = []
		for(def int i=0 ; i<tableNames.size() ; i++)
			for(def int j=0 ; j<listOfScripts.size() ; j++)
				for(def int k=0 ; k<listOfScripts[j].size() ; k++)
					if(listOfScripts[j][k].equals(tableNames[i]))
						usedTables.add(tableNames[i])
		usedTables = usedTables.unique()
		//----------------------------------------------------------------------------------------
		//for each database get tables and see if there is equality in names for ambiguity reasons
		//----------------------------------------------------------------------------------------
		tableNames = []
		foundDbs.each{
			tableQuery = 'show tables from ' + it
			sql.eachRow(tableQuery){
				row-> row[0]
				tableNames.add(row[0])
			}
			for(def int i=0 ; i<usedTables.size() ; i++)
				for(def int j=0 ; j<tableNames.size() ; j++)
					if(usedTables[i].equals(tableNames[j]))
						finalTables.add(it+'.'+usedTables[i])
			tableNames = []
		}
		finalTables.addAll(dependencyTables)
		finalTables = finalTables.unique()
		println finalTables
		//---------------------
		//get constraint tables
		//---------------------
		def constTables = []
		def currentTable = []
		finalTables.each{
			currentTable = it.split('\\.')
			stmt = "SELECT REFERENCED_TABLE_NAME FROM information_schema.KEY_COLUMN_USAGE WHERE CONSTRAINT_SCHEMA = ${currentTable[0]} AND TABLE_NAME = ${currentTable[1]} AND REFERENCED_TABLE_NAME != 'null'"
			sql.eachRow(stmt){
				row-> constTables.add(currentTable[0]+'.'+row[0])
			}
		}
		constTables.each{
			finalTables.add(it)
		}
		finalTables = finalTables.unique()
		//----------------------
		//Create those databases
		//----------------------
		foundDbs.each{
			stmt = 'SHOW CREATE DATABASE ' + it
			sql.eachRow(stmt){
				row-> finalScript <<= ('DROP DATABASE IF EXISTS ' + it + ';\n' + row[1] + ';\n')
			}
		}
		//-------------
		//Create tables
		//-------------
		finalTables.each{
			stmt = 'SHOW CREATE TABLE ' + it
			sql.eachRow(stmt){
				row-> finalScript <<= ('use ' + it.split('\\.')[0] + ';\n' + row[1] + ';\n')
			}
			
		}
		file << finalScript	
		File fh1 = new File(folderName+'/output_view.sql')
		def text = fh1.getText('UTF-8')
		file.append(text)
		
		fh1 = new File(folderName+'/output_trigger.sql')
		text = fh1.getText('UTF-8')
		file.append(text)
	}
	
	//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	def getMySqlViews(String folderName){
		def pathof = folderName+"/output_view.sql"
		viewFile = new File(pathof)
		viewFile.write('')
		def viewScript = ''
		def stmt
		//----------------------------------
		//Extract view names from databases
		//----------------------------------
		def viewQuery
		//contains all view name from all dbs
		def viewNames = []
		def foundDbViews = []
		foundDbs.each{
			viewQuery = "select TABLE_NAME from information_schema.tables where TABLE_TYPE='VIEW' AND TABLE_SCHEMA= ${it}"
			sql.eachRow(viewQuery){
				row-> row[0]
				viewNames.add(row[0])
			}
		}
		//---------------------------------------------
		//Next we need to find out what views are used
		//---------------------------------------------
		def usedViews = []
		for(def int i=0 ; i<viewNames.size() ; i++)
			for(def int j=0 ; j<listOfScripts.size() ; j++)
				for(def int k=0 ; k<listOfScripts[j].size() ; k++)
					if(listOfScripts[j][k].equals(viewNames[i]))
						usedViews.add(viewNames[i])
		usedViews = usedViews.unique()
		//----------------------------------------------------------------------------------------
		//for each database get tables and see if there is equality in names for ambiguity reasons
		//----------------------------------------------------------------------------------------
		if(usedViews){
			additionalScripts.add(folderName + '/output_view.sql')
			viewNames = []
			foundDbs.each{
				viewQuery = "select TABLE_NAME from information_schema.tables where TABLE_TYPE='VIEW' AND TABLE_SCHEMA= ${it}"
				sql.eachRow(viewQuery){
					row-> row[0]
					viewNames.add(row[0])
					//foundDbViews.add(it+'.'+row[0])
				}
				for(def int i=0 ; i<usedViews.size() ; i++)
					for(def int j=0 ; j<viewNames.size() ; j++)
						if(usedViews[i].equals(viewNames[j]))
							finalViews.add(it+'.'+usedViews[i])
				finalViews = finalViews.unique()
							
				viewNames = []
			}
			//---------------------
			//get dependency tables
			//---------------------
			//SELECT DISTINCT VIEW_NAME FROM INFORMATION_SCHEMA.VIEW_TABLE_USAGE WHERE TABLE_SCHEMA='DB'
			//SELECT DISTINCT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.VIEW_TABLE_USAGE WHERE TABLE_SCHEMA=
			def currentTable = []
			finalViews.each{
				currentTable = it.split('\\.')
				stmt = "SELECT DISTINCT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.VIEW_TABLE_USAGE WHERE TABLE_SCHEMA= ${currentTable[0]} AND VIEW_NAME= ${currentTable[1]}"
				sql.eachRow(stmt){
					row-> dependencyTables.add(row[0]+'.'+row[1])
				}
			}
			println dependencyTables
			finalViews = finalViews.unique()
			//-------------
			//Create tables
			//-------------
			finalViews.each{
				stmt = 'SHOW CREATE VIEW ' + it
				sql.eachRow(stmt){
					row-> viewScript <<= ('use ' + it.split('\\.')[0] + ';\n' + row[1] + ';\n')
				}
				
			}
			viewFile.write('')
			viewFile << viewScript	
		}
	}
	//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	def getMySqlTriggers(String folderName){
		
		def pathof = folderName+"/output_trigger.sql"
		triggerFile = new File(pathof)
		triggerFile.write('')
		def triggerScript = ''
		def stmt
		//----------------------------------
		//Extract view names from databases 
		//----------------------------------
		def triggerQuery
		//contains all view name from all dbs
		def triggerNames = []
		def foundDbTriggers = []
		foundDbs.each{
			triggerQuery = "SELECT TRIGGER_NAME FROM INFORMATION_SCHEMA.TRIGGERS WHERE TRIGGER_SCHEMA = ${it}"
			sql.eachRow(triggerQuery){
				row-> row[0]
				triggerNames.add(row[0])
			}
		}
		//---------------------------------------------
		//Next we need to find out what triggers are used
		//---------------------------------------------
		def usedTriggers = []
		for(def int i=0 ; i<triggerNames.size() ; i++)
			for(def int j=0 ; j<listOfScripts.size() ; j++)
				for(def int k=0 ; k<listOfScripts[j].size() ; k++)
					if(listOfScripts[j][k].equals(triggerNames[i]))
						usedTriggers.add(triggerNames[i])
		usedTriggers = usedTriggers.unique()
		//----------------------------------------------------------------------------------------
		//for each database get triggers and see if there is equality in names for ambiguity reasons
		//----------------------------------------------------------------------------------------
		if(usedTriggers){
			additionalScripts.add(folderName+'/output_trigger.sql')
			triggerNames = []
			foundDbs.each{
				triggerQuery = "SELECT TRIGGER_NAME FROM INFORMATION_SCHEMA.TRIGGERS WHERE TRIGGER_SCHEMA =  ${it}"
				sql.eachRow(triggerQuery){
					row-> row[0]
					triggerNames.add(row[0])
					//foundDbViews.add(it+'.'+row[0])
				}
				for(def int i=0 ; i<usedTriggers.size() ; i++)
					for(def int j=0 ; j<triggerNames.size() ; j++)
						if(usedTriggers[i].equals(triggerNames[j]))
							finalTriggers.add(it+'.'+usedTriggers[i])
				finalTriggers = finalTriggers.unique()
							
				triggerNames = []
			}
			//-------------
			//Create triggers
			//-------------
			finalTriggers.each{
				stmt = 'SHOW CREATE TRIGGER ' + it
				sql.eachRow(stmt){
					row-> triggerScript <<= ('use ' + it.split('\\.')[0] + ';\n' + 'delimiter |\n' + row[2] + ';\n|\n' + 'delimiter ;\n')
				}
				
			}
			triggerFile.write('')
			triggerFile << triggerScript	
		}
	}
	//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	def getMySqlProcedures(String folderName){}
	//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	def getMySqlFunctions(String folderName){}
}