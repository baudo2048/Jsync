include "console.iol"
include "file.iol"
include "jsync.iol"

execution{ concurrent }

inputPort JSyncServer {
	Location: "socket://localhost:8002"
	Protocol: sodep
	Interfaces: ServerInterface
}


/*
*	TO DO ON START UP 1) ASK FOR LOCATION AND PROTOCOL. 2) ASK FOR FOLDER TO CREATE/SYNCHRONIZE 
*/

init {
	println@Console("Starting Server...")();
	registerForInput@Console()();

	println@Console("Server Settings")();

	//TODO IF Directory dosen't exist create it.
	
	print@Console("Insert Server Repositories Directory: ")();
	in(dir);
	global.reposDir = dir;
	println@Console("serverdir is: " + global.reposDir)();
	println@Console("Server Started.")()
}

main
{
	

	/*
	*	Author: Baudo Giuseppe
	*
	*	TODO: CREARE IL FILE .version da inserire nella cartella del repository	
	*/
	[createRepository( repoType )(){
		
		exists@File(global.reposDir + "/" + repoType.repoName)(test);
		println@Console("server - createRepository - repoType.repoName is " + repoType.repoName)();
		println@Console("server - createRepository - reposDir is " + global.reposDir)();
		if(!test){
			println@Console("server - createRepository - repo dir doesn't exist " + repoType.repoName)();
			mkdir@File(global.reposDir + "/" + repoType.repoName)();
			
			//Create .version file
			writeFileRequest.content = "1";
			writeFileRequest.filename = global.reposDir + "/" + repoType.repoName + "/.version";				
				
			writeFile@File(writeFileRequest)()
		}
		
	}]{
		println@Console("server - createRepository requested.")()
	}


	/*
	*	Author: Baudo Giuseppe
	*
	*	
	*/
	[listRepositories()(repoType){
		listRequest.directory = global.reposDir;
		list@File(listRequest)(listResponse);
		for(i=0,i<#listResponse.result,i++) {
			println@Console(listResponse.result[i])();
			repoType.repoName[i]=listResponse.result[i]
		}
	}]{
		println@Console("listRepositories requested")()
	}
	
	/*
	*	Author: Baudo Giuseppe
	*
	*/
	[pull(repoType)(filesType){
		//CONTROLLO SE IL REPO ESISTE
		
		//LIST SU REPOSITORY
		listRequest.directory= global.reposDir + "/" + repoType.repoName;
		println@Console("server - pull - listRequest.directory: " + listRequest.directory)();
		
		exists@File(listRequest.directory)(test);
		println@Console("server - pull - listRequest.directory exists?: " + test)();
	
		filesType.repoName=repoType.repoName;
		
		list@File( listRequest )( listResponse );
		println@Console("server - pull - #listResponse.result: " + #listResponse.result)();
		for(i=0,i<#listResponse.result,i++) {
			println@Console("server - pull - listReponse.result[i]: " + listResponse.result[i])();
			readFileRequest.filename = global.reposDir + "/" + repoType.repoName + "/" + listResponse.result[i];
			readFile@File( readFileRequest )( response );
			filesType.file[i].path=listResponse.result[i];
			filesType.file[i].content=response;
			
			println@Console("server - pull - listResponse.result[i]: " + listResponse.result[i] + "***")();
			if(listResponse.result[i]==".version"){
				filesType.version = int(response);
				println@Console("server - pull - .version: " + int(response))()
			}
			
			//AGGIUNGO I FILE A filesType
		}
		
		
		
	}]{
		println@Console("pull requested")()
	}
	

}
