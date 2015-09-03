type AddServerType: void {
	.serverName: string
	.address: string
}

type RepoType: void {
	.repoName*: string
}

type AddRepoType: void {
	.serverName: string
	.address: string
	.localPath: string
	.repoName: string
}

type FilesType: void {
	.repoName: string
	.version: int
	.file*: void {
		.path: string
		.content: undefined   //raw???
	}
}

type ListReposType: void {		//TODO QUI HO TOCCATO DA METTERE A POSTO NEI PUNTI DEL PROGRAMMA
	.server*: void {
		.serverName: string
		.repo*: void {
			.name: string
			.path: string
		}
	}
}


interface ClientInterface {
	RequestResponse: 	
		addServer( AddServerType )( bool )

	RequestResponse:
		listServers(void)(RepoType)
	
	RequestResponse:	
		removeServer(int)(bool)

	RequestResponse:
		ping( void )( bool )

	RequestResponse:
		addRepository( AddRepoType )( bool )

	RequestResponse:
		listNewRepos(void)(ListReposType)		//TODO TYPE AD HOC PER SERVER REPONAME ...
	
	RequestResponse:
		listRegRepos( void )( ListReposType )
		
	RequestResponse:
		removeRepository(int)(bool)
		
	RequestResponse:
		push( int )( bool )

	RequestResponse:
		pull( int )( bool )
	
}



interface ServerInterface {
	RequestResponse: 
		createRepository( RepoType )( void )

	RequestResponse:
		listRepositories (void) (RepoType)
	
	//RequestResponse:
	//	push( PushRequest )( FilesType )
		
	RequestResponse:
		pull( RepoType )( FilesType )
}
