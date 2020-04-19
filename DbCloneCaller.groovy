


//------------------------------
def user = 'root'
def pass = 'pixid123'
def folderName = 'PATT_UTILS/sql'
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
