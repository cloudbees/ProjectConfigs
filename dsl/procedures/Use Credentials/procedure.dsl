import java.io.File

def procName = 'Use Credentials'
procedure procName, {
	step 'step',
    	  command: new File(pluginDir, "dsl/procedures/$procName/steps/step.sh").text 
}
  
