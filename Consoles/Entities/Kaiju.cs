using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KaijuGame.Consoles.Entities
{
    class Kaiju
    {
        private string size;
        private int difficulty;

        public Kaiju(string kaijuSize, int difficultyRating)
        {
            size = kaijuSize;
            difficulty = difficultyRating;
        }

        public string Size
        {
            get => size;
            set => size = value;
        }

        public int Difficulty
        {
            get => difficulty;
            set => difficulty = value;
        }
    }
}
