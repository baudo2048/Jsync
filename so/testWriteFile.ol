include "console.iol"
include "file.iol"

main
{
		
	writeFileRequest.content = "1";
	writeFileRequest.filename = "test/.version";				
				
	writeFile@File(writeFileRequest)()
}