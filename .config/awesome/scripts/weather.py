import urllib.request
import json

LAT = "LATITUDE GOES HERE"
LON = "LONGITUDE GOES HERE"
KEY = "KEY GOES HERE"

data = urllib.request.urlopen("https://api.openweathermap.org/data/2.5/weather?lat="+LAT+"&lon="+LON+"&appid="+KEY+"&units=imperial").read()

icon = json.loads(data)["weather"][0]["icon"]
description = json.loads(data)["weather"][0]["description"]
temperature = json.loads(data)["main"]["temp"]

if (icon == "01d"):
	print(f" {int(temperature)}°F\n{description}")
elif (icon == "02d"):
	print(f" {int(temperature)}°F\n{description}")
elif (icon == "03d"):
	print(f" {int(temperature)}°F\n{description}")
elif (icon == "04d"):
	print(f" {int(temperature)}°F\n{description}")
elif (icon == "09d"):
	print(f" {int(temperature)}°F\n{description}")
elif (icon == "10d"):
	print(f" {int(temperature)}°F\n{description}")
elif (icon == "11d"):
	print(f" {int(temperature)}°F\n{description}")
elif (icon == "13d"):
	print(f" {int(temperature)}°F\n{description}")
elif (icon == "50d"):
	print(f" {int(temperature)}°F\n{description}")
elif (icon == "01n"):
	print(f" {int(temperature)}°F\n{description}")
elif (icon == "02n"):
	print(f" {int(temperature)}°F\n{description}")
elif (icon == "03n"):
	print(f" {int(temperature)}°F\n{description}")
elif (icon == "04n"):
	print(f" {int(temperature)}°F\n{description}")
elif (icon == "09n"):
	print(f" {int(temperature)}°F\n{description}")
elif (icon == "10n"):
	print(f" {int(temperature)}°F\n{description}")
elif (icon == "11n"):
	print(f" {int(temperature)}°F\n{description}")
elif (icon == "13n"):
	print(f" {int(temperature)}°F\n{description}")
elif (icon == "50n"):
	print(f" {int(temperature)}°F\n{description}")
else:
	print(f"{icon} {int(temperature)}°F\n{description}")
#"01d" = "clear-sky",
#"02d" = "few-clouds",
#"03d" = "scattered-clouds",
#"04d" = "broken-clouds",
#"09d" = "shower-rain",
#"10d" = "rain",
#"11d" = "thunderstorm",
#"13d" = "snow",
#"50d" = "mist",
#"01n" = "clear-sky-night",
#"02n" = "few-clouds-night",
#"03n" = "scattered-clouds-night",
#"04n" = "broken-clouds-night",
#"09n" = "shower-rain-night",
#"10n" = "rain-night",
#"11n" = "thunderstorm-night",
#"13n" = "snow-night",
#"50n" = "mist-night"
