using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KaijuGame.Entities
{
    public enum KaijuSize
    {
        Small,
        Medium,
        Large,
        Huge,
        Massive,
        Gigantic,
    }
    public class Kaiju
    {
        private KaijuSize size;
        private int difficulty;


        public Kaiju()
        {
            var r = new Random();
            var kSize = r.Next(3);

            Size = (KaijuSize)kSize;
            Difficulty = ((kSize + 1) * 10);
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

        public string nameEnglish { get; set; }
        public string nameMonster { get; set; }
        public string creature { get; set; }
        public string movement { get; set; }
        public string material { get; set; }
        public string characteristic { get; set; }
        public string weapon { get; set; }
    }
}
