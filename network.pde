import java.net.*;

void listNetsEx() 
throws SocketException
{
  Enumeration nets = NetworkInterface.getNetworkInterfaces();
  for (Object netint : Collections.list(nets))
    displayInterfaceInformation((NetworkInterface)netint);
}
void displayInterfaceInformation(NetworkInterface netint) 
throws SocketException 
{
  System.out.println("Display name: " 
    + netint.getDisplayName());
  Enumeration addresses = netint.getInetAddresses();
  for (Object addr : Collections.list(addresses))
  {
    System.out.println(((addr instanceof Inet4Address) ? "ipv4 address: " : "ip address: ") + (InetAddress)addr);
  }
}

