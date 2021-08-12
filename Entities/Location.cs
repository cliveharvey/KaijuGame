using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KaijuGame.Entities
{
    class Location
    {
        private string city;
        private string[] cities = new string[] 
        {
            "Prague, Czech Republic",
            "Istanbul, Turkey",
            "Jerusalem, Israel",
            "Accra, Ghana",
            "Colombo, Sri Lanka",
            "Buenos Aires, Argentina",
            "Reykjavík, Iceland",
            "Denver, United States",
            "Abuja, Nigeria",
            "Nashville, TN, United States",
            "Bratislava, Slovakia",
            "Lima, Peru",
            "Bamako, Mali",
        };
        public Location (string CountryName)
        {
            city = CountryName;
        }

        public Location()
        {
            city = RandomCity();
        }

        public string City
        {
            get => city;
            set => city = value;
        }

        public string RandomCity()
        {
            var r = new Random();
            return cities[r.Next(cities.Length - 1)];
        }
    }
}
