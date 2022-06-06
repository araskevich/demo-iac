package main

import (
	"fmt"
	"hash/crc32"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
)

type DirectoryPath struct {
	pathToStaticFiles string
}

func (staticPath *DirectoryPath) staticFileHandler(writer http.ResponseWriter, request *http.Request) {
	log.Println("Request:", request.Method, request.URL.Path)

	switch request.Method {
	case "GET":

		switch request.URL.Path {
		case "/ui":
			serveStaticContent(writer, request, "index.html", filepath.Join(staticPath.pathToStaticFiles, "index.html"))

		case "/ui/":
			redirectToConfigurator(writer, request)

		case "/":
			redirectToConfigurator(writer, request)

		default:
			var ifFileExist, ifRequestParameterValid bool
			ifFileExist = checkIfFileExist(filepath.Join(staticPath.pathToStaticFiles, request.URL.Path))
			ifRequestParameterValid = verifyRequestParameter(request.URL.Path)
			log.Println("Verify request parameter:", "ifFileExist:", ifFileExist, "ifRequestParameterValid:", ifRequestParameterValid)

			if ifFileExist && ifRequestParameterValid {
				serveStaticContent(writer, request, getFirstParameter(request.URL.Path), filepath.Join(staticPath.pathToStaticFiles, request.URL.Path))
			} else {
				log.Println("Path to file does not exist:", request.URL.Path)
				echoUrlPathHandler(writer, request)
			}
		}

	default:
		log.Println("Request method not supported:", request.Method)
		echoUrlPathHandler(writer, request)
	}
}

func echoUrlPathHandler(writer http.ResponseWriter, request *http.Request) {
	writer.WriteHeader(http.StatusNotFound)
	log.Println("Cannot", request.Method, request.URL.Path)
	fmt.Fprintf(writer, "Cannot %s %s", request.Method, request.URL.Path)
}

func serveStaticContent(writer http.ResponseWriter, request *http.Request, fileName string, filePath string) {
	log.Println("Serve static content:", fileName, filePath)
	writer.Header().Set("Cache-Control", "public, max-age=0")
	writer.Header().Set("Connection", "keep-alive")
	writer.Header().Set("Keep-Alive", "timeout=5")
	writer.Header().Set("ETag", createEtag(fileName, filePath))
	http.ServeFile(writer, request, filePath)
}

func createEtag(fileName, filePath string) string {
	fileContent, err := ioutil.ReadFile(filePath)
	checkError(err)
	return etagHandler([]byte(fileName), []byte(fileContent))
}

func etagHandler(fileName []byte, fileContent []byte) string {
	crcFileName := crc32.ChecksumIEEE(fileName)
	crcFileContent := crc32.ChecksumIEEE(fileContent)
	return fmt.Sprintf(`W/"%08X-%d-%08X"`, crcFileName, len(fileContent), crcFileContent)
}

func redirectToConfigurator(writer http.ResponseWriter, request *http.Request) {
	log.Println("Redirect to \"/ui\" page")
	writer.Header().Set("Cache-Control", "public, max-age=0")
	writer.Header().Set("Connection", "keep-alive")
	writer.Header().Set("Keep-Alive", "timeout=5")
	http.Redirect(writer, request, "/ui", http.StatusMovedPermanently)
}

func checkIfFileExist(filePath string) bool {
	if _, err := os.Stat(filePath); err != nil {
		if os.IsNotExist(err) {
			return false
		}
	}
	return true
}

func getFirstParameter(httpUrlPath string) (parameter string) {
	for i := 0; i < len(httpUrlPath); i++ {
		if httpUrlPath[i] == '/' {
			parameter = httpUrlPath[i+1:]
		}
	}
	log.Println("Get first parameter, parameter:", parameter)
	return
}

func verifyRequestParameter(httpUrlPath string) bool {
	match, err := regexp.MatchString("\\.(gif|ico|jpg|jpeg|png|GIF|ICO|JPG|JPEG|PNG|css|js|woff|woff2|CSS|JS|WOFF|WOFF2|ttf|TTF)$", getFirstParameter(httpUrlPath))
	checkError(err)
	return match
}

func checkError(e error) {
	if e != nil {
		log.Println(e)
	}
}

func main() {
	ex, err := os.Executable()
	checkError(err)
	executablePath := filepath.Dir(ex)
	log.Println("Executable path:", executablePath)

	staticPath := &DirectoryPath{pathToStaticFiles: filepath.Join(executablePath, "public")}
	log.Println("Path to static files:", staticPath.pathToStaticFiles)

	// cat <<EOF > web_config.json
	// {
	// 	"certfile": "/cert/certfile.pem",
	// 	"keyfile": "/cert/keyfile.pem"
	// }
	// EOF

	// var webConfig map[string]string
	// webConfigFile, err := ioutil.ReadFile(filepath.Join(executablePath, "web_config.json"))
	// checkError(err)
	// err = json.Unmarshal([]byte(webConfigFile), &webConfig)
	// checkError(err)

	// certificateFilePath := webConfig["certfile"]
	// log.Println("Path to certificate file directory certfile:", certificateFilePath)
	// keyFilePath := webConfig["keyfile"]
	// log.Println("Path to certificate file directory keyfile:", keyFilePath)

	http.HandleFunc("/", staticPath.staticFileHandler)

	// uncomment to run via http
	log.Println("Running at port 5000 via http")
	err = http.ListenAndServe(":5000", nil)
	checkError(err)

	// command to generate a self-signed certificate
	// openssl req -nodes -new -x509 -keyout server.key -out server.cert -days 1100

	// uncomment to run via https
	// log.Println("Running at port 443 via https")
	// err = http.ListenAndServeTLS(":443", certificateFilePath, keyFilePath, nil)
	// checkError(err)
}
