Soaring Sport
=============

Soaring Spot is an website created by [Naviter](http://www.naviter.si). This website contains a list of ongoing competitions.

This application makes the [Soaring Sport website](http://soaringspot.com/) more accessible on iPhone and iPad.

This repo contains the code for the API website.

HOW
---

### Competitions

URL: http://soaringspot.heroku.com/competitions

EXAMPLE OUTPUT:
	{
		"in-progress": {
			"sprints_sisteron": {
				"name":"Les sprints de Sisteron"
			}
		},
		"recent": { ... }
	}

### Filter

Get al list of all the countries here: https://github.com/fousa/spoty/blob/master/Countries.plist

URL: /competitions/filter/:country/:year
Replace :country with the country key and :year with the year you want to search.

ex: http://soaringspot.heroku.com/competitions/filter/__us_/2012

EXAMPLE OUTPUT:
	{
		"__us_ (2012)": {
			"wgc20112": {
				"name": "32nd FAI World Gliding Championships"
			}
		}
	}
	
### Results

URL: http://soaringspot.heroku.com/competitions/:code/results
Replace :code with the competition key.

ex: http://soaringspot.heroku.com/competitions/wgc20112/results

OUTPUT:
	{
		"open": { 
			"name": "Open class",
			"days": {
				"00": {
					"name": "Day 11",
					"date": "yesterday",
					"key": "day11"
				}
			}
		}
	}

### Pilots

URL: http://soaringspot.heroku.com/competitions/:code/results/:klass/pilots
Replace :code with the competition key and klass with the klass key from above.

ex: http://soaringspot.heroku.com/competitions/wgc20112/results/open/pilots

OUTPUT: {
	"006": { 
		"results": { 
			"6": "19(561)",
			"11":"6(933)",
			"7":"8(941)",
			"8":"14(720)",
			"9":"2(993)",
			"1":"3(945)",
			"2":"6(976)",
			"3":"16(823)"
		},
		"info":{ 
			"cn":"72",
			"pilot":"Sylvain Gerbaud",
			"#":"13.",
			"total":"9432",
			"glider":"Quintus M",
			"team":"FRA"
		}
	}
}
	
### Day results

URL: http://soaringspot.heroku.com/competitions/:code/results/:klass/days/:day
Replace :code with the competition key, klass with the klass key from above and day with the day key from above.

ex: http://soaringspot.heroku.com/competitions/wgc20112/results/open/days/day10

OUTPUT: 
<code></pre>
{</br>
	"daily": [</br>
		{</br>
			"cn":"OG",</br>
			"pen.":"",</br>
			"dist.":"485.1km",</br>
			"finish":"18:30:51",</br>
			"pilot":"Oscar Goudriaan",</br>
			"#":"1.",</br>
			"time":"03:36:28",</br>
			"points":"1000",</br>
			"igc":"show.php5?auth=cflight/wgc20112.Open.28F_OG/1345195551",</br>
			"start":"14:54:23",</br>
			"glider":"JS1-B",</br>
			"speed":"134.5km/h",</br>
			"team":"RSA"</br>
		}</br>
	],</br>
	"totals":[</br>
		{</br>
			"cn":"CD",</br>
			"pilot":"Laurent Aboulin",</br>
			"#":"1.",</br>
			"total":"9416",</br>
			"glider":"Quintus M",</br>
			"team":"FRA"</br>
		}</br>
	]</br>
}
</code></pre>
	

WHO
---

Created by Me!

With permission of the owner of the [Soaring Spot website](http://soaringspot.com/)
