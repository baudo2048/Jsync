include "console.iol"
include "file.iol"
include "jsync.iol"


outputPort JSynchClient {
	Location: "socket://localhost:8003"
	Protocol: sodep
	//Location: "local"
	Interfaces: ClientInterface
}



main
{
	// Maybe binding can take place on init zone
	registerForInput@Console()();
	

	//command = "connect";
	while( command != "close" ){
		//println@Console( "Insert new command" )();
		print@Console( "> " )();
		in( command );
		
		/*
		*	Author: Baudo Giuseppe
		*/
		if ( command=="listServers" ) {
			listServers@JSynchClient()(ris);
			println@Console("ELENCO SERVER REGISTRATI")();
			if(#ris.repoName>0){
				for(i=0,i<#ris.repoName,i++){
					println@Console((i+1) + " " + ris.repoName[i])()
				}
			} else {
				println@Console("Nessun server registrato")()
			}
			
		} 
		
		/*
		*	Author: Baudo Giuseppe
		*/
		else if ( command=="addServer" ) {

			print@Console("Insert server name: ")();
			in (server.serverName);
			//println@Console("")();  
			print@Console("Insert server address: ")();
			in (server.address);
			
			addServer@JSynchClient(server)(vend);
			if (vend){
				println@Console("Registrazione riuscita!")()	
			} else{
				println@Console("Problema di registrazione")()
			}
			
			
		} 

		/*
		*	Author: Baudo Giuseppe
		*
		*	Retrieve the list of repos for each registered server.
		*/
		else if (command == "listNewRepos" ) {
			listNewRepos@JSynchClient()(listReposType);
			println@Console("LIST OF ALL REPOS")();
			println@Console("Server\t\t\tRepoName")();
			println@Console("listReposType: " + #listReposType.server)();
			//println@Console("listReposType2: " + #listReposType)();
			for(i=0,i<#listReposType.server,i++){
				for(j=0,j<#listReposType.server[i].repos,j++){
					println@Console(listReposType.server[i].serverName + "\t\t\t" + listReposType.server[i].repos[j])()		
				}
				
			}
			
		} 
		
		/*
		*	Author: Baudo Giuseppe
		*
		*/
		else if (command == "listRegRepos" ) {
			listRegRepos@JSynchClient()(listReposType);
			println@Console("LIST OF REGISTERED REPOS")();
			println@Console("RepoID\t\t\tServerID\tRepoName\tRepoPath")();
						
			for(i=0,i<#listReposType.server,i++){
				for(j=0,j<#listReposType.server[i].repos,j++){
					println@Console((i+1) + "\t\t\t" + listReposType.server[i].serverName + "\t\t" + listReposType.server[i].repos[j].name + "\t" + listReposType.server[i].repos[j].path)()		
				}
				
			}
		} 

		/*
		* Author: Baudo Giuseppe
		*
		*	todo: controllo su id ricevuto che sia un numero valido
		*/
		else if (command == "removeServer" ) {
			print@Console( "Insert server id: " )();
			in(serverToRemove);
			removeServer@JSynchClient(int(serverToRemove))(resp);
			if(resp){
				println@Console("Server removed")()
			} else {
				println@Console("ERROR: A problem occurred")()
			}
		}

		/*
		* Author: Baudo Giuseppe
		*
		*/
		else if (command == "addRepository" ) {
			print@Console ( "Server ID:" )();
			in(addRepoType.serverName);

			print@Console ( "Repository Name:" )();
			in(addRepoType.repoName);

			print@Console ("Local Path: ")();
			in(addRepoType.localPath);
			
			addRepoType.address="";
			
			println@Console("JSynchClient.ol - instanceof addRepoType: " + (addRepoType instanceof AddRepoType)) ();
			addRepository@JSynchClient(addRepoType)(resp)
		} 

		/*
		*	Author: Baudo Giuseppe
		*	
		*/
		else if (command == "push" ) {			
			print@Console( "Insert repository id: " )();
			in(repositoryToPush);
			push@JSynchClient(int(repositoryToPush))(resp);
			if(resp){
				println@Console("Repository pushed")()
			} else {
				println@Console("ERROR: A problem occurred")()
			}
		} 
		
		/*
		*	Author: Baudo Giuseppe
		*	
		*/		
		else if (command == "pull" ) {
			//TODO INSERISCO MESSAGGIO: ATTENZIONE I FILE LOCALI NON TROVATI SUL REPO VERRANNO ELIMINATI.
		
			print@Console( "Insert repository id: " )();
			in(repositoryToPull);
			pull@JSynchClient(int(repositoryToPull))(resp);
			if(resp){
				println@Console("Repository pulled")()
			} else {
				println@Console("ERROR: A problem occurred")()
			}
		} 
		
		/* 
		*	Author: Baudo Giuseppe
		*	
		*/
		else if (command == "removeRepository" ) {
			print@Console( "Insert repository id: " )();
			in(repositoryToRemove);
			removeRepository@JSynchClient(int(repositoryToRemove))(resp);
			if(resp){
				println@Console("Repository removed")()
			} else {
				println@Console("ERROR: A problem occurred")()
			}
		} 

		/*
		*	Author Baudo Giuseppe
		*	Used to connect to a Client or to switch from a Client to another. 	
		*
		*/
		else if (command == "connect"){
			print@Console("Insert Client Location (eg socket://localhost:8000) > ")();	
			in(JSynchClient.location);

			print@Console("Insert Client Protocol (eg sodep) > ")();
			in(JSynchClient.protocol);
	
			scope (checkForClient) {
				install(default => println@Console("Client not found. Location and/or Protocol incorrect.\nUse <<connect>> command to try again.")());
				ping@JSynchClient()(resp);
				if( resp ){
					println@Console("Connection established")()
				}	
			}


		} 

		/*
		*	Author: Baudo Giuseppe
		*	
		*	Print the commands list
		*/
		else if (command == "help" ) {
			println@Console( "COMMANDS LIST (commands are case sensitive):" )();
			println@Console( "addServer         -   Add a Server in the local Client" )();
			println@Console( "removeServer      -   Remove a Server from the local Client" )();
			println@Console( "listServers       -   List all servers registered in the local Client" )();
			println@Console( "addRepository     -   Add a remote Repository in the local Client" )();
			println@Console( "removeRepository  -   Remove Repository from local Client" )();
			println@Console( "listNewRepos      -   List all repositories from all registered Server" )();
			println@Console( "listRegRepos      -   List local repositories registered in the local Client" )();
			println@Console( "push              -   Send files locate in a local Client to remote repository" )();
			println@Console( "pull              -   Retrieve files locate in a remote repository to local Client" )();
			println@Console( "delete            -   Delete repository from local Client and remote Server" )();
			println@Console( "connect           -   Connect/Switch this CLI to a specified Client" )();
			println@Console( "help              -   Show this help" )();
			println@Console( "close             -   Close the CLI" )()
		} else if ( command=="close" ) {
			println@Console( "chiusura client" )()
		} else {
			println@Console( command + " isn't a correct command!!!")()
		}


	}


}
