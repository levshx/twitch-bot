import std/[httpclient, json, strutils], os

let
    GoogleAPIKey = readFile(getAppDir() / "google_key.key")

proc validateURL*(url: string): bool =
    let client = newHttpClient()
    client.headers = newHttpHeaders({ "Content-Type": "application/json" })

    let body = %*{
        "client": {
        "clientId":      "levshx",
        "clientVersion": "1.5.2"
        },
        "threatInfo": {
        "threatTypes":      ["THREAT_TYPE_UNSPECIFIED", "UNWANTED_SOFTWARE", "POTENTIALLY_HARMFUL_APPLICATION", "MALWARE", "SOCIAL_ENGINEERING"],
        "platformTypes":    ["WINDOWS"],
        "threatEntryTypes": ["URL", "THREAT_ENTRY_TYPE_UNSPECIFIED", "THREAT_ENTRY_TYPE_UNSPECIFIED"],
        "threatEntries": [            
            {"url": url},
        ]
        }
    }
    let response = client.request("https://safebrowsing.googleapis.com/v4/threatMatches:find?key=" & GoogleAPIKey, httpMethod = HttpPost, body = $body)
    result = response.body.len < 5
    