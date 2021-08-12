using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KaijuGame.Entities
{
    class Location
    {
        private string country;
        public Location (string CountryName)
        {
            country = CountryName;
        }

        public string Country
        {
            get => country;
            set => country = value;
        }
    }
}
