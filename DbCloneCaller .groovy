


//------------------------------
def user = 'root'
def pass = 'med123'
def folderName = 'temp_sql_scripts'
//------------------------------


def tools = new GroovyScriptEngine( '.' ).with {
loadScriptByName( 'DbClone.groovy' )
}
this.metaClass.mixin tools
getReady(user, pass, folderName)

//------------------------------
getMySqlViews(folderName)
getMySqlTriggers(folderName)
getMySqlProcedures(folderName)
getMySqlFunctions(folderName)
getMySqlTables(folderName)