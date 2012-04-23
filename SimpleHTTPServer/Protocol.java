import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.URISyntaxException;


public class Protocol {
	
	static String rootPath;// = "home/pedro/Dropbox/apps/eclipse/workspace/SimpleHTTPServer/www";
			
	static class FileContent {
		byte[] content;
		String charset;
	}
	
	private Protocol() {}
	
	static public void handle(InputStream input, OutputStream output) throws IOException {
		
		if (rootPath == null) {
			rootPath = new File(Protocol.class.getResource("/").getPath(), "www").getAbsolutePath();
		}
		String[] tmp = new BufferedReader(new InputStreamReader(input)).readLine().split(" ");
		
		System.out.println(tmp[0] + " " + tmp[1] + " " + tmp[2]);
		
		String method  = tmp[0];
		String path    = tmp[1];
		String version = tmp[2];
		
		if (!version.equals("HTTP/1.0")) {
			sendBadResponse("505 HTTP Version Not Supported", output);
			return;
		}

		
		else if (!method.equals("GET")) {
			sendBadResponse("400 Bad Request", output);
			return;
		}
		
		else try {
			FileContent content = getContent(path);
			byte[] response = ("HTTP/1.0 200 OK"
								+ "\r\n"
								+ "Server: Servidor Fuleiro v0\r\n"
								+ "Content-Type: text/html; charset=" + content.charset + "\r\n"
								+ "Content-Lenght: " + content.content.length + "\r\n"
								+ "\r\n").getBytes("US-ASCII");
			
			byte[] raw = new byte[response.length + content.content.length];
			System.arraycopy(response, 0, raw, 0, response.length);
			System.arraycopy(content.content, 0, raw, response.length, content.content.length);
			
			output.write(raw);
			output.close();
			
		} catch (IOException e) {
			sendBadResponse("404 Not Found", output);
		} catch (Exception e) {
			sendBadResponse("500 Internal Server Error", output);
		}
	}
	
	static private void sendBadResponse(String res, OutputStream output) throws IOException {
		String response = "HTTP/1.0 " + res
						+ "\r\n"
						+ "Server: Servidor Fuleiro v0\r\n";
		output.write(response.getBytes("US-ASCII"));
		output.close();
	}
	
	static private FileContent getContent(String path) throws UnsupportedEncodingException, URISyntaxException, IOException {
		
		File file = new File(rootPath, path);		
		FileContent content = new FileContent();
		
		if (!file.exists())
			throw new IOException();
		
		if (file.isDirectory()) {
			content.content = new Lister(rootPath).list(path).getBytes("UTF-8");
			content.charset = "UTF-8";
			return content;
		}
		
		// Feio, muito feio.
		FileInputStream in = new FileInputStream(file);
		int length = (int)file.length();
		content.content = new byte[length];
		in.read(content.content);
		content.charset = "UTF-8";
		return content;
	}
}
