include "service1interface.iol"

inputPort Service1Port {
	Location: "socket://localhost:8000"
	Protocol: sodep
	Interfaces: Service1Interface
}

main
{
	op1( nome )( result )
	{
		for ( i=0 , i<1000 , i++ )
		
		
		result = "Response is Service1 " + nome
	}
}