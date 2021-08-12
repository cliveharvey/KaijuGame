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
        private KaijuSize size;
        private int difficulty;

        public Kaiju(int kaijuSize, int difficultyRating)
        {
            size = (KaijuSize)kaijuSize;
            difficulty = difficultyRating;
        }

        public KaijuSize Size
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
