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
<pre><code>
{
	"in-progress": {
		"sprints_sisteron": {
			"name":"Les sprints de Sisteron"
		}
	},
	"recent": { ... }
}
</code></pre>

### Filter

Get al list of all the countries here: https://github.com/fousa/spoty/blob/master/Countries.plist

URL: /competitions/filter/:country/:year
Replace :country with the country key and :year with the year you want to search.

ex: http://soaringspot.heroku.com/competitions/filter/__us_/2012

EXAMPLE OUTPUT:
<pre><code>
{
	"__us_ (2012)": {
		"wgc20112": {
			"name": "32nd FAI World Gliding Championships"
		}
	}
}
</code></pre>
	
### Results

URL: http://soaringspot.heroku.com/competitions/:code/results
Replace :code with the competition key.

ex: http://soaringspot.heroku.com/competitions/wgc20112/results

OUTPUT:
<pre><code>
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
</code></pre>

### Pilots

URL: http://soaringspot.heroku.com/competitions/:code/results/:klass/pilots
Replace :code with the competition key and klass with the klass key from above.

ex: http://soaringspot.heroku.com/competitions/wgc20112/results/open/pilots

OUTPUT: 
<pre><code>
{
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
</code></pre>
	
### Day results

URL: http://soaringspot.heroku.com/competitions/:code/results/:klass/days/:day
Replace :code with the competition key, klass with the klass key from above and day with the day key from above.

ex: http://soaringspot.heroku.com/competitions/wgc20112/results/open/days/day10

OUTPUT: 
<pre><code>
{
	"daily": [
		{
			"cn":"OG",
			"pen.":"",
			"dist.":"485.1km",
			"finish":"18:30:51",
			"pilot":"Oscar Goudriaan",
			"#":"1.",
			"time":"03:36:28",
			"points":"1000",
			"igc":"show.php5?auth=cflight/wgc20112.Open.28F_OG/1345195551",
			"start":"14:54:23",
			"glider":"JS1-B",
			"speed":"134.5km/h",
			"team":"RSA"
		}
	],
	"totals":[
		{
			"cn":"CD",
			"pilot":"Laurent Aboulin",
			"#":"1.",
			"total":"9416",
			"glider":"Quintus M",
			"team":"FRA"
		}
	]
}
</code></pre>
	

WHO
---

Created by Me!

With permission of the owner of the [Soaring Spot website](http://soaringspot.com/)
