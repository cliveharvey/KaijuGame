using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KaijuGame.Entities
{
    enum KaijuSize
    {
        Small,
        Medium,
        Large,
        Huge,
        Massive,
        Gigantic,
    }
    class Kaiju
    {
        private int size;
        private int difficulty;

        public Kaiju(int kaijuSize, int difficultyRating)
        {
            size = kaijuSize;
            difficulty = difficultyRating;
        }

        public int Size
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
