import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

import javax.net.ssl.SSLServerSocketFactory;

public class Server extends Thread {

	Socket client;
	static ServerSocket serverSocket;
	static {
		try {
			serverSocket = new ServerSocket(8080);
			//SSLServerSocketFactory ssf = (SSLServerSocketFactory)SSLServerSocketFactory.getDefault();
			//serverSocket = ssf.createServerSocket(9090);
			 
		} catch (IOException e) {
			throw new RuntimeException("Não foi possível abrir a porta " +
					serverSocket.getLocalPort() + ".");
		}
	}
	
	public Server(Socket client) {
		this.client = client;
	}
	
	public void run() {
		System.out.println(Thread.currentThread().getName());
		try {			
			Protocol.handle(client.getInputStream(), client.getOutputStream());
		} catch (IOException e) {
			System.out.println("Não foi possível aceitar a requisição.");
			System.exit(1);
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(2);
		}
	}
	public static void main(String[] args) throws IOException {
		while (true) {
			Socket clientSocket = serverSocket.accept();
			new Server(clientSocket).start();
		}
	}
}
