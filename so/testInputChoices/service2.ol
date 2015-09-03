include "service2interface.iol"

inputPort Service2Port {
	Location: "socket://localhost:8001"
	Protocol: sodep
	Interfaces: Service2Interface
}

main
{
	op2( nome )( result )
	{
		result = "Response is Service2"
	}
}