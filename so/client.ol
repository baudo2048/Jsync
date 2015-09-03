include "console.iol"
include "file.iol"
include "jsync.iol"

execution{ concurrent }

//outputPort portName {
//	Location: "socket://localhost:8003"
//	Protocol: sodep
//	Interfaces: ClientInterface
//}

outputPort JSynchServer {
	//Location: "socket://localhost:8001"
	Protocol: sodep
	Interfaces: ServerInterface
}

inputPort JSynchClient {
	Location: "socket://localhost:8003"
	//Location: "local"
	Protocol: sodep
	Interfaces: ClientInterface
	//Aggregates: portName
}


/* 
*	Author: Baudo Giuseppe
*/
init{
	println@Console("Starting client...")();
	global.numServer=-1;				// Hold a pointer to the last registered Server
	global.numRepo=-1;					// Hold a pointer to the last registered Repo
	

	// global.serverList      		// Array of RepoType. Hold a list of registered Servers
	// global.repoList  			// Array of AddRepoType. Hold a list of registered Repos
	REMOVED = "removed";
	println@Console("Client Started.")()
}


main
{
	
	/* 
	*	Author: Baudo Giuseppe
	* 	
	*	TODO: AGGIUNGERE UN CHECK SE ILSERVER IS ACTIVE?
	*
	*/
	[addServer( server )( resp ){
		
		synchronized( tokenServer ){
			global.numServer = global.numServer+1;
			//server.repoName=server.serverName;
			global.serverList[global.numServer] << server;
			
			// USERFUL LINES FOR DEBUGGING
			//println@Console("Ricevuto server name: " + server.serverName)();
			println@Console("Ricevuto server address: " + server.address)();
			//println@Console("Registrato server name: " + global.serverList[global.numServer].serverName)();
			println@Console("Registrato server address: " + global.serverList[global.numServer].address)();
			resp=true  
		}
		
	}]{
		println@Console("addServer requested")()
	}

	
	/* 
	*	Author: Baudo Giuseppe
	*	
	*	
	*/
	[listServers()(resp){
		synchronized( tokenServer ){
			for(i=0,i<=global.numServer,i++){			
				if(global.serverList[i].serverName!="removed"){
					resp.repoName[i]=global.serverList[i].serverName	
				} else {
					resp.repoName[i]="removed"
				}
			
			}  
		}
		

		
	}]{
		println@Console("listServers requested")()
	}

	/* 
	*	Author: Baudo Giuseppe
	*	
	*	
	*/
	[removeServer(id)(resp){
		synchronized( tokenServer ){
			global.serverList[id-1].serverName="removed";
			global.serverList[id-1].address="removed";
			resp=true  
		}
		
	}]{
		println@Console("removeServer requested")()
	}


	[ping()(resp){
		resp=true
	}]{
		println@Console("ping requested")()
	}

	/*
	*	Author: Baudo Giuseppe
	*
	*	Add a repository to local repositories.
	* 	If localPath doesn't exist it create a localDir.
	*
	*	TODO: FARE IL BINDING CON IL SERVER CORRETTO	
	*/

	[addRepository( addRepoType )( resp ){
		synchronized( tokenServer ){	//Altro token?
			global.numRepo++;			
			
			repoType.repoName=addRepoType.repoName;
			println@Console("client - addRepository - repoType.repoName: " + repoType.repoName)();
			JSynchServer.location = global.serverList[int(addRepoType.serverName)-1].address;
			println@Console("client - addRepository - JSynchServer.location: " + JSynchServer.location)();
			
			// TODO DEVE CONTROLLARE SE localPath is directory

			exists@File(addRepoType.localPath)(test);
			if(!test){
				mkdir@File(addRepoType.localPath)()
			};
			scope (checkForServer){
				install (default => println@Console("A problem occurred on connection with server " + global.serverList[int(addRepoType.serverName)-1].serverName + " at location: " + JSynchServer.location)());
				createRepository@JSynchServer(repoType)()
			};
			
			// Register this repository into local repositories (global.repoList)
			addRepoType.address = global.serverList[int(addRepoType.serverName)-1].address;
			//addRepoType.serverName = global.serverList[int(addRepoType.serverName)-1].serverName;
			global.repoList[global.numRepo] << addRepoType;
			println@Console("client - addRepository - global.addRepoType.serverName: " + global.repoList[global.numRepo].serverName)();
			println@Console("client - addRepository - global.addRepoType.address: " + global.repoList[global.numRepo].address)();
			println@Console("client - addRepository - global.addRepoType.localPath: " + global.repoList[global.numRepo].localPath)();
			println@Console("client - addRepository - global.addRepoType.repoName: " + global.repoList[global.numRepo].repoName)();

			
			resp=true  
		}
		
	}]{
		println@Console("addRepository requested")()
	}


	/*
	*	Author: Baudo Giuseppe
	*
	*/
	
	[listNewRepos()(listReposType){
		// TODO devo scorrere tutti i server registrati e per ognuno di essi lanciare listRepositories
		// TODO da sincronizzare
		synchronized( tokenServer ){
			for(i=0,i<=global.numServer,i++){
				JSynchServer.location = global.serverList[i].address;
				println@Console("client.ol - listNewRepos - global.listServers[i].address: " + global.serverList[i].address)();
				println@Console("client.ol - listNewRepos - JSynchServer.location: " + JSynchServer.location)();
				
				listReposType.server[i].serverName = global.serverList[i].serverName;
				scope (checkForServer){
					install (default => println@Console("A problem occurred on connection with server " + global.serverList[i].serverName + " at location: " + JSynchServer.location)());
					listRepositories@JSynchServer()(repoType);
					for(j=0,j<#repoType.repoName,j++){
						listReposType.server[i].repos[j]=repoType.repoName[j];
						println@Console("client - listNewRepos - listReposType - " + listReposType.server[i].repos[j])()	
					}
				}
								
				
				
				
			}
		}
		
	}]{
		println@Console("listNewRepos requested")()
	}
	
	
	/*
	*	Author: Baudo Giuseppe
	*
	*/
	
	[listRegRepos()(listReposType){
		
		synchronized( tokenServer ){
			for(i=0,i<=global.numRepo,i++){			
				
				listReposType.server[i].serverName = global.repoList[i].serverName;
				listReposType.server[i].repo.name=global.repoList[i].repoName;
				listReposType.server[i].repo.path=global.repoList[i].localPath;
										
				println@Console("client - listRegRepos - global.repoList[i].serverName: " + global.repoList[i].serverName)();
				println@Console("client - listRegRepos - global.repoList[i].repoName: " + global.repoList[i].repoName)();
				println@Console("client - listRegRepos - global.repoList[i].localPath: " + global.repoList[i].localPath)()
									
			}  
						
		}
		
	}]{
		println@Console("listNewRepos requested")()
	}
	
	/*
	*	Author: Baudo Giuseppe
	*
	*/
	[removeRepository(idRepo)(resp){
		println@Console("client - removeRepository - started")();
		synchronized( tokenServer ){
			global.repoList[idRepo-1].serverName="removed";
			global.repoList[idRepo-1].repoName="removed";
			resp=true  
		}
	}]{
		println@Console("removeRepository requested")()
	}
	
	/*
	*	Author: Baudo Giuseppe
	*
	*/
	[push(idRepo)(resp){
		//TODO DEVO PRELEVARE I DATI DEL SERVER E DEL REPOSITORY
		
		//FACCIO LA PUSH
		//push@JSynchServer()();
		
		//RITORNO LA RISPOSTA
		resp=true
	}]{
		println@Console("push requested")()
	}
	
	/*
	*	Author: Baudo Giuseppe
	*
	*/
	
	[pull(idRepo)(resp){
		// in questo punto del programma non posso pullare un repo non registrato localmente.
		// quindi devo trovare la cartella e il file .version
		
		// Get repoName from registered repo (repoList)
		repoType.repoName=global.repoList[idRepo-1].repoName;		
		
		// Get serverID that will be used to retreive server address from registered server (serverList)
		serverID = int(global.repoList[idRepo-1].serverName);
		JSynchServer.location = global.serverList[serverID-1].address;
		
		// LOGS
		println@Console("client - pull - repoType.repoName: " + repoType.repoName)();
		println@Console("client - pull - serverID: " + serverID)();
		println@Console("client - pull - JSynchServer.location: " + JSynchServer.location)();
				
		pull@JSynchServer(repoType)(filesType);
		
		// Get client repository localPath 
		localPath = global.repoList[idRepo-1].localPath;
		println@Console("client - pull - localPath is: " + localPath)();
		
		// Get client local version file
		readFileRequest.filename = localPath + "/" + ".version";
		readFile@File(readFileRequest)(response);
		localVersion = int(response);
		
		//TODO LOGICA DI BUSINESS. SOVRASCRIVIAMO TUTTO? MERGE?
		//se version uguale non faccio nulla
		
		if(filesType.version!=localVersion){
			println@Console("client - pull - not same repo, do something")();
	
			for(i=0,i<#filesType.file,i++){
				//LA SEGUENTE RIGA DA SPOSTARE IN UN AREA AD HOC PRIMA DOVE CANCELLO TUTTI I FILE DELLA CARTELLA LOCALPATH
				exists@File(localPath + "/" + filesType.file[i].path)(test);
				if(test){
					delete@File(localPath + "/" + filesType.file[i].path)()
				};
				writeFileRequest.filename=localPath + "/" + filesType.file[i].path;
				writeFileRequest.content=filesType.file[i].content;
				writeFile@File(writeFileRequest)()
			}
			
			
		} else {
			println@Console("client - pull - same repo, do nothing")()
		};
		
		//altrimenti cancello tutto e trasferisco i dati
		resp=true
	}]{
		println@Console("pull requested")()
	}

}
