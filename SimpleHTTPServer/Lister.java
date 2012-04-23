import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.StringWriter;
import java.io.Writer;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.LinkedHashMap;

public class Lister {
	
	URI root;
	
	public Lister(String root) throws URISyntaxException {
		this.root = new URI(root);
	}

	public String list(String dir) throws URISyntaxException, IOException {
		
		String template = getTemplate("dirlist.html");
		LinkedHashMap<String, String> files = getFilePaths(dir);
		
		
		String tmp = "";
		for (String p : files.keySet()) {
			tmp += "<a href='" + files.get(p) + "'>" + p + "</a><br>";
		}
		
		template = template.replace("{{DIR}}", dir);
		template = template.replace("{{FILES}}", tmp);
		
		return template;
	}

	private LinkedHashMap<String, String> getFilePaths(String dir) throws URISyntaxException {
		
		LinkedHashMap<String, String> files = new LinkedHashMap<String, String>();
		
		if (dir.equals("/"))
			files.put("..", "/");
		else
			files.put("..", root.relativize(new File(dir).getParentFile().toURI()).getPath());
		
		String[] tmp = new File(root.getPath(), dir).list();
		for (String f : tmp)
			files.put(f, new File(dir, f).getPath());
		
		return files;
	}
	
	
	// adaptado da internet
	private String getTemplate(String path) throws IOException, URISyntaxException {
		
		URL url = Lister.class.getResource(path);
		InputStream is = new FileInputStream(new File(url.toURI()));
		Writer writer = new StringWriter();

		char[] buffer = new char[1024];
		try {
			Reader reader = new BufferedReader(new InputStreamReader(is, "UTF-8"));
			int n;
			while ((n = reader.read(buffer)) != -1) {
				writer.write(buffer, 0, n);
			}
		} finally {
			is.close();
		}
		return writer.toString();
	}
}
