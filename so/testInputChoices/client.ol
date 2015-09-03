include "console.iol"
include "Service1Interface.iol"
include "Service2Interface.iol"

outputPort Service1 {
Location: "socket://localhost:8000"
Protocol: sodep
Interfaces: Service1Interface
}

outputPort Service2 {
Location: "socket://localhost:8001"
Protocol: sodep
Interfaces: Service2Interface
}

main {
[ op1( nome )( response ) {
	op1@Service1( "nome" )( response )
} ] { println@Console( response )() }

[ op2( nome )( response ) {
	op2@Service2( "nome" )( response ) 
}] { println@Console( response )() }
}