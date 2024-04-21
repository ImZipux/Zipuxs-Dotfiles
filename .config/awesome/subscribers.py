import urllib.request
import json

CHANNELID = "YOUR CHANNEL ID HERE"
KEY       = "YOUR API HERE"

data = urllib.request.urlopen("https://www.googleapis.com/youtube/v3/channels?part=statistics&id="+CHANNELID+"&key="+KEY).read()

subs = json.loads(data)["items"][0]["statistics"]["subscriberCount"]

print("{:,d}".format(int(subs)))
